import React, { useState, useEffect } from 'react'
import axios from 'axios'
import { AlertMessage } from '../components/DashboardCard'
import { FiUser, FiLock, FiShield, FiCheckCircle, FiEdit, FiSave } from 'react-icons/fi'

export default function AdminProfile() {
  // ── State ──────────────────────────────────────────────────
  const [alert, setAlert] = useState(null)
  const [passwordAlert, setPasswordAlert] = useState(null)
  const [loading, setLoading] = useState(false)
  const [profileLoading, setProfileLoading] = useState(false)
  const [editing, setEditing] = useState(false)

  const [passwordForm, setPasswordForm] = useState({ current_password: '', new_password: '', confirm_password: '' })
  const [profileForm, setProfileForm] = useState({ first_name: '', last_name: '', email: '', phone: '', two_factor_enabled: false })

  const token = localStorage.getItem('admin_token')

  // ── Load admin data from localStorage ─────────────────────
  const getAdmin = () => {
    try {
      const data = localStorage.getItem('admin_user')
      if (!data || data === 'undefined') return {}
      return JSON.parse(data)
    } catch { return {} }
  }

  const [admin, setAdmin] = useState(getAdmin)

  useEffect(() => {
    setProfileForm({
      first_name: admin.first_name || '',
      last_name: admin.last_name || '',
      email: admin.email || '',
      phone: admin.phone || '',
      two_factor_enabled: !!admin.two_factor_enabled
    })
  }, [admin.first_name, admin.last_name, admin.email, admin.phone, admin.two_factor_enabled])

  // ── Profile Edit Handlers ─────────────────────────────────
  const handleProfileChange = e => {
    const { name, value, type, checked } = e.target
    setProfileForm(p => ({ ...p, [name]: type === 'checkbox' ? checked : value }))
  }

  const handleProfileSubmit = async e => {
    e.preventDefault()
    setAlert(null)
    if (!profileForm.first_name.trim() || !profileForm.last_name.trim() || !profileForm.email.trim()) {
      return setAlert({ type: 'error', message: 'First name, last name, and email are required.' })
    }
    setProfileLoading(true)
    try {
      await axios.patch('/api/admin/profile', profileForm, { headers: { Authorization: `Bearer ${token}` } })
      // Sync to localStorage so sidebar & header update immediately
      const updatedAdmin = { ...admin, ...profileForm }
      localStorage.setItem('admin_user', JSON.stringify(updatedAdmin))
      setAdmin(updatedAdmin)
      setAlert({ type: 'success', message: 'Profile updated successfully!' })
      setEditing(false)
    } catch (err) {
      setAlert({ type: 'error', message: err.response?.data?.message || 'Failed to update profile.' })
    } finally {
      setProfileLoading(false)
    }
  }

  // ── Password Change Handlers ──────────────────────────────
  const handlePasswordChange = e => {
    setPasswordForm(p => ({ ...p, [e.target.name]: e.target.value }))
    setPasswordAlert(null)
  }

  const handlePasswordSubmit = async e => {
    e.preventDefault()
    setPasswordAlert(null)

    if (!passwordForm.current_password || !passwordForm.new_password) {
      return setPasswordAlert({ type: 'error', message: 'All fields are required.' })
    }
    if (passwordForm.new_password.length < 8) {
      return setPasswordAlert({ type: 'error', message: 'New password must be at least 8 characters.' })
    }
    if (passwordForm.new_password !== passwordForm.confirm_password) {
      return setPasswordAlert({ type: 'error', message: 'New passwords do not match.' })
    }

    setLoading(true)
    try {
      await axios.patch('/api/admin/profile/password', {
        current_password: passwordForm.current_password,
        new_password: passwordForm.new_password
      }, { headers: { Authorization: `Bearer ${token}` } })
      setPasswordAlert({ type: 'success', message: 'Password changed successfully!' })
      setPasswordForm({ current_password: '', new_password: '', confirm_password: '' })
    } catch (err) {
      setPasswordAlert({ type: 'error', message: err.response?.data?.message || 'Failed to change password.' })
    } finally {
      setLoading(false)
    }
  }

  // ── Render ─────────────────────────────────────────────────
  return (
    <div>
      {/* Premium Gradient Header */}
      <div style={{
        background: 'linear-gradient(135deg, #1e40af 0%, #2563eb 60%, #3b82f6 100%)',
        padding: '32px 40px', borderRadius: '16px', marginBottom: '24px',
        color: 'white', boxShadow: '0 10px 30px rgba(37, 99, 235, 0.15)'
      }}>
        <h1 style={{ fontSize: '2rem', fontWeight: 800, margin: '0 0 8px 0', fontFamily: 'var(--font-heading)', color: '#ffffff' }}>Admin Profile</h1>
        <p style={{ margin: 0, color: 'rgba(255,255,255,0.7)', fontSize: '0.95rem' }}>Manage your account settings, personal details, and security.</p>
      </div>

      <div className="grid-2" style={{ alignItems: 'start' }}>
        {/* ── LEFT COLUMN ──────────────────────────────────── */}
        <div>
          {/* Profile Info / Edit Card */}
          <div className="card" style={{ border: 'none', borderRadius: '16px', boxShadow: '0 4px 20px rgba(0,0,0,0.03)', overflow: 'hidden' }}>
            <div className="card-header" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <span className="card-title"><FiUser style={{ marginRight: 8 }} />Account Information</span>
              {!editing && (
                <button className="btn btn-secondary btn-sm" onClick={() => setEditing(true)}>
                  <FiEdit /> Edit
                </button>
              )}
            </div>
            <div className="card-body">
              {alert && <AlertMessage type={alert.type} message={alert.message} onClose={() => setAlert(null)} />}

              {!editing ? (
                /* ── View Mode ── */
                <>
                  <div style={{ textAlign: 'center', marginBottom: 24 }}>
                    <div style={{
                      width: 80, height: 80, borderRadius: '50%', background: 'var(--primary-100)',
                      color: 'var(--primary-700)', display: 'flex', alignItems: 'center', justifyContent: 'center',
                      margin: '0 auto 16px', fontFamily: 'var(--font-heading)', fontWeight: 800, fontSize: '1.8rem',
                    }}>
                      {admin.first_name?.[0]}{admin.last_name?.[0]}
                    </div>
                    <div style={{ fontFamily: 'var(--font-heading)', fontWeight: 700, fontSize: '1.1rem' }}>
                      {admin.first_name} {admin.last_name}
                    </div>
                    <div style={{ marginTop: 8 }}>
                      <span style={{ padding: '4px 14px', background: 'var(--primary-100)', color: 'var(--primary-700)', borderRadius: 20, fontSize: '0.75rem', fontWeight: 800, textTransform: 'uppercase' }}>
                        Administrator
                      </span>
                    </div>
                  </div>

                  <div style={{ display: 'grid', gridTemplateColumns: '120px 1fr', gap: '12px 16px', fontSize: '.9rem' }}>
                    <span style={{ color: 'var(--gray-500)', fontWeight: 600 }}>Email</span>
                    <span>{admin.email || '—'}</span>
                    <span style={{ color: 'var(--gray-500)', fontWeight: 600 }}>Phone</span>
                    <span>{admin.phone || '—'}</span>
                    <span style={{ color: 'var(--gray-500)', fontWeight: 600 }}>Role</span>
                    <span style={{ textTransform: 'capitalize' }}>{admin.role || 'admin'}</span>
                    <span style={{ color: 'var(--gray-500)', fontWeight: 600 }}>2FA Status</span>
                    <span>
                      <span style={{
                        padding: '2px 10px', borderRadius: 12, fontSize: '.78rem', fontWeight: 700,
                        background: admin.two_factor_enabled ? 'var(--success-50)' : 'var(--gray-100)',
                        color: admin.two_factor_enabled ? 'var(--success-700)' : 'var(--gray-500)'
                      }}>
                        {admin.two_factor_enabled ? 'Enabled' : 'Disabled'}
                      </span>
                    </span>
                  </div>
                </>
              ) : (
                /* ── Edit Mode ── */
                <form onSubmit={handleProfileSubmit}>
                  <div className="form-group">
                    <label className="form-label">First Name *</label>
                    <input className="form-control" name="first_name" value={profileForm.first_name} onChange={handleProfileChange} placeholder="First name" />
                  </div>
                  <div className="form-group">
                    <label className="form-label">Last Name *</label>
                    <input className="form-control" name="last_name" value={profileForm.last_name} onChange={handleProfileChange} placeholder="Last name" />
                  </div>
                  <div className="form-group">
                    <label className="form-label">Email *</label>
                    <input className="form-control" type="email" name="email" value={profileForm.email} onChange={handleProfileChange} placeholder="Email address" />
                  </div>
                  <div className="form-group">
                    <label className="form-label">Phone</label>
                    <input className="form-control" name="phone" value={profileForm.phone} onChange={handleProfileChange} placeholder="Phone number" />
                  </div>

                  {/* 2FA Toggle */}
                  <div className="form-group" style={{
                    display: 'flex', alignItems: 'center', gap: 12, padding: '14px 16px',
                    background: profileForm.two_factor_enabled ? 'var(--success-50)' : 'var(--gray-50)',
                    borderRadius: 10, border: `1px solid ${profileForm.two_factor_enabled ? 'var(--success-200)' : 'var(--gray-200)'}`,
                    transition: 'all 0.2s ease'
                  }}>
                    <input
                      type="checkbox" id="twofa" name="two_factor_enabled"
                      checked={profileForm.two_factor_enabled} onChange={handleProfileChange}
                      style={{ width: 18, height: 18, accentColor: 'var(--primary-600)', cursor: 'pointer' }}
                    />
                    <label htmlFor="twofa" style={{ cursor: 'pointer', fontWeight: 600, fontSize: '.9rem', margin: 0 }}>
                      <FiShield style={{ marginRight: 6, verticalAlign: 'middle' }} />
                      Enable Two-Factor Authentication
                    </label>
                  </div>

                  <div style={{ display: 'flex', gap: 10, marginTop: 16 }}>
                    <button type="submit" className="btn btn-primary" disabled={profileLoading} style={{ flex: 1 }}>
                      <FiSave /> {profileLoading ? 'Saving...' : 'Save Changes'}
                    </button>
                    <button type="button" className="btn btn-secondary" onClick={() => { setEditing(false); setAlert(null) }} style={{ flex: 1 }}>
                      Cancel
                    </button>
                  </div>
                </form>
              )}
            </div>
          </div>
        </div>

        {/* ── RIGHT COLUMN ─────────────────────────────────── */}
        <div>
          {/* Password Change Card */}
          <div className="card" style={{ border: 'none', borderRadius: '16px', boxShadow: '0 4px 20px rgba(0,0,0,0.03)', overflow: 'hidden' }}>
            <div className="card-header">
              <span className="card-title"><FiLock style={{ marginRight: 8 }} />Change Password</span>
            </div>
            <div className="card-body">
              {passwordAlert && <AlertMessage type={passwordAlert.type} message={passwordAlert.message} onClose={() => setPasswordAlert(null)} />}

              <form onSubmit={handlePasswordSubmit}>
                <div className="form-group">
                  <label className="form-label">Current Password *</label>
                  <input className="form-control" type="password" name="current_password" value={passwordForm.current_password} onChange={handlePasswordChange} placeholder="Enter your current password" />
                </div>
                <div className="form-group">
                  <label className="form-label">New Password *</label>
                  <input className="form-control" type="password" name="new_password" value={passwordForm.new_password} onChange={handlePasswordChange} placeholder="Minimum 8 characters" />
                </div>
                <div className="form-group">
                  <label className="form-label">Confirm New Password *</label>
                  <input className="form-control" type="password" name="confirm_password" value={passwordForm.confirm_password} onChange={handlePasswordChange} placeholder="Re-enter new password" />
                </div>
                <button type="submit" className="btn btn-primary" disabled={loading} style={{ width: '100%' }}>
                  <FiCheckCircle /> {loading ? 'Changing...' : 'Update Password'}
                </button>
              </form>

              <div style={{
                display: 'flex', alignItems: 'start', gap: '10px', padding: '12px',
                background: 'var(--info-50)', borderRadius: '8px', border: '1px solid var(--info-200)',
                color: 'var(--info-700)', fontSize: '0.78rem', lineHeight: 1.4, marginTop: 16
              }}>
                <FiShield size={16} style={{ marginTop: '2px', flexShrink: 0 }} />
                <span>
                  <strong>Security:</strong> Your password is encrypted with bcrypt before storage.
                  We recommend using a unique, strong password that you don't use elsewhere.
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
