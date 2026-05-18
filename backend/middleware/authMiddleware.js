const jwt = require('jsonwebtoken')
const db = require('../config/db')

const authMiddleware = async (req, res, next) => {
  const authHeader = req.headers.authorization
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'Unauthorized. No token provided.' })
  }
  const token = authHeader.split(' ')[1]
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET)
    req.user = decoded

    // DB safety net check
    const [users] = await db.query('SELECT status FROM users WHERE id = ?', [decoded.id])
    if (users.length && users[0].status === 'suspended') {
      return res.status(403).json({ message: 'Account suspended', suspended: true })
    }

    next()
  } catch {
    return res.status(401).json({ message: 'Invalid or expired token.' })
  }
}

module.exports = authMiddleware
