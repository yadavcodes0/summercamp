import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { create, getNumericDate } from "https://deno.land/x/djwt@v3.0.1/mod.ts";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

// Helper to convert PEM string to CryptoKey
async function importPrivateKey(pem: string) {
  const b64 = pem.replace(/(-----(BEGIN|END) PRIVATE KEY-----|\n)/g, '');
  const bin = atob(b64);
  const buf = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) buf[i] = bin.charCodeAt(i);
  
  return await crypto.subtle.importKey(
    "pkcs8",
    buf.buffer,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"]
  );
}

// Get Google Access Token
async function getAccessToken(serviceAccount: any) {
  const privateKey = await importPrivateKey(serviceAccount.private_key);
  
  const jwt = await create(
    { alg: "RS256", typ: "JWT" },
    {
      iss: serviceAccount.client_email,
      scope: "https://www.googleapis.com/auth/spreadsheets",
      aud: serviceAccount.token_uri,
      exp: getNumericDate(3600),
      iat: getNumericDate(0),
    },
    privateKey
  );

  const res = await fetch(serviceAccount.token_uri, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: `grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=${jwt}`,
  });
  
  if (!res.ok) {
    const err = await res.text();
    throw new Error(`Failed to get access token: ${err}`);
  }
  
  const data = await res.json();
  return data.access_token;
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const payload = await req.json();
    console.log("Received webhook payload:", payload);

    const { type, table, record, old_record } = payload;

    if (table !== 'children') {
        console.log(`Ignoring table: ${table}`);
        return new Response(JSON.stringify({ message: "Ignored table: " + table }), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 200,
        });
    }

    const SPREADSHEET_ID = Deno.env.get('GOOGLE_SPREADSHEET_ID');
    const SERVICE_ACCOUNT_JSON = Deno.env.get('GOOGLE_SERVICE_ACCOUNT_JSON');

    if (!SPREADSHEET_ID || !SERVICE_ACCOUNT_JSON) {
        throw new Error('Missing GOOGLE_SPREADSHEET_ID or GOOGLE_SERVICE_ACCOUNT_JSON');
    }

    const serviceAccount = JSON.parse(SERVICE_ACCOUNT_JSON);
    const token = await getAccessToken(serviceAccount);
    const SHEET_NAME = 'Sheet1';
    
    const apiBase = `https://sheets.googleapis.com/v4/spreadsheets/${SPREADSHEET_ID}`;
    const headers = {
        "Authorization": `Bearer ${token}`,
        "Content-Type": "application/json"
    };

    // Helper to find row index by ID (Assuming child_id is in column B to match format)
    async function getRowIndexByChildId(childId: string) {
        const res = await fetch(`${apiBase}/values/${SHEET_NAME}!B:B`, { headers });
        const data = await res.json();
        const rows = data.values || [];
        for (let i = 0; i < rows.length; i++) {
            if (rows[i][0] === childId) return i + 1; // 1-based index
        }
        return -1;
    }

    // Helper to format time (e.g. 2:50 PM)
    function formatTime(isoString: string | null) {
        if (!isoString) return '';
        const date = new Date(isoString);
        return date.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit', hour12: true });
    }

    // Format output: Child Name, Camp ID, Age, Parent Name, Phone Number, Gender, Entry Status, Entry Time
    const formatRecord = (rec: any) => [
        rec.child_name || '', 
        rec.child_id || '', 
        rec.age || '', 
        rec.parent_name || '', 
        rec.phone || '', 
        rec.gender || '', 
        rec.entry_status ? 'Entered' : 'Not Yet', 
        formatTime(rec.entry_time) 
    ];

    // Helper: Insert a new row inside the table (inherits formatting) and write values
    async function insertRowInTable(values: any[]) {
        // 1. Find the last row with data
        const valRes = await fetch(`${apiBase}/values/${SHEET_NAME}!A:A`, { headers });
        const valData = await valRes.json();
        const lastRow = valData.values?.length || 1; // total rows including header

        // 2. Get sheetId
        const sheetRes = await fetch(apiBase, { headers });
        const sheetData = await sheetRes.json();
        const sheetId = sheetData.sheets?.find((s: any) => s.properties?.title === SHEET_NAME)?.properties?.sheetId ?? 0;

        // 3. Insert a blank row at the end of the table, inheriting formatting from the row above
        const insertRes = await fetch(`${apiBase}:batchUpdate`, {
            method: "POST",
            headers,
            body: JSON.stringify({
                requests: [{
                    insertDimension: {
                        range: {
                            sheetId: sheetId,
                            dimension: 'ROWS',
                            startIndex: lastRow,   // 0-based, inserts AFTER last data row
                            endIndex: lastRow + 1
                        },
                        inheritFromBefore: true    // copies table formatting from row above
                    }
                }]
            })
        });
        if (!insertRes.ok) throw new Error(await insertRes.text());

        // 4. Write values into the newly inserted row (1-based index)
        const newRowIndex = lastRow + 1;
        const updateRes = await fetch(`${apiBase}/values/${SHEET_NAME}!A${newRowIndex}:H${newRowIndex}?valueInputOption=USER_ENTERED`, {
            method: "PUT",
            headers,
            body: JSON.stringify({ values: [values] })
        });
        if (!updateRes.ok) throw new Error(await updateRes.text());
    }

    if (type === 'INSERT') {
        console.log("Inserting new row for child ID:", record.child_id);
        await insertRowInTable(formatRecord(record));
    } 
    else if (type === 'UPDATE') {
        const rowIndex = await getRowIndexByChildId(record.child_id);
        console.log(`Updating row index ${rowIndex} for child ID:`, record.child_id);
        
        if (rowIndex > 0) {
            const res = await fetch(`${apiBase}/values/${SHEET_NAME}!A${rowIndex}:H${rowIndex}?valueInputOption=USER_ENTERED`, {
                method: "PUT",
                headers,
                body: JSON.stringify({ values: [formatRecord(record)] })
            });
            if (!res.ok) throw new Error(await res.text());
        } else {
             console.log("Row not found for UPDATE, inserting instead.");
             await insertRowInTable(formatRecord(record));
        }
    } 
    else if (type === 'DELETE') {
        const idToDelete = old_record?.child_id;
        const rowIndex = await getRowIndexByChildId(idToDelete);
        console.log(`Deleting row index ${rowIndex} for child ID:`, idToDelete);

        if (rowIndex > 0) {
            // Get sheetId
            const sheetRes = await fetch(apiBase, { headers });
            const sheetData = await sheetRes.json();
            const sheetId = sheetData.sheets?.find((s: any) => s.properties?.title === SHEET_NAME)?.properties?.sheetId;
            
            if (sheetId !== undefined) {
                const res = await fetch(`${apiBase}:batchUpdate`, {
                    method: "POST",
                    headers,
                    body: JSON.stringify({
                        requests: [{
                            deleteDimension: {
                                range: {
                                    sheetId: sheetId,
                                    dimension: 'ROWS',
                                    startIndex: rowIndex - 1, // 0-based
                                    endIndex: rowIndex
                                }
                            }
                        }]
                    })
                });
                if (!res.ok) throw new Error(await res.text());
            }
        }
    }

    return new Response(JSON.stringify({ success: true }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    });

  } catch (error) {
    console.error('Error syncing to sheet:', error);
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    });
  }
});
