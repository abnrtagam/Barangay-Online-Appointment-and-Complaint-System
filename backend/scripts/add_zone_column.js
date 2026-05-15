const db = require('../config/db')

async function updateSchema() {
  try {
    console.log('Adding zone column to users table...')
    await db.query(`
      ALTER TABLE users 
      ADD COLUMN zone VARCHAR(20) DEFAULT NULL AFTER address
    `)
    console.log('Success: zone column added.')
    process.exit(0)
  } catch (err) {
    if (err.code === 'ER_DUP_COLUMN_NAME') {
      console.log('Note: zone column already exists.')
      process.exit(0)
    }
    console.error('Error adding zone column:', err.message)
    process.exit(1)
  }
}

updateSchema()
