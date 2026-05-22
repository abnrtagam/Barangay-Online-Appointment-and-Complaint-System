# Barangay Bulua Online Appointment and Complaint System
## Capstone Project Manuscript

**Project Context:** Barangay Bulua, Cagayan de Oro City

---

## Abstract

The Barangay Bulua Online Appointment and Complaint System is a digital service portal that replaces the manual, paper-based operations of Barangay Bulua. Residents use a mobile application to file complaints and book appointments, while administrators manage everything through a web dashboard. The system features real-time account suspension that logs out flagged users across all devices within 30 seconds, multi-layered security protections, and a permanent audit trail of all administrative actions.

---

## Chapter I: Introduction

### Background of the Study

Barangay Bulua is one of the busiest barangays in Cagayan de Oro City. Its office processes a high volume of complaints, document requests, and appointment scheduling daily — all handled through manual paperwork. Residents must physically visit the hall, wait in line, and fill out forms. Records are kept in filing cabinets, making them hard to search or track. There is no way for residents to check the status of their requests remotely, and no structured log of administrative actions exists for accountability.

### Statement of the Problem

1. Residents must be physically present at the barangay hall for every transaction, causing long wait times.
2. There is no mechanism for residents to track their complaints or appointments after submission.
3. Administrative actions are not logged, making accountability difficult.
4. Suspended user accounts can still access the system if already logged in, creating a security gap.

### Objectives

To develop a secure, multi-platform system that automates appointment scheduling, complaint management, and administrative oversight for Barangay Bulua. Specifically: build a centralized backend server, develop a resident mobile app, create an admin web dashboard, implement real-time session termination for suspended accounts, optimize database performance, and secure the system against common attacks.

### Target Users

**Residents** use the mobile app to register with email verification, submit complaints with attachments, book appointment slots, cancel bookings within the allowed window, and track the status of all their requests.

**Administrators** use the web dashboard to approve resident registrations, manage complaint and appointment workflows, suspend or reactivate accounts, view analytics, export reports, and review a full audit log of all actions taken.

### Scope and Delimitations

The system covers complaint filing, appointment booking, account management, reporting, and real-time session control. It does not include financial transactions or GPS tracking. It is built specifically for Barangay Bulua.

---

## Chapter II: System Architecture

### Development Approach

The project followed the Agile Iterative model, dividing work into phases — from database and server setup, to mobile and web interfaces, to security hardening and the real-time suspension feature.

### System Structure

The system has three layers:

**Client Layer** — Two user-facing applications. A React web dashboard for administrators and a Flutter mobile app for residents. Neither stores permanent data; all actions are sent to the server.

**Server Layer** — A Node.js and Express backend that receives all requests, validates users, processes data, interacts with the database, and sends email notifications.

**Database Layer** — A MySQL relational database that stores all records with defined relationships between tables and automatic cleanup rules when records are deleted.

Both clients communicate with the same server through a REST API using standard HTTP requests and JSON responses.

---

## Chapter III: Database Design

The database has four main tables: **Residents** (user profiles and account status), **Complaints** (filed concerns linked to residents), **Appointments** (scheduled visits linked to residents), and **Admin Activity Log** (timestamped records of every admin action).

Database indexes are automatically created on frequently searched columns to keep queries fast as data grows. Foreign key constraints with cascade rules ensure that deleting a resident automatically removes all their related records, preventing orphaned data.

---

## Chapter IV: Security and Key Features

### Security

The system applies HTTP security headers via Helmet, restricts cross-origin requests to the official portal URL only, sanitizes all user input to prevent script injection, and uses parameterized queries to block SQL injection. Passwords are hashed with Bcrypt using 12 salt rounds.

Login protection uses two layers: a global rate limiter on authentication endpoints, and a per-account lockout that blocks login for 15 minutes after 5 consecutive failed attempts.

### Real-Time Account Suspension

When an admin suspends a resident, three things happen simultaneously. The server middleware immediately blocks all future requests from that account. The web portal detects the suspension within 30 seconds through a background status check and logs the user out with a countdown notification. The mobile app runs the same background check and forces logout with a dialog message. The suspended user cannot perform any further actions on either platform.

### 24-Hour Cancellation Policy

Residents can cancel appointments only if the scheduled date is at least 24 hours away. This is validated using the server clock to prevent manipulation.

### Admin Audit Trail

Every administrative action is permanently logged with the admin's identity, action type, description, and timestamp. This log is searchable, filterable, and cannot be modified through the interface.

---

## Chapter V: Summary, Conclusion, and Recommendations

### Summary

The system was successfully developed as a multi-platform portal. Residents can register, file complaints, book appointments, and track statuses through the mobile app. Administrators manage all operations through the web dashboard with full audit logging. The real-time suspension feature closes the session persistence security gap within 30 seconds.

### Conclusion

The project demonstrates that local government digital services can prioritize both usability and security. The three-tier architecture enables cross-platform access from a single server, and the real-time suspension mechanism achieves high-security session control with minimal resource overhead.

### Recommendations

1. **SMS Notifications** for residents without consistent internet access.
2. **WebSocket Integration** for instant real-time updates once infrastructure supports it.
3. **Automated Complaint Categorization** using natural language processing to prioritize incoming reports.
