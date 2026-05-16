require('dotenv').config()
const express  = require('express')
const db = require('./config/db')
;(async () => {
  try {
    const [cols] = await db.query('DESCRIBE complaints')
    const hasCreatedAt = cols.some(c => c.Field === 'created_at')
    if (!hasCreatedAt) {
      console.log('修复 (Repair): Adding missing created_at to complaints...')
      await db.query('ALTER TABLE complaints ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP AFTER status')
    }
    
    const [cols2] = await db.query('DESCRIBE appointments')
    const hasCreatedAt2 = cols2.some(c => c.Field === 'created_at')
    if (!hasCreatedAt2) {
      console.log('修复 (Repair): Adding missing created_at to appointments...')
      await db.query('ALTER TABLE appointments ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP AFTER status')
    }
    
    // Ensure auth-related tables exist (required for registration)
    await db.query(`
      CREATE TABLE IF NOT EXISTS registration_attempts (
        id INT AUTO_INCREMENT PRIMARY KEY,
        ip_address VARCHAR(45) NOT NULL,
        email VARCHAR(255),
        attempt_count INT DEFAULT 1,
        last_attempt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        blocked_until TIMESTAMP NULL DEFAULT NULL
      )
    `)
    await db.query(`
      CREATE TABLE IF NOT EXISTS otp_verifications (
        id INT AUTO_INCREMENT PRIMARY KEY,
        email VARCHAR(255) NOT NULL,
        otp_code VARCHAR(10) NOT NULL,
        verified BOOLEAN DEFAULT FALSE,
        expires_at TIMESTAMP NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `)
    await db.query(`
      CREATE TABLE IF NOT EXISTS password_reset_tokens (
        id INT AUTO_INCREMENT PRIMARY KEY,
        email VARCHAR(255) NOT NULL,
        token VARCHAR(255) NOT NULL,
        otp_code VARCHAR(10) NOT NULL,
        used BOOLEAN DEFAULT FALSE,
        expires_at TIMESTAMP NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `)

    // Ensure users table has all required columns for registration
    const userColumns = [
      ['dob', 'DATE DEFAULT NULL AFTER last_name'],
      ['gov_id_type', 'VARCHAR(50) DEFAULT NULL AFTER dob'],
      ['gov_id_number', 'VARCHAR(50) DEFAULT NULL AFTER gov_id_type'],
      ['status', "ENUM('pending','approved','rejected','suspended') DEFAULT 'pending' AFTER role"],
      ['email_verified', 'BOOLEAN DEFAULT FALSE AFTER status'],
      ['verification_documents', 'TEXT DEFAULT NULL AFTER email_verified'],
      ['zone', 'VARCHAR(50) DEFAULT NULL AFTER address'],
      ['created_at', 'TIMESTAMP DEFAULT CURRENT_TIMESTAMP'],
    ]
    for (const [col, definition] of userColumns) {
      try { await db.query(`ALTER TABLE users ADD COLUMN ${col} ${definition}`) }
      catch (e) { /* column already exists, skip */ }
    }
    // Backfill users with missing created_at
    await db.query('UPDATE users SET created_at = NOW() WHERE created_at IS NULL OR created_at = "0000-00-00 00:00:00"')

    // BACKFILL existing rows if they have NULL or zero created_at
    await db.query('UPDATE complaints SET created_at = NOW() WHERE created_at IS NULL OR created_at = "0000-00-00 00:00:00" OR created_at = ""')
    await db.query('UPDATE appointments SET created_at = NOW() WHERE created_at IS NULL OR created_at = "0000-00-00 00:00:00" OR created_at = ""')
    console.log('✅ Schema repair and backfill complete')
  } catch (err) { console.error('Schema check failed:', err.message) }
})()
const cors     = require('cors')
const morgan   = require('morgan')
const path     = require('path')
const emailService = require('./services/emailService')

const app = express()

// ── Middleware ──────────────────────────────────────────────
app.use(cors())
app.use(express.json())
app.use(express.urlencoded({ extended: true }))
app.use(morgan('dev'))

// Static uploads
app.use('/uploads', express.static(path.join(__dirname, 'uploads')))

// ── Verify Email Service ────────────────────────────────────
emailService.verifyConnection()

// ── Routes ──────────────────────────────────────────────────
app.use('/api/auth',          require('./routes/authRoutes'))
app.use('/api/complaints',    require('./routes/complaintRoutes'))
app.use('/api/appointments',  require('./routes/appointmentRoutes'))
app.use('/api/residents',     require('./routes/residentRoutes'))
app.use('/api/admin',         require('./routes/adminRoutes'))
app.use('/api/admin/verifications', require('./routes/verificationRoutes'))
app.use('/api/announcements', require('./routes/announcementRoutes'))

// ── Health check ────────────────────────────────────────────
app.get('/api/health', (req, res) => res.json({ status: 'OK', timestamp: new Date() }))

// ── 404 handler ─────────────────────────────────────────────
app.use((req, res) => res.status(404).json({ message: 'Route not found.' }))

// ── Error handler ───────────────────────────────────────────
app.use((err, req, res, next) => {
  console.error(err.stack)
  res.status(err.status || 500).json({ message: err.message || 'Internal server error.' })
})

const PORT = process.env.PORT || 5000
app.listen(PORT, () => {
  console.log(`\n🚀 Barangay Backend running at http://localhost:${PORT}`)
  console.log(`📁 Uploads served at http://localhost:${PORT}/uploads\n`)
})
