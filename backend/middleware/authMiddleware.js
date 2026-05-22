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

    const [users] = await db.query('SELECT status, role FROM users WHERE id = ?', [decoded.id])
    if (!users.length) {
      return res.status(401).json({ message: 'User not found.' })
    }

    const { status, role } = users[0]

    if (role === 'resident') {
      if (status === 'suspended') {
        return res.status(403).json({ message: 'Account suspended', suspended: true })
      }
      if (status !== 'approved') {
        const messages = {
          pending: 'Your account is pending admin approval.',
          rejected: 'Your account registration was rejected.',
        }
        return res.status(403).json({
          message: messages[status] || 'Access denied.',
          status,
        })
      }
    }

    next()
  } catch {
    return res.status(401).json({ message: 'Invalid or expired token.' })
  }
}

module.exports = authMiddleware
