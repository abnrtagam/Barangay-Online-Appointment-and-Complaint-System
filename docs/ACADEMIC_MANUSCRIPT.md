# Barangay Bulua Online Appointment and Complaint System
## Capstone Project Manuscript

**Project Context:** Barangay Bulua, Cagayan de Oro City

---

## 1. Introduction

Barangay Bulua is one of the busiest barangays in Cagayan de Oro City. Its administrative office processes a high volume of complaints, document requests, and appointment scheduling on a daily basis. Traditionally, these processes are handled through manual paperwork, requiring residents to physically visit the barangay hall, wait in long queues, and fill out physical forms. Records are stored in filing cabinets, making them difficult to search, track, or update efficiently.

To address these inefficiencies, the **Barangay Bulua Online Appointment and Complaint System** was developed. It is a multi-platform digital service portal that replaces the manual operations of the barangay. Residents use a mobile application (built with Flutter) to file complaints and book appointments remotely, while administrators manage everything through a centralized web dashboard (built with React). A secure Node.js backend coordinates all data, providing a modernized, transparent, and accountable digital governance solution.

---

## 2. Statement of the Problem

The reliance on manual administrative workflows and basic digital architectures creates several key problems for Barangay Bulua:

1. **Physical Bottlenecks:** Residents must be physically present at the barangay hall for every transaction, causing long wait times and operational friction.
2. **Lack of Transparency:** There is no mechanism for residents to remotely track the progress of their filed complaints or scheduled appointments after submission.
3. **Accountability Deficits:** Administrative actions (such as approving or rejecting records) are not systematically logged, making internal accountability difficult to maintain.
4. **Session Persistence Vulnerability:** In standard digital systems, suspended user accounts can still access the system if they are already logged in, creating a security gap where malicious users can continue to file false reports until their session naturally expires.

---

## 3. Objective

The primary objective of this project is to develop a secure, multi-platform system that automates appointment scheduling, complaint management, and administrative oversight for Barangay Bulua. 

Specific objectives include:
* Building a centralized backend server to act as the single source of truth for all data.
* Developing a resident mobile app for remote registration, complaint filing, and booking.
* Creating a web dashboard for barangay staff to manage workflows and generate reports.
* Implementing a real-time session termination feature that logs out suspended accounts globally within 30 seconds.
* Securing the system against common cyber threats such as brute-force attacks, cross-site scripting (XSS), and SQL injection.

---

## 4. Scope and Limitation

**Scope:**
The system is built exclusively for Barangay Bulua. It covers the end-to-end workflow of:
* Resident account registration with OTP email verification.
* Complaint filing with photo attachments and status tracking.
* Time-slot appointment booking and cancellation policies.
* Administrative reporting, analytics, and an immutable action audit log.
* Real-time session control and account suspension mechanisms.

**Limitation:**
The system does not handle financial transactions, digital payment processing for municipal fees, or real-time GPS tracking of barangay patrol units. It requires an active internet connection for both the mobile and web platforms to function.

---

## 5. System Feature

The platform provides dedicated functionalities tailored for both administrators and residents, supported by advanced technical features.

**Resident Features (Mobile Application):**
* Account registration with secure OTP email verification.
* Submission of complaints with photographic attachments.
* Calendar-based booking of barangay hall appointments.
* A **24-Hour Cancellation Policy** that allows residents to cancel appointments only if the scheduled date is at least 24 hours away.
* Real-time tracking of complaint and appointment statuses through an interactive timeline.

**Administrator Features (Web Dashboard):**
* Review and verification of resident identity documents for account approval.
* Centralized management of complaint workflows (Pending -> Approved -> Resolved) and appointment scheduling.
* Live dashboard feeds displaying incoming resident submissions and real-time statistical analytics.
* Manual suspension or reactivation of resident accounts.
* Generation and export of CSV reports for barangay operations.

**Advanced System-Wide Features:**
* **Real-Time Account Suspension:** When an administrator suspends a resident, a background status check forces a logout on both the web portal and mobile app within 30 seconds, immediately cutting off the user's access.
* **Administrative Audit Trail:** Every significant action taken by an admin (approving a user, updating a complaint, changing a password) is permanently recorded with the admin's identity, action type, and exact timestamp.
* **Multi-Layered Security:**
  * **Brute-Force Protection:** A global rate limiter is applied to endpoints, and a stateful login lock blocks accounts for 15 minutes after 5 consecutive failed login attempts.
  * **Helmet & XSS-Clean:** HTTP security headers protect the web dashboard from clickjacking, while input sanitization scrubs malicious scripts from user submissions.
  * **Cryptography:** All passwords are mathematically hashed using Bcrypt with 12 salt rounds.

---

## 6. Database Schema / ERD

The system uses a highly normalized **MySQL 8** relational database to ensure data integrity and performance. The core tables include:

1. **Residents Table:** Stores user profiles, hashed passwords, verification documents, and account status (Pending, Approved, Suspended).
2. **Complaints Table:** Stores filed concerns (title, category, description, attachments, status). It is linked to the Resident who filed it via a Foreign Key.
3. **Appointments Table:** Stores scheduled visits (purpose, date, time slot). It is also linked to the Resident via a Foreign Key.
4. **Admin Activity Log Table:** Stores chronological, timestamped records of every administrative action taken.

**Optimization & Integrity:**
* **Indexing:** High-frequency query columns (like resident emails and complaint statuses) use B-Tree indexes, speeding up database search times significantly.
* **Cascade Operations:** Foreign keys are configured with `ON DELETE CASCADE`. If a resident record is deleted from the database, all of their linked complaints and appointments are automatically removed, preventing orphaned data.

---

## 7. User Manual

### For Residents (Mobile Application)
1. **Registration:** Open the app and fill out the registration form. Upload a valid ID. Check your email for a 6-digit OTP code to verify your account.
2. **Login:** Wait for an administrator to approve your account. Once approved, log in using your email and password.
3. **Filing a Complaint:** Navigate to the "Complaints" tab. Click the (+) button, fill in the incident details, attach a photo if necessary, and submit. You can track the status (Pending -> Approved -> Resolved) on your dashboard.
4. **Booking an Appointment:** Navigate to the "Appointments" tab. Select an available date and time slot. To cancel an appointment, click on the appointment details (Note: Cancellations must be made at least 24 hours before the schedule).

### For Administrators (Web Dashboard)
1. **Login:** Access the web portal and log in using your administrative credentials.
2. **Dashboard Overview:** View real-time statistics, recent activities, and a live feed of incoming resident submissions.
3. **Account Verifications:** Navigate to "Manage Residents" -> "Verifications" to review uploaded IDs and approve or reject new resident registrations.
4. **Managing Workflows:** Use the "Complaints" and "Appointments" menus to review submissions. Update their statuses (e.g., mark a complaint as "Resolved") to automatically notify the resident.
5. **Suspending Users:** If a resident violates rules, navigate to "Manage Residents", find their name, and click "Suspend". The system will automatically log them out of their app within 30 seconds.
6. **Viewing Logs:** Navigate to the "Activity Log" to see a chronological history of all actions performed by staff members.

---

## 8. Conclusion

The Barangay Bulua Online Appointment and Complaint System successfully demonstrates how local government units can modernize public service delivery without compromising security. By adopting a three-tier architecture, the system provides a seamless, cross-platform experience for both residents and administrators. 

The integration of advanced security features—such as real-time account suspension, input sanitization, and automated audit trails—ensures that the system is highly resistant to both external attacks and internal accountability failures. Ultimately, the project provides Barangay Bulua with a scalable, transparent, and highly secure digital infrastructure that improves constituent satisfaction and streamlines administrative workloads.
