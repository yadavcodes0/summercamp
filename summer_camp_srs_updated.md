
# Software Requirement Specification (SRS)

## 1. Project Title
**Summer Camp QR Registration & Entry Management System**

---

## 2. Introduction

### 2.1 Purpose
The purpose of this application is to digitally manage registration and entry verification for children attending the **Satsang Summer Camp**.

The system will:

- Register children
- Generate a unique ID
- Generate a QR code
- Allow admins to scan QR codes for entry verification
- Allow parents to access their child's QR code before the event

---

## 3. Scope

The app will allow:

- Child Registration
- QR Code Generation
- Parent QR Access
- Admin QR Scanning
- Entry Tracking

The system will ensure:

- No duplicate entries
- Faster entry process
- Digital attendance record
- Parents can retrieve QR codes anytime before the event

---

## 4. User Roles

### 4.1 Parent / Volunteer

**Permissions:**

- Register child
- View child QR code
- Share QR code
- Retrieve child QR code using phone number

### 4.2 Admin

**Permissions:**

- Login
- Scan QR codes
- Verify entry
- View child information

---

## 5. Functional Requirements

### FR1: Child Registration

The system must allow registration with:

- Child Name
- Age
- Parent Name
- Phone Number
- Address

After submission:

- Unique ID generated
- QR code generated
- Data stored in database

---

### FR2: Unique ID Generation

Each child must have a unique ID.

Example:

```
SC2026-0001
SC2026-0002
SC2026-0003
```

---

### FR3: QR Code Generation

After registration:

The system generates a QR code containing:

```
child_id
```

Example QR data:

```
SC2026-0001
```

---

### FR4: Parent QR Access

Parents should be able to access their child’s QR code anytime before the event.

Process:

1. Parent opens the app
2. Parent enters their phone number
3. System fetches children registered with that phone number

Query example:

```
SELECT * FROM children
WHERE phone = entered_phone
```

Parents can:

- View child details
- View QR code
- Download QR code
- Share QR code

---

### FR5: Admin QR Scanning

Admin can scan QR codes using the camera.

System retrieves child data and shows:

- Child Name
- Age
- Parent Name
- Unique ID
- Entry Status

Admin can press:

**Allow Entry**

System updates:

```
entry_status = true
entry_time = timestamp
```

---

### FR6: Duplicate Entry Protection

If a QR code is scanned again:

System shows:

```
Already Entered
```

---

## 6. Non-Functional Requirements

### Performance

QR scan response time:

```
< 2 seconds
```

### Security

- Only admin can access scanner
- QR codes validated with database

### Scalability

System must support:

```
500 - 2000 children
```

---

## 7. System Architecture

### Frontend

**Flutter Mobile App**

Modules:

- Registration
- Parent QR Access
- QR Code Display
- Admin Scanner

### Backend

**Supabase**

Services:

- PostgreSQL Database
- Supabase Authentication (Admin)
- Row Level Security (RLS)

### Architecture Diagram

```
Flutter App
     |
     |
Supabase Authentication
     |
     |
Supabase PostgreSQL Database
     |
QR Code Generation & Verification
```

---

## 8. UI Wireframes

### 1. Home Screen

```
---------------------------
   Summer Camp 2026
---------------------------

[ Register Child ]

[ Find My Child QR ]

[ Admin Login ]

---------------------------
```

---

### 2. Registration Screen

```
-------------------------
Register Child
-------------------------

Child Name:  __________

Age:         __________

Parent Name: __________

Phone:       __________

Address:     __________

[ Register ]

-------------------------
```

---

### 3. QR Code Screen

```
-------------------------
Registration Successful
-------------------------

Child Name: Rahul
ID: SC2026-0001

      [ QR CODE ]

[ Download QR ]

[ Share QR ]

-------------------------
```

---

### 4. Parent Access Screen

```
-------------------------
Find Your Registration
-------------------------

Enter Phone Number

[ View My Child QR ]

-------------------------
```

---

### 5. Parent Children List

```
-------------------------
My Registered Children
-------------------------

Rahul
SC2026-0001

Aman
SC2026-0002
```

---

### 6. Admin Login

```
-----------------------
Admin Login
-----------------------

Username: _________

Password: _________

[ Login ]

-----------------------
```

---

### 7. QR Scanner Screen

```
------------------------
Scan QR Code
------------------------

[ Camera Scanner ]

------------------------
```

---

### 8. Child Verification Screen

```
--------------------------
Child Details
--------------------------

Name: Rahul
Age: 10
Parent: Amit Kumar
ID: SC2026-0001

Status: Not Entered

[ Allow Entry ]

--------------------------
```

---

### 9. Entry Success Screen

```
-------------------------
Entry Successful
-------------------------

Child Rahul has entered

Time:
10:32 AM

-------------------------
```

---

## 9. Database Design

### Table

```
children
```

### Table Structure

| Field | Type | Description |
|------|------|-------------|
| id | uuid | Primary key |
| child_id | text | Unique camp ID |
| child_name | text | Child name |
| age | integer | Age |
| parent_name | text | Parent name |
| phone | text | Parent phone |
| address | text | Address |
| entry_status | boolean | Entry allowed |
| entry_time | timestamp | Entry time |
| created_at | timestamp | Registration time |

Example:

```
child_id: SC2026-0001
child_name: Rahul
age: 10
parent_name: Amit Kumar
phone: 9876543210
address: Delhi
entry_status: false
entry_time: null
created_at: timestamp
```

---

## 10. Admin Table

```
admins
```

Structure:

```
id
username
password
role
```

---

## 11. Flutter Packages

Recommended packages:

```
supabase_flutter
qr_flutter
mobile_scanner
uuid
provider
```

---

## 12. App Workflow

### Registration Flow

```
Register Child
      ↓
Generate Unique ID
      ↓
Save Data in Database
      ↓
Generate QR Code
      ↓
Display QR Code
```

### Parent Access Flow

```
Parent enters phone number
      ↓
Fetch children records
      ↓
Display children list
      ↓
Show QR code
```

### Entry Flow

```
Admin scans QR
      ↓
Fetch child data
      ↓
Check entry_status
      ↓
Allow Entry
      ↓
Update entry_status
```

---

## 13. Future Features

Possible future improvements:

- Admin dashboard
- Live entry counter
- Multiple scanners
- Parent WhatsApp QR delivery
- Attendance report export
