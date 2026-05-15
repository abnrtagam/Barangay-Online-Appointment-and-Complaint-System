const db = require('../config/db')

async function updateSchema() {
  try {
    console.log('Adding identity fields to users table...')
    await db.query(`
      ALTER TABLE users 
      ADD COLUMN dob DATE DEFAULT NULL AFTER last_name,
      ADD COLUMN gov_id_number VARCHAR(50) DEFAULT NULL AFTER dob,
      ADD COLUMN gov_id_type VARCHAR(50) DEFAULT NULL AFTER gov_id_number
    `)
    console.log('Success: dob and gov_id fields added.')
    process.exit(0)
  } catch (err) {
    if (err.code === 'ER_DUP_COLUMN_NAME') {
      console.log('Note: Fields already exist.')
      process.exit(0)
    }
    console.error('Error adding fields:', err.message)
    process.exit(1)
  }
}

updateSchema()
