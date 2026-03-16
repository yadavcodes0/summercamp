
# Product Requirement Document (PRD)
## Summer Camp Admin Dashboard

---

# 1. Product Overview

The **Summer Camp Admin Dashboard** is a web-based admin panel that allows organizers of the **Sant Nirankari Mission Summer Camp** to monitor registrations, track entries, analyze participant data, and manage volunteers.

The dashboard provides **real-time insights** into:

- Total registrations
- Entry status
- Remaining children
- Age group distribution
- Gender distribution
- Volunteer data

The dashboard connects directly to the **Supabase database used by the mobile application**.

---

# 2. Objectives

## Primary Goals

- Monitor total camp registrations
- Track real-time entry status
- View detailed child data
- Identify children who have not entered
- Monitor volunteer data

## Secondary Goals

- Analyze demographics
- Export participant data
- Provide real-time operational overview

---

# 3. Target Users

### Admin
Camp organizers with full dashboard access.

### Staff (future role)
Limited access for monitoring entries.

---

# 4. System Architecture

Frontend: Web Admin Dashboard

Backend: Supabase

Database: PostgreSQL

Architecture Flow

Admin Dashboard (Web)
        |
        |
Supabase API
        |
        |
PostgreSQL Database
        |
        |
Mobile App (Registration + Entry Scanner)

---

# 5. Core Features

## 5.1 Overview Dashboard

The main dashboard screen will show **real-time statistics**.

Metrics cards:

- Total Registrations
- Total Children
- Total Volunteers
- Total Entries Completed
- Remaining Children to Enter

Example

Total Registrations: 324  
Entries Completed: 210  
Remaining: 114  

---

## 5.2 Live Entry Monitoring

The dashboard should show **recent entries** as they happen.

Example Table

| Child Name | Camp ID | Entry Time |
|------------|---------|------------|
| Rahul | SC2026-0021 | 10:32 AM |
| Aman | SC2026-0022 | 10:35 AM |

Features:

- Auto refresh
- Sort by time
- Filter by entry status

---

## 5.3 Children Data Table

Admin can view all registered children.

Columns:

| Field | Description |
|------|-------------|
| Child Name | Name of child |
| Age | Age |
| Gender | Gender |
| Parent Name | Parent name |
| Phone Number | Contact |
| Address | Address |
| Entry Status | Entered / Not Entered |
| Entry Time | Timestamp |

Features:

- Search
- Filter
- Sort
- Export CSV

---

## 5.4 Remaining Children Page

Displays children who **have not entered yet**.

Query logic

entry_status = false

Example

Remaining Children: 114

---

## 5.5 Age Group Analytics

Age groups visualization

- 5–8 years
- 9–12 years
- 13–16 years

Charts:

- Pie chart
- Bar chart

---

## 5.6 Gender Distribution

Charts showing:

- Male
- Female
- Other

Graph type:

- Pie chart

---

## 5.7 Volunteers Management

View volunteers working at the event.

| Name | Phone | Assigned Role |
|-----|------|------|

Example Roles

- Gate Entry
- Registration Desk
- Support

---

## 5.8 Search Participant

Search child by:

- Camp ID
- Child Name
- Phone number

Example

Search: SC2026-0012

Result

Child details  
Entry status  

---

# 6. Dashboard Navigation

Sidebar menu

- Dashboard
- Children
- Entries
- Remaining
- Volunteers
- Analytics
- Settings

---

# 7. UI Layout

Layout

Sidebar | Main Content

Top Header

- Summer Camp Admin Panel
- Current Date
- Admin Profile

---

# 8. Database Schema (Supabase)

## Table: children

| Field | Type |
|------|------|
| id | uuid |
| child_id | text |
| child_name | text |
| age | integer |
| gender | text |
| parent_name | text |
| phone | text |
| address | text |
| entry_status | boolean |
| entry_time | timestamp |
| created_at | timestamp |

---

## Table: volunteers

| Field | Type |
|------|------|
| id | uuid |
| name | text |
| phone | text |
| role | text |
| created_at | timestamp |

---

# 9. Real-Time Updates

Dashboard must update automatically when entries occur.

Workflow

Child enters gate  
↓  
QR scanned in mobile app  
↓  
Supabase updates entry_status  
↓  
Dashboard updates instantly  

---

# 10. Security

Admin login required.

Authentication:

- Supabase Auth
- Email + Password

Access levels

Admin → Full access  
Staff → Limited access  

---

# 11. Performance Requirements

Dashboard must support:

500 – 2000 children

Target load time:

< 2 seconds

---

# 12. Export Features

Admin should be able to export data.

Formats:

- CSV
- Excel

Export options:

- All children
- Entered children
- Remaining children

---

# 13. Future Enhancements

Possible upgrades:

- Multi-gate entry tracking
- Entry heatmap
- SMS notifications
- WhatsApp reminders
- Volunteer assignment system

---

# 14. Success Metrics

Success of dashboard measured by:

- Real-time visibility of registrations
- Faster entry operations
- Accurate attendance tracking
- Improved event coordination

---

# 15. Estimated Development Time

| Feature | Time |
|------|------|
| Dashboard UI | 5 hours |
| Data tables | 4 hours |
| Charts | 3 hours |
| Supabase integration | 3 hours |
| Authentication | 2 hours |

Estimated total development time:

15–18 hours
