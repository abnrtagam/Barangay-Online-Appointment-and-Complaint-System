import React, { useState, useEffect, useRef } from 'react'
import { Outlet, useNavigate } from 'react-router-dom'
import Navbar from '../components/Navbar'
import axios from 'axios'
import { FiAlertTriangle } from 'react-icons/fi'

export default function ResidentLayout() {
  const navigate = useNavigate()
  const [suspended, setSuspended] = useState(false)
  const [countdown, setCountdown] = useState(5)
  const timerRef = useRef(null)
  const intervalRef = useRef(null)

  useEffect(() => {
    const token = localStorage.getItem('resident_token')
    if (!token) return

    const checkAccountStatus = async () => {
      try {
        const { data } = await axios.get('/api/auth/check-status', {
          headers: { Authorization: `Bearer ${token}` }
        })
        if (data.status === 'suspended') {
          handleSuspension()
        }
      } catch (err) {
        if (err.response?.status === 403 && err.response?.data?.suspended) {
          handleSuspension()
        }
      }
    }

    const handleSuspension = () => {
      if (intervalRef.current) clearInterval(intervalRef.current)
      setSuspended(true)
      
      let count = 5
      timerRef.current = setInterval(() => {
        count -= 1
        setCountdown(count)
        if (count <= 0) {
          clearInterval(timerRef.current)
          localStorage.removeItem('resident_token')
          localStorage.removeItem('resident_user')
          navigate('/login?suspended=true')
        }
      }, 1000)
    }

    checkAccountStatus()
    intervalRef.current = setInterval(checkAccountStatus, 30000)

    return () => {
      if (intervalRef.current) clearInterval(intervalRef.current)
      if (timerRef.current) clearInterval(timerRef.current)
    }
  }, [navigate])

  return (
    <div style={{ minHeight: '100vh', background: 'var(--gray-50)', position: 'relative' }}>
      <Navbar />
      <main style={{ maxWidth: 1200, margin: '0 auto', padding: '32px 24px' }}>
        <Outlet />
      </main>

      {/* Account Suspended Modal */}
      {suspended && (
        <div style={{
          position: 'fixed', top: 0, left: 0, right: 0, bottom: 0,
          background: 'rgba(15, 23, 42, 0.75)', backdropFilter: 'blur(8px)',
          display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 99999
        }}>
          <div style={{
            background: 'white', borderRadius: '32px', padding: '40px', maxWidth: '480px', width: '90%',
            textAlign: 'center', boxShadow: '0 25px 50px -12px rgba(0,0,0,0.25)',
            border: '1px solid #f1f5f9', display: 'flex', flexDirection: 'column', alignItems: 'center'
          }}>
            <div style={{
              width: '64px', height: '64px', borderRadius: '20px', background: '#fef2f2',
              display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: '24px'
            }}>
              <FiAlertTriangle size={32} color="#ef4444" />
            </div>
            
            <h2 style={{ fontSize: '1.5rem', fontWeight: 800, color: '#0f172a', margin: '0 0 12px 0' }}>
              Account Suspended
            </h2>
            
            <p style={{ fontSize: '0.95rem', color: '#475569', lineHeight: 1.6, margin: '0 0 24px 0' }}>
              Your account has been suspended by the barangay admin. You will be logged out automatically. Please contact the barangay office for further assistance.
            </p>

            <div style={{
              width: '80px', height: '80px', borderRadius: '50%', background: '#f8fafc',
              border: '4px solid #ef4444', display: 'flex', alignItems: 'center', justifyContent: 'center',
              fontSize: '2rem', fontWeight: 900, color: '#ef4444', marginBottom: '12px'
            }}>
              {countdown}
            </div>
            
            <div style={{ fontSize: '0.8rem', color: '#94a3b8', fontWeight: 600 }}>
              Logging out in {countdown} seconds...
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
