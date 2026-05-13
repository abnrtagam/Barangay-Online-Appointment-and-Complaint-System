# Barangay Complaint and Appointment Booking System

## Project Overview

This is a full-stack barangay service system for managing resident accounts, complaint submissions, appointment bookings, and admin review workflows.

The system is built with:
- React.js for the frontend user interface
- Node.js + Express.js for the main API middleware
- Laravel for additional backend services
- MySQL for the database
- XAMPP to run Apache and MySQL locally

Residents can:
- register and verify their email
- submit complaints with file attachments
- book appointments with barangay staff
- track complaint and appointment status updates
- view announcements

Admins can:
- review and approve resident verifications
- manage complaint records and change statuses
- approve or reject appointments
- suspend and reactivate accounts
- post announcements and monitor system activity

Complaint handling includes filing, admin review, status updates, and notification of residents. Appointment booking includes scheduling requests, admin approval, and resident updates.

## System Features

- Resident Registration
- Email Verification
- Admin Verification Approval
- Complaint Submission
- File Attachment Uploads
- Appointment Booking
- Complaint Status Tracking
- Dashboard Management
- Account Suspension / Reactivation
- Announcements Management
- Complaint Resolution Workflow

## System Workflow

### Resident Registration Workflow

```text
Register
→ Email Verification
→ Pending Verification
→ Admin Review
→ Approved or Rejected
→ User Gains Access
```

Each step explained:
- Register: Resident creates an account with name, email, and password.
- Email Verification: The system sends an OTP or verification message to the resident email.
- Pending Verification: The request is stored while admin review is pending.
- Admin Review: An admin checks the resident details and confirms identity.
- Approved or Rejected: The admin grants or denies access.
- User Gains Access: Approved residents can submit complaints and book appointments.

### Complaint Workflow

```text
Resident Submits Complaint
→ Admin Reviews Complaint
→ Status Updates
→ Resident Receives Update
→ Complaint Resolved
```

### Appointment Workflow

```text
Resident Books Appointment
→ Admin Reviews Appointment
→ Schedule Approval/Rejection
→ Resident Receives Update
```

### Account Suspension/Reactivation Workflow

```text
Admin Suspends Account
→ User Loses Access
→ User Requests Reactivation
→ Admin Reviews Request
→ Account Reactivated
```

## Project Structure

```text
frontend/           React frontend application
backend/            Node.js + Express backend middleware
laravel-backend/    Laravel backend services
uploads/            Uploaded file storage
barangay_complaint_system.sql  MySQL schema import file
```

## Requirements

- Node.js
- npm
- Composer
- PHP 8.2+
- XAMPP
- MySQL
- Git

## Step-by-Step Installation Guide

### 1. Clone the Repository

```bash
git clone <repository-url>
cd barangay-system/barangay-system
```

> Make sure you are in the folder that contains `frontend/`, `backend/`, and `laravel-backend/`.

### 2. Setup XAMPP

1. Open the XAMPP Control Panel.
2. Start **Apache**.
3. Start **MySQL**.
4. Open **phpMyAdmin** at `http://localhost/phpmyadmin`.

### 3. Create Database

1. In phpMyAdmin, click **New** and create the database `barangay_complaint_system`.
2. Click **Import**.
3. Choose `barangay_complaint_system.sql`.
4. Click **Go**.

This imports all required tables, seed data, and the initial admin account.

### 4. Configure Backend Environment

#### Node backend

Edit `backend/.env` and confirm the MySQL settings:

```env
PORT=5000
DB_HOST=127.0.0.1
DB_PORT=3306
DB_USER=root
DB_PASSWORD=
DB_NAME=barangay_complaint_system
JWT_SECRET=your_jwt_secret_here
```

#### Laravel backend

Edit `laravel-backend/.env` and confirm:

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=barangay_complaint_system
DB_USERNAME=root
DB_PASSWORD=
```

If `.env` is missing, copy from `.env.example`:
- macOS/Linux: `cp .env.example .env`
- Windows PowerShell: `Copy-Item .env.example .env`

### 5. Install Frontend Dependencies

```bash
cd frontend
npm install
npm run dev
```

The React app will start at `http://localhost:3000`.

### 6. Install Backend Dependencies

```bash
cd ../backend
npm install
npm run dev
```

The Node backend runs on `http://localhost:5000`.

### 7. Install Laravel Backend

```bash
cd ../laravel-backend
composer install
php artisan key:generate
php artisan serve --port=8000
```

The Laravel backend runs on `http://localhost:8000`.

## Running the System

Open these URLs:

- Frontend: `http://localhost:3000`
- Backend API: `http://localhost:5000/api`
- Laravel Backend: `http://localhost:8000`

## Admin Access

Admin users can:
- log in through the admin portal
- approve or reject resident verifications
- manage complaints and update statuses
- approve or reject appointment bookings
- suspend and reactivate resident accounts
- create announcements

Residents can:
- register and verify accounts
- submit complaints with attached files
- book appointments and track responses
- view announcements

## Common Troubleshooting

- npm install issues: delete `node_modules` and `package-lock.json`, then run `npm install` again.
- composer install issues: ensure PHP is installed and run `composer install` inside `laravel-backend`.
- MySQL connection issues: confirm XAMPP MySQL is running and the database name is `barangay_complaint_system`.
- port already in use: use a different port for frontend, backend, or Laravel.
- uploads not showing: ensure `backend/uploads` exists and `backend/server.js` is serving `/uploads`.
- CORS issues: verify `backend/server.js` allows `http://localhost:3000`.
- email verification issues: update SMTP/Gmail credentials in `backend/.env`.

## Important Instructions

- Do not commit `.env` files with credentials.
- Start XAMPP before running the backend.
- Use the SQL file to create the MySQL schema.
- Run frontend, Node backend, and Laravel backend together for the full system.

---

Thank you for using the Barangay Complaint and Appointment Booking System. This guide is designed for developers and beginners to install and run the project successfully.
