# Barangay Bulua Online Appointment and Complaint System
## Capstone Project Technical Manuscript

**Project Context:** Barangay Bulua, Cagayan de Oro City  
**Submitted to:** Academic Instructor & Examination Committee

---

## Table of Contents

1. Abstract
2. Chapter I — Introduction
3. Chapter II — Methodology and System Architecture
4. Chapter III — System Design and Database Structure
5. Chapter IV — Security and Real-Time Features
6. Chapter V — Summary, Conclusion, and Recommendations

---

## Abstract

The Barangay Bulua Online Appointment and Complaint System is a multi-platform digital service portal built to replace the manual, paper-based operations of Barangay Bulua in Cagayan de Oro City. The system allows residents to register, file complaints, and book appointments through a mobile application, while barangay administrators manage all incoming requests through a dedicated web dashboard. The backend server acts as the central bridge between both platforms, handling authentication, data storage, email notifications, and security enforcement. A key technical achievement of this project is its real-time account suspension feature, which can terminate an active user session across both mobile and web platforms within 30 seconds of an administrator taking action, closing a common security gap found in standard web applications.

---

## Chapter I: Introduction

### Background of the Study

Barangay Bulua is one of the busiest residential and commercial barangays in Cagayan de Oro City. Its administrative office handles a high volume of daily transactions, including resident complaints, document requests, and appointment scheduling. Despite the availability of modern technology, these processes are still largely handled through manual paperwork. Residents must physically visit the barangay hall, wait in line, and fill out paper forms. Records are stored in filing cabinets, making them difficult to search, track, or update. There is no system in place for residents to check the status of their submitted complaints or scheduled appointments remotely.

This manual approach creates several problems. Documents can be misplaced. Scheduling conflicts arise because there is no centralized calendar. Residents have no way of knowing whether their concerns are being addressed. Administrators lack a structured record of their own actions, making internal accountability difficult.

Beyond operational issues, there is also a security concern. In digital systems that use token-based authentication, a logged-in user remains authenticated even if their account is suspended by an administrator. The suspended user can continue using the system normally until they log out on their own or until their session token expires. This means a resident whose account has been flagged for abuse could continue to file false complaints or occupy appointment slots for an extended period.

### Statement of the Problem

This project seeks to address the following problems:

1. Residents must be physically present at the barangay hall to file complaints or book appointments, causing long wait times and inefficiencies.
2. There is no transparent mechanism for residents to track the progress of their complaints or appointments after submission.
3. Administrative actions such as approving, rejecting, or updating records are not logged, making it difficult to maintain accountability.
4. When a resident's account is suspended, the user can still access and use the system if they are already logged in, creating a security gap.

### Objectives of the Study

The general objective of this project is to develop a secure, multi-platform digital system that automates appointment scheduling, complaint management, and administrative oversight for Barangay Bulua.

Specifically, the project aims to:

1. Build a backend server that serves as the single source of truth for all resident and administrative data.
2. Develop a mobile application for residents to register, submit complaints, book appointments, and track the status of their requests.
3. Create a web-based admin dashboard for barangay staff to manage residents, complaints, appointments, and generate reports.
4. Implement a real-time session termination feature that automatically logs out suspended residents from both mobile and web platforms within 30 seconds.
5. Optimize database performance through indexing and enforce data integrity through relational constraints.
6. Secure the system against common attacks such as brute-force login attempts, cross-site scripting, and SQL injection.

### Target Users

The system is designed for two primary user groups:

**Residents of Barangay Bulua** use the mobile application to create an account, verify their identity via email, submit complaints with file attachments, book available appointment slots at the barangay hall, cancel appointments within the allowed time window, and view the full status history of all their transactions.

**Barangay Administrators** use the web dashboard to review and approve resident registrations, manage complaint workflows through defined status stages, schedule and confirm appointments, suspend or reactivate resident accounts, view real-time analytics and statistics, export reports to CSV, and review a chronological audit log of all administrative actions taken within the system.

### Scope and Delimitations

The system covers complaint filing, appointment booking, resident account management, administrative reporting, and real-time session control. It does not include financial transactions, payment processing, or GPS-based tracking of barangay personnel. The system is built specifically for Barangay Bulua and its administrative processes.

### Significance of the Study

For residents, the system eliminates the need for physical visits for routine transactions and provides full visibility into the progress of their requests. For administrators, it replaces manual record-keeping with a structured, searchable, and auditable digital workflow. For the field of software engineering, the project demonstrates a practical solution to the session persistence vulnerability in token-based authentication systems using lightweight background polling instead of resource-heavy persistent connections.

---

## Chapter II: Methodology and System Architecture

### Development Approach

The project followed the Agile Iterative development model. Work was divided into phases, each focusing on a specific layer of the system. Early phases established the database schema and core server logic. Middle phases built the mobile and web user interfaces. Later phases focused on security hardening, performance optimization, and the real-time suspension feature. This approach allowed the team to test and refine each layer independently before integrating them.

### How the System is Structured

The system uses a three-tier architecture, meaning the work is divided into three separate layers that communicate with each other through a defined set of rules.

**The Client Layer** is what users see and interact with. There are two clients. The first is a web-based admin dashboard built with React, which barangay staff use on their office computers. The second is a mobile application built with Flutter, which residents install on their Android or iOS phones. Neither client stores permanent data on its own. Every action a user takes — submitting a complaint, booking an appointment, logging in — sends a request to the server.

**The Server Layer** is the central brain of the system. Built with Node.js and Express, it receives all incoming requests from both the web and mobile clients. It checks whether the user is authenticated and authorized, validates the data being submitted, performs the requested operation on the database, and sends back a response. It also handles sending emails for OTP verification and account status notifications.

**The Database Layer** is where all permanent data lives. It uses MySQL, a relational database that organizes data into structured tables with defined relationships between them. For example, every complaint record is linked to the resident who filed it. If a resident's account is removed, all of their associated complaints and appointments are automatically cleaned up by the database itself.

### How the Platforms Communicate

All communication between the clients and the server happens through a REST API. The clients send HTTP requests (such as GET, POST, or PATCH) to specific server endpoints, and the server responds with structured JSON data. This standardized format ensures that both the React web app and the Flutter mobile app can communicate with the exact same server without any modifications.

---

## Chapter III: System Design and Database Structure

### Core Data Tables

The database is organized into several primary tables:

**Residents** stores every registered user's name, email, hashed password, phone number, zone, uploaded verification document, approval status, and account status (which can be Pending, Approved, Rejected, or Suspended).

**Complaints** stores each complaint's title, category, description, optional file attachment, and current status. Each complaint is linked to the resident who submitted it.

**Appointments** stores the purpose of the visit, the selected date and time slot, optional notes, and current status. Each appointment is linked to the resident who booked it.

**Admin Activity Log** records every action taken by an administrator, including what type of action it was, a description of the action, and the exact timestamp. This creates a permanent, searchable record of all administrative behavior.

### Database Performance

As the system accumulates records over months and years of use, searching through large tables can become slow. To prevent this, the system automatically creates database indexes on the most frequently searched columns during server startup. An index works like a table of contents in a book — instead of scanning every single row to find a match, the database can jump directly to the relevant section. This reduces search times dramatically, especially for login lookups by email, filtering complaints by resident, and sorting audit logs by date.

### Data Integrity

All relationships between tables are enforced at the database level using foreign key constraints. This means the database itself will reject any operation that would create an orphaned record, such as a complaint that references a resident who does not exist. Additionally, cascade rules ensure that when a resident record is deleted, all of their complaints, appointments, and related history records are automatically removed in the same operation, keeping the database clean without requiring manual cleanup.

---

## Chapter IV: Security and Real-Time Features

### Security Layers

The system implements security at multiple levels:

**HTTP Security Headers** are applied automatically to every server response using the Helmet library. These headers instruct browsers to block clickjacking attempts, prevent content type sniffing, and enforce strict transport security.

**Cross-Origin Request Protection** restricts which websites are allowed to communicate with the server. Only the official admin web portal URL is permitted, preventing unauthorized third-party websites from making requests to the backend.

**Input Sanitization** automatically cleans all incoming data from users, stripping out potentially dangerous HTML or script tags before the data reaches the database. This protects against cross-site scripting attacks.

**Parameterized Database Queries** ensure that user input is never directly inserted into SQL commands. Instead, the database driver treats all user input as plain data values, completely preventing SQL injection attacks.

### Login Protection

To defend against brute-force login attacks, the system uses two layers of protection. First, a global rate limiter restricts the number of requests any single IP address can make to authentication endpoints within a given time window. Second, a stateful login lock tracks failed login attempts per account in the database. After five consecutive incorrect password entries, the account is locked for 15 minutes. During this lockout period, the server rejects login attempts immediately without even checking the password, which also protects the server from being overwhelmed by repeated cryptographic operations.

All passwords are stored using Bcrypt hashing with 12 salt rounds, making them resistant to offline dictionary attacks even if the database were compromised.

### Real-Time Account Suspension

This is the system's most technically significant security feature. It solves the problem where a suspended resident can continue using the system because their login token is still valid.

The solution works in three coordinated parts:

**On the server**, every single authenticated request passes through a middleware layer that checks not only whether the token is valid, but also whether the user's current status in the database is still active. If the database shows the user as Suspended, the server immediately rejects the request with a 403 Forbidden response, regardless of whether the token itself is still technically valid.

**On the web portal**, a background process runs silently every 30 seconds while the resident is logged in. It sends a lightweight check to the server asking for the account's current status. If the server responds that the account is suspended (or returns a 403 error), the web portal immediately displays a countdown overlay informing the user that their account has been suspended. After five seconds, the portal clears all stored credentials and redirects the user to the login page.

**On the mobile app**, the same 30-second background check runs in parallel. When suspension is detected, the app displays a dialog with a five-second countdown, then clears the user's session and returns them to the login screen with a notification explaining what happened.

The result is that when an administrator suspends a resident's account, the resident is automatically logged out from every active session — both web and mobile — within a maximum of 30 seconds. The resident cannot perform any further actions because the server-side middleware blocks all requests from suspended accounts, even if the client somehow bypasses the logout flow.

### Appointment Cancellation Policy

To prevent residents from booking appointment slots and then cancelling at the last minute, leaving gaps in the barangay's schedule, the system enforces a 24-hour cancellation policy. A resident can only cancel a pending or approved appointment if the scheduled date is at least 24 hours away. This calculation is performed on the server using the server's own clock, not the client device's clock, preventing manipulation. If a resident attempts to cancel within the 24-hour window, the request is rejected with an explanation.

### Administrative Audit Trail

Every significant action taken by an administrator — approving a resident, changing a complaint's status, suspending an account, changing their own password — is automatically recorded in the audit log. Each entry includes the administrator's identity, the type of action, a human-readable description, and the exact timestamp. This log is fully searchable, filterable by action type, and paginated for easy navigation. It cannot be modified or deleted through the admin interface, ensuring its integrity as an accountability record.

---

## Chapter V: Summary, Conclusion, and Recommendations

### Summary

The Barangay Bulua Online Appointment and Complaint System was successfully developed as a multi-platform digital governance portal. The mobile application enables residents to register with email verification, file complaints, book appointments, and track request statuses. The web admin dashboard provides barangay staff with real-time analytics, structured workflow management, report generation, and full account control. The backend server secures all operations through layered rate limiting, input sanitization, encrypted password storage, and enforced database integrity. The real-time suspension feature terminates active sessions within 30 seconds across all platforms, closing the session persistence vulnerability.

### Conclusion

The system demonstrates that local government digital services can be built with both usability and security as primary design objectives. By separating the system into distinct, independent layers connected through a standardized API, the project achieves cross-platform accessibility without duplicating business logic. The real-time suspension mechanism proves that critical security requirements can be met using lightweight polling techniques that consume minimal server and network resources, making the approach viable even for organizations with limited IT infrastructure.

### Recommendations

For future development, the following enhancements are recommended:

1. **SMS Notifications:** Adding SMS-based alerts for residents who may not have consistent internet access, ensuring they receive appointment confirmations and status updates regardless of connectivity.
2. **WebSocket Integration:** Upgrading the 30-second polling mechanism to a persistent WebSocket connection for true real-time updates, once the barangay's server infrastructure can support sustained concurrent connections.
3. **Automated Complaint Categorization:** Integrating natural language processing to automatically classify and prioritize incoming complaints based on content analysis, reducing manual sorting work for administrators.
