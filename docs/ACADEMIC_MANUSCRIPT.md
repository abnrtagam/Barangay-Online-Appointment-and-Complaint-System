# 🏛️ CAPSTONE PROJECT TECHNICAL MANUSCRIPT
## SYSTEM DOCUMENTATION: CHAPTERS I - V
**Project Title:** Barangay Bulua Online Appointment and Complaint System  
**Context:** Barangay Bulua, Cagayan de Oro City  
**Target:** Academic Instructor & Examination Committee  

---

# 📑 TABLE OF CONTENTS
1. **[Abstract](#abstract)**
2. **[Chapter I: Introduction](#chapter-i-introduction)**
   * Background of the Study
   * Statement of the Problem
   * Objectives of the Study
   * Scope and Delimitations
   * Significance of the Study
3. **[Chapter II: Technical Methodology & System Architecture](#chapter-ii-technical-methodology--system-architecture)**
   * Software Development Life Cycle (SDLC)
   * Three-Tier System Architecture
   * Platform Interoperability
4. **[Chapter III: System Design & Relational Database Schema](#chapter-iii-system-design--relational-database-schema)**
   * Relational Database Schema Design
   * Database Indexing & Query Optimizations
   * Referential Integrity & Cascade Operations
5. **[Chapter IV: Security Implementations & Synchronization Logic](#chapter-iv-security-implementations--synchronization-logic)**
   * Multi-Layer Security Configuration
   * Dual-Layer Rate Limiting & Hashing
   * Real-Time Account Suspension Syncing
   * Scheduling Rules & 24-Hour Cancellation Policy
   * Administrative Audit Trails & Live Feeds
6. **[Chapter V: Summary, Conclusion, and Recommendations](#chapter-v-summary-conclusion-and-recommendations)**
   * Summary of Findings
   * Conclusions
   * Recommendations for Future Work

---

# 📝 ABSTRACT

The **Barangay Bulua Online Appointment and Complaint System** is a secure, multi-platform digital governance portal designed to modernize public service administration in Barangay Bulua, Cagayan de Oro City. The system addresses operational friction in traditional manual transaction logging, the lack of immediate feedback loops in citizen report tracking, and the security vulnerabilities associated with delayed session termination for suspended user accounts. 

Built using a decoupled **three-tier architecture**, the platform comprises:
1. A cross-platform mobile resident application engineered in **Flutter** using the **Provider** pattern for state management.
2. A high-performance web administration console designed in **React 18** and built with **Vite**.
3. A hardened RESTful API backend structured in **Node.js** and **Express**, utilizing a relational **MySQL 8** database.

Key technical milestones include:
*   A **real-time session termination protocol** that detects administrative account suspensions and terminates active resident app and web sessions globally within **30 seconds** via lightweight API polling and custom middleware interception (`403 Forbidden`).
*   A robust **security framework** incorporating Helmet HTTP headers, XSS-Clean input sanitization, dynamic CORS origin validation, and a stateful login rate limiter that locks accounts for 15 minutes after 5 consecutive failures.
*   An **automated indexing system** that provisions database B-Trees on high-frequency columns, reducing table-scan lookup complexity from linear $O(N)$ to logarithmic $O(\log N)$ time.
*   Strict **data integrity rules**, including database-level foreign key cascades (`ON DELETE CASCADE`) and an administrative audit logging trail.

This manuscript details the software engineering methodologies, database design, cryptographic implementations, and operational outcomes of the developed system.

---

# 🏛️ CHAPTER I: INTRODUCTION

### Background of the Study
Local government units (LGUs) at the barangay level serve as the primary interface between the government and the community. In highly populated urban barangays, such as Barangay Bulua in Cagayan de Oro City, administrative staff process hundreds of transactions daily, including document requests, scheduling municipal facility usage, and handling civil disputes or community complaints.

Despite rapid technological advancements, many barangays still rely on manual, paper-based operations. Residents are forced to physically travel to the barangay hall to request services, file complaints, or schedule appointments. This manual pipeline suffers from operational bottlenecks, such as paper records being lost, long queues, lack of updates for constituents, and administrative lag.

Additionally, digital governance systems must navigate complex security requirements. When constituents register online, their identities must be verified to prevent fraudulent reports. In cases of system abuse or malicious false reporting, administrators require immediate tools to suspend resident accounts. However, conventional web architectures suffer from the **Session Persistence Loophole**: once a client logs in and receives an access token, they remain authenticated until the token naturally expires, even if their status is changed to "Suspended" in the database. Bridging this gap requires real-time status-validation layers that protect the integrity of the civic system.

### Statement of the Problem
The operational reliance on manual workflows and basic web architectures in Barangay Bulua results in several systemic vulnerabilities:
1.  **Administrative Inefficiencies:** Manual scheduling of appointments causes scheduling conflicts, overbooking, and excessive physical queues at the barangay hall.
2.  **Opacity in Civic Processes:** Residents lack a transparent tracking mechanism for submitted complaints, leading to a lack of updates on resolutions.
3.  **Accountability and Audit Deficits:** The absence of structured logging for administrative activities leaves the organization vulnerable to untraceable modifications of record statuses.
4.  **Vulnerabilities in Session Termination:** Standard authentication protocols fail to immediately revoke access for suspended accounts. Active, suspended residents can continue to make database changes (such as filing false complaints and booking slots) until their local sessions expire.

### Objectives of the Study
#### General Objective
To design, develop, and implement a highly secure, multi-platform digital governance portal that automates appointment scheduling, streamlines complaint management, enforces administrative accountability, and secures real-time constituent session synchronization for Barangay Bulua.

#### Specific Objectives
1.  To build a secure RESTful API backend using Node.js, Express, and MySQL that serves as a single source of truth for administrative and resident records.
2.  To develop a cross-platform resident mobile application in Flutter that enables OTP email verification, secure document upload, calendar-based appointment booking, and complaint tracking with interactive status timelines.
3.  To design a web admin portal in React 18 using Vite that provides automated statistical summaries, structured status transitions, and a searchable administrative audit trail.
4.  To implement a **Real-Time Session Termination Protocol** that programmatically terminates suspended user sessions in less than 30 seconds across all platforms.
5.  To optimize database query performance by programmatically implementing index-based B-Tree optimizations, and to prevent data corruption using foreign key cascades.
6.  To secure the system using dual-layered rate limiting, Helmet HTTP security headers, input sanitization via XSS-Clean, and password hashing via Bcrypt.

### Scope and Delimitations
The system is built specifically for **Barangay Bulua, Cagayan de Oro City**.
*   **The system includes:**
    *   **Resident Portal (Mobile & Web):** Email registration verified via SMTP 6-digit OTP, profile document upload, complaint submission, time-slot scheduling, a 24-hour cancellation threshold, and chronological status timelines.
    *   **Admin Console (Web):** Dynamic analytics dashboard, resident status control, document approval, paginated/filterable CSV reporting, live dashboard notification feeds, and an immutable action logging utility.
*   **The system excludes:**
    *   Financial transactions or digital payment processing for municipal fees.
    *   Direct real-time GPS tracking of barangay patrol units.

### Significance of the Study
*   **For Residents of Barangay Bulua:** Offers a secure, transparent, and convenient portal to file concerns and schedule visits without physical delays.
    **For Barangay Administrators:** Streamlines manual records, prevents scheduling conflicts, enforces administrative accountability, and provides immediate control over malicious activity.
*   **For Software Engineering Research:** Demonstrates a practical implementation of lightweight API status polling and interceptors to solve session persistence vulnerabilities in distributed client systems.

---

# 💻 CHAPTER II: TECHNICAL METHODOLOGY & SYSTEM ARCHITECTURE

### Software Development Life Cycle (SDLC)
The development team utilized the **Agile Iterative Model**. This model enabled continuous development, rapid prototyping of security boundaries, and modular component testing. Each iteration prioritized distinct system layers:
1.  **Phase 1-2:** Schema definition, core REST API controllers, and JWT authorization setup.
2.  **Phase 3-4:** Flutter UI creation (Provider integration) and React dashboard implementation.
3.  **Phase 5-7:** Security hardening (Helmet, rate limits) and indexing optimizations.
4.  **Phase 8-9:** Real-time cancellation constraints and admin activity audit logging.
5.  **Phase 11:** Production build integration, PM2 configuration, and **Real-Time Account Suspension Syncing**.

### Three-Tier System Architecture
The application is structured around a decoupled **three-tier architecture**:
1.  **Presentation Tier (Client Layer):** The user interface is split into two major clients:
    *   *React 18 Web Portal:* Structured with Vite for optimized building, using Vanilla CSS for UI styles and Recharts for administrative visual analytics.
    *   *Flutter Mobile App:* A cross-platform mobile client for Android and iOS using Dart, organized with Provider for state propagation and high-fidelity widgets for layout rendering.
2.  **Logic Tier (Application Server Layer):** A RESTful API built on Node.js and Express. It parses client requests, executes validation, filters inputs using sanitizers, and validates identity states via JWT tokens and active database checks.
3.  **Data Tier (Database Layer):** MySQL 8 acts as the relational storage engine. It enforces strict relational integrity, referential constraints, and optimized access paths via indexes.

### Platform Interoperability
Data is serialized exclusively using **JSON (JavaScript Object Notation)** formats over HTTPS. The systems map to a unified data structure, ensuring that status labels, timestamps, and error responses maintain schema consistency whether processed in Dart (mobile) or JavaScript (web/backend).

---

# 📊 CHAPTER III: SYSTEM DESIGN & DATABASE IMPLEMENTATION

### Relational Database Schema Design
The data schema consists of six core relational tables designed to eliminate redundant attributes and ensure relational integrity:

```sql
-- 1. Residents Table
CREATE TABLE IF NOT EXISTS residents (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    zone VARCHAR(50) NOT NULL,
    verification_doc VARCHAR(255),
    is_verified BOOLEAN DEFAULT FALSE,
    status ENUM('Pending', 'Approved', 'Rejected', 'Suspended') DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Complaints Table
CREATE TABLE IF NOT EXISTS complaints (
    id INT AUTO_INCREMENT PRIMARY KEY,
    resident_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    attachment VARCHAR(255),
    status ENUM('Pending', 'Approved', 'Scheduled', 'Resolved') DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (resident_id) REFERENCES residents(id) ON DELETE CASCADE
);

-- 3. Appointments Table
CREATE TABLE IF NOT EXISTS appointments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    resident_id INT NOT NULL,
    purpose VARCHAR(255) NOT NULL,
    appointment_date DATE NOT NULL,
    appointment_time VARCHAR(20) NOT NULL,
    status ENUM('Pending', 'Approved', 'Completed', 'Cancelled') DEFAULT 'Pending',
    additional_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (resident_id) REFERENCES residents(id) ON DELETE CASCADE
);

-- 4. Admin Activity Log Table
CREATE TABLE IF NOT EXISTS admin_activity_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    admin_id INT NOT NULL,
    action_type VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Database Indexing & Query Optimizations
To ensure sub-second response times as the platform handles thousands of records over years of service, an automated query optimization routine is executed during server startup. It programmatically maps B-Tree indexes to high-frequency query columns:

$$\text{Search Complexity Reduction: } O(N) \rightarrow O(\log N)$$

```javascript
// Programmatic Index Provisioning on Startup
const createIndexes = async () => {
  const indexes = [
    { table: 'residents', name: 'idx_resident_email', cols: '(email)' },
    { table: 'residents', name: 'idx_resident_status', cols: '(status)' },
    { table: 'complaints', name: 'idx_complaint_resident', cols: '(resident_id)' },
    { table: 'appointments', name: 'idx_appointment_resident', cols: '(resident_id)' },
    { table: 'admin_activity_log', name: 'idx_log_created', cols: '(created_at)' }
  ];

  for (const idx of indexes) {
    try {
      await db.query(`CREATE INDEX ${idx.name} ON ${idx.table} ${idx.cols}`);
      console.log(`Index ${idx.name} verified successfully.`);
    } catch (err) {
      if (err.errno !== 1061) throw err; 
    }
  }
};
```

### Referential Integrity & Cascade Operations
By binding foreign keys with `ON DELETE CASCADE` at the SQL engine level, we prevent database pollution from orphaned rows. If a user record is deleted, MySQL automatically deletes all related complaints, appointments, status updates, and history trails in a single atomic transaction. This maintains data consistency without requiring heavy administrative script sweeps.

---

# 🛡️ CHAPTER IV: SECURITY IMPLEMENTATIONS & SYNCHRONIZATION LOGIC

### Multi-Layer Security Configuration
The application enforces security at the boundary, server, and transaction layers:
*   **Helmet.js Integration:** The backend API applies the `helmet` package to inject 11 HTTP security headers. This includes configuring the **X-Frame-Options** header to prevent clickjacking and enforcing strict Content Security Policies (CSP).
*   **CORS Hardening:** Cross-Origin Resource Sharing (CORS) is configured dynamically to trust and accept requests *only* from the designated `FRONTEND_URL`. 
*   **XSS Input Sanitization:** To block Cross-Site Scripting (XSS) injections, all incoming string fields inside JSON payloads are sanitized on the server before they hit database queries, removing malicious `<script>` tags.

### Dual-Layer Rate Limiting & Hashing
To secure the application against brute-force attacks, a stateful double protection strategy was engineered:

1.  **Global Rate Limiting:** Built using `express-rate-limit`, limiting registration endpoint requests to 20 per hour.
2.  **Stateful Login Lockouts:** Failed logins increment a count inside the database. Upon reaching **5 consecutive failed attempts**, the system locks the target email address for **15 minutes**. Subsequent attempts during this lock window are rejected instantly before running `bcrypt.compare()` algorithms, shielding the server's CPU from potential denial-of-service (DoS) attempts.
3.  **Password Hashing:** Passwords are encrypted using **Bcrypt** with **12 salt rounds**, rendering them secure against offline dictionary attacks.

### Real-Time Account Suspension Syncing
To close the **Session Persistence Loophole**, we designed a background status checking workflow that coordinates the backend middleware with the client layouts.

#### 1. Backend Middleware Implementation (`authMiddleware.js`)
```javascript
const authMiddleware = async (req, res, next) => {
  try {
    const token = req.headers.authorization?.split(" ")[1];
    if (!token) return res.status(401).json({ message: "No token provided" });

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;

    // Deep Status Check against the database
    const [user] = await db.query("SELECT status FROM residents WHERE id = ?", [decoded.id]);
    if (!user.length) return res.status(404).json({ message: "User not found" });

    if (user[0].status === "Suspended") {
      return res.status(403).json({ 
        success: false, 
        suspended: true, 
        message: "Your account has been suspended by the administrator." 
      });
    }

    next();
  } catch (error) {
    res.status(401).json({ message: "Invalid or expired token" });
  }
};
```

#### 2. React Web Client Polling (`ResidentLayout.jsx`)
A background execution hook runs in the main resident routing layer:
```javascript
useEffect(() => {
  const checkAccountStatus = async () => {
    try {
      const response = await api.get('/auth/check-status');
      if (response.data.status === 'Suspended') {
        triggerSuspensionCountdown();
      }
    } catch (err) {
      if (err.response?.status === 403) {
        triggerSuspensionCountdown();
      }
    }
  };

  const interval = setInterval(checkAccountStatus, 30000); // 30s background check
  return () => clearInterval(interval);
}, []);
```

#### 3. Flutter Mobile Interception (`navigation_shell.dart`)
A matching background timer is implemented in Dart to handle mobile clients:
```dart
void startSuspensionPoller() {
  _statusTimer = Timer.periodic(Duration(seconds: 30), (timer) async {
    final response = await ApiService.get('/auth/check-status');
    if (response['statusCode'] == 403 || response['success'] == false) {
      _statusTimer?.cancel();
      triggerSuspensionCountdown();
    }
  });
}
```
*   **Result:** When an administrator marks a user as suspended, their active session is terminated globally within **30 seconds** on both web and mobile devices, preventing any further database changes.

### Scheduling Rules & 24-Hour Cancellation Policy
To maintain structured planning for barangay services, appointments are bound by scheduling rules:
*   **Collision Detection:** The database runs select statements on slots prior to writing records, disabling booking slots once they are reserved.
*   **The 24-Hour Cancellation Lock:** To prevent empty calendars, residents can only cancel their appointments if the date of scheduling is $\ge 24\text{ hours}$ away. The backend validates this by calculating the delta between the target slot and the server's master clock:

$$\Delta t = t_{\text{appointment}} - t_{\text{current server time}} \ge 86,400 \text{ seconds (24 Hours)}$$

If $\Delta t < 86,400$ seconds, the database update is aborted, returning an error payload.

### Administrative Audit Trails & Live Feeds
*   **Admin Audit Trails:** Implemented using a secure logging service, recording all status updates, resident status controls, and security changes. It tracks:
    $$\text{Audit Log Entry} = \{\text{AdminID}, \text{ActionType}, \text{Description}, \text{Timestamp}\}$$
*   **Live Dashboard Feeds:** A visual dashboard component in the React admin workspace displays resident submissions dynamically. Complex SQL queries resolve joint table attributes (joining `complaints` or `appointments` with `residents`) to display constituent names in real-time.

---

# 🏁 CHAPTER V: SUMMARY, CONCLUSION, AND RECOMMENDATIONS

### Summary of Findings
The development and testing phases of the Barangay Bulua Online Appointment and Complaint System yielded several technical results:
1.  **Queue Reduction:** Automating time-slot reservations replaces physical queues with scheduled visits, allowing administrative staff to allocate hours efficiently.
2.  **Improved Security Integrity:** Integrating dual-layered rate limiters, Helmet headers, and Bcrypt successfully protected the database from injection and dictionary attacks during stress tests.
3.  **Instant Session Control:** The real-time suspension mechanism terminated active sessions in under 30 seconds across web and mobile configurations, resolving the session persistence vulnerability.
4.  **Optimized Performance:** Programmatic database indexing improved database lookup times under concurrent simulated request streams.

### Conclusions
The Barangay Bulua Online Appointment and Complaint System successfully digitizes local governance services. Decoupling the architecture into a secure Node.js API, React administration console, and Flutter mobile client delivers cross-platform access and administrative security. 

Furthermore, the implementation of active session-status validation closes the security loopholes of standard stateless JWT architectures, demonstrating that high-security requirements can be achieved with minimal processing overhead.

### Recommendations for Future Work
To expand the platform, future development iterations should prioritize:
1.  **Fully Bidirectional WebSockets Integration:** Transitioning the background status pollers into active WebSocket pipelines once the barangay IT infrastructure upgrades to support persistent connection states.
2.  **SMS Gateway Fallback:** Adding SMS-based OTP and status notifications to support constituents who do not have continuous mobile data access.
3.  **Machine Learning Sentiment Analysis:** Incorporating automated Natural Language Processing (NLP) models in the admin panel to automatically tag, categorize, and prioritize resident complaints based on urgency and sentiment.
