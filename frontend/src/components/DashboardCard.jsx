import React from 'react'

const COLOR_MAP = {
  blue:    { 
    primary: '#2563eb', 
    light: '#dbeafe', 
    dark: '#1e40af', 
    gradient: 'linear-gradient(135deg, #3b82f6 0%, #2563eb 100%)',
    shadow: 'rgba(37, 99, 235, 0.2)'
  },
  info:    { 
    primary: '#0891b2', 
    light: '#cffafe', 
    dark: '#0e7490',
    gradient: 'linear-gradient(135deg, #06b6d4 0%, #0891b2 100%)',
    shadow: 'rgba(8, 145, 178, 0.2)'
  },
  success: { 
    primary: '#10b981', 
    light: '#d1fae5', 
    dark: '#047857',
    gradient: 'linear-gradient(135deg, #34d399 0%, #10b981 100%)',
    shadow: 'rgba(16, 185, 129, 0.2)'
  },
  green:   { 
    primary: '#10b981', 
    light: '#d1fae5', 
    dark: '#047857',
    gradient: 'linear-gradient(135deg, #34d399 0%, #10b981 100%)',
    shadow: 'rgba(16, 185, 129, 0.2)'
  },
  warning: { 
    primary: '#f59e0b', 
    light: '#fef3c7', 
    dark: '#b45309',
    gradient: 'linear-gradient(135deg, #fbbf24 0%, #f59e0b 100%)',
    shadow: 'rgba(245, 158, 11, 0.2)'
  },
  danger:  { 
    primary: '#ef4444', 
    light: '#fee2e2', 
    dark: '#b91c1c',
    gradient: 'linear-gradient(135deg, #f87171 0%, #ef4444 100%)',
    shadow: 'rgba(239, 68, 68, 0.2)'
  },
  red:     { 
    primary: '#ef4444', 
    light: '#fee2e2', 
    dark: '#b91c1c',
    gradient: 'linear-gradient(135deg, #f87171 0%, #ef4444 100%)',
    shadow: 'rgba(239, 68, 68, 0.2)'
  },
}

export function DashboardCard({ title, value, icon, color = 'blue', sub, trend }) {
  const palette = COLOR_MAP[color] || COLOR_MAP.blue
  const [hovered, setHovered] = React.useState(false)

  return (
    <article
      style={{
        background: 'rgba(255, 255, 255, 0.95)',
        backdropFilter: 'blur(10px)',
        borderRadius: '24px',
        padding: '24px',
        display: 'flex',
        flexDirection: 'column',
        gap: '20px',
        boxShadow: hovered 
          ? `0 20px 40px ${palette.shadow}, 0 10px 20px rgba(0,0,0,0.05)` 
          : '0 10px 30px rgba(0,0,0,0.03)',
        border: '1px solid rgba(255, 255, 255, 0.3)',
        transform: hovered ? 'translateY(-8px)' : 'translateY(0)',
        transition: 'all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275)',
        cursor: 'default',
        position: 'relative',
        overflow: 'hidden',
      }}
      onMouseEnter={() => setHovered(true)}
      onMouseLeave={() => setHovered(false)}
    >
      {/* Decorative Blob */}
      <div style={{
        position: 'absolute',
        top: '-30px',
        right: '-30px',
        width: '120px',
        height: '120px',
        borderRadius: '50%',
        background: palette.gradient,
        opacity: hovered ? 0.08 : 0.04,
        transition: 'all 0.4s ease',
        pointerEvents: 'none',
      }} />

      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', zIndex: 1 }}>
        <div style={{
          width: '52px',
          height: '52px',
          borderRadius: '16px',
          background: palette.gradient,
          color: '#ffffff',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          fontSize: '1.4rem',
          boxShadow: `0 8px 16px ${palette.shadow}`,
          transition: 'all 0.4s ease',
          transform: hovered ? 'rotate(5deg) scale(1.1)' : 'none',
        }}>
          {icon}
        </div>
        
        {trend && (
          <div style={{
            fontSize: '0.75rem',
            fontWeight: 700,
            color: trend.startsWith('+') ? '#10b981' : '#ef4444',
            background: trend.startsWith('+') ? 'rgba(16, 185, 129, 0.1)' : 'rgba(239, 68, 68, 0.1)',
            padding: '4px 10px',
            borderRadius: '10px',
            display: 'flex',
            alignItems: 'center',
            gap: '4px'
          }}>
            {trend}
          </div>
        )}
      </div>

      <div style={{ zIndex: 1 }}>
        <p style={{
          fontSize: '0.85rem',
          fontWeight: 700,
          color: '#64748b',
          margin: '0 0 4px 0',
          fontFamily: 'var(--font-heading)'
        }}>
          {title}
        </p>
        <div style={{
          fontSize: '2.4rem',
          fontWeight: 900,
          color: '#0f172a',
          lineHeight: 1,
          letterSpacing: '-0.04em',
          display: 'flex',
          alignItems: 'baseline',
          gap: '8px'
        }}>
          {value}
          <span style={{ fontSize: '1rem', fontWeight: 600, color: '#94a3b8' }}>Units</span>
        </div>
        {sub && (
          <div style={{
            fontSize: '0.85rem',
            color: '#94a3b8',
            marginTop: '12px',
            fontWeight: 500,
            display: 'flex',
            alignItems: 'center',
            gap: '6px'
          }}>
            <div style={{ width: '6px', height: '6px', borderRadius: '50%', background: palette.primary }} />
            {sub}
          </div>
        )}
      </div>
    </article>
  )
}

export function StatusBadge({ status }) {
  const normalized = typeof status === 'string' ? status : String(status || '')
  const slug = normalized.toLowerCase().replace(/\s+/g, '-')

  const badgeColors = {
    pending:   { bg: '#fff7ed', color: '#c2410c', border: '#ffedd5', dot: '#f97316' },
    approved:  { bg: '#f0fdf4', color: '#15803d', border: '#dcfce7', dot: '#22c55e' },
    rejected:  { bg: '#fef2f2', color: '#b91c1c', border: '#fee2e2', dot: '#ef4444' },
    resolved:  { bg: '#f0f9ff', color: '#0369a1', border: '#e0f2fe', dot: '#0ea5e9' },
    scheduled: { bg: '#f5f3ff', color: '#6d28d9', border: '#ede9fe', dot: '#8b5cf6' },
    completed: { bg: '#f0fdf4', color: '#15803d', border: '#dcfce7', dot: '#22c55e' },
  }

  const style = badgeColors[slug] || { bg: '#f8fafc', color: '#475569', border: '#f1f5f9', dot: '#94a3b8' }

  return (
    <span style={{
      background: style.bg,
      color: style.color,
      border: `1px solid ${style.border}`,
      borderRadius: '12px',
      padding: '4px 12px',
      fontSize: '0.75rem',
      fontWeight: 700,
      display: 'inline-flex',
      alignItems: 'center',
      gap: '6px',
      textTransform: 'capitalize'
    }}>
      <div style={{ width: '6px', height: '6px', borderRadius: '50%', background: style.dot }} />
      {normalized}
    </span>
  )
}

export function AlertMessage({ type = 'info', title, message, onClose }) {
  if (!message) return null
  const cfg = {
    success: { bg: '#f0fdf4', border: '#dcfce7', color: '#15803d' },
    error:   { bg: '#fef2f2', border: '#fee2e2', color: '#b91c1c' },
    warning: { bg: '#fff7ed', border: '#ffedd5', color: '#c2410c' },
    info:    { bg: '#f0f9ff', border: '#e0f2fe', color: '#0369a1' },
  }[type] || { bg: '#f8fafc', border: '#f1f5f9', color: '#475569' }

  return (
    <div style={{
      background: cfg.bg,
      border: `1px solid ${cfg.border}`,
      color: cfg.color,
      borderRadius: '16px',
      padding: '16px 20px',
      display: 'grid',
      gridTemplateColumns: '1fr auto',
      gap: 12,
      alignItems: 'center',
      marginBottom: 20,
      boxShadow: '0 4px 12px rgba(0,0,0,0.02)'
    }} role="alert">
      <div style={{ display: 'flex', flexDirection: 'column', gap: '2px' }}>
        {title && <div style={{ fontWeight: 800, fontSize: '0.9rem' }}>{title}</div>}
        <div style={{ fontWeight: 500, fontSize: '0.85rem', opacity: 0.9 }}>{message}</div>
      </div>
      {onClose && (
        <button onClick={onClose} style={{
          border: 'none', background: 'rgba(0,0,0,0.05)', cursor: 'pointer',
          color: cfg.color, width: '28px', height: '28px', borderRadius: '8px',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontWeight: 800, transition: 'all 0.2s'
        }}>×</button>
      )}
    </div>
  )
}

export function Modal({ open, onClose, title, children, footer }) {
  if (!open) return null

  return (
    <div style={{
      position: 'fixed', top: 0, left: 0, right: 0, bottom: 0,
      background: 'rgba(15, 23, 42, 0.6)', backdropFilter: 'blur(8px)',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      zIndex: 1000, padding: '20px'
    }} onClick={onClose}>
      <div style={{
        background: '#ffffff', borderRadius: '28px', width: '100%', maxWidth: '600px',
        maxHeight: '90vh', display: 'flex', flexDirection: 'column',
        boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.25)',
        overflow: 'hidden', animation: 'modalSlideUp 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275)'
      }} onClick={e => e.stopPropagation()}>
        <div style={{
          padding: '24px 32px', borderBottom: '1px solid #f1f5f9',
          display: 'flex', alignItems: 'center', justifyContent: 'space-between',
          flexShrink: 0
        }}>
          <h2 style={{ fontSize: '1.25rem', fontWeight: 800, color: '#0f172a', margin: 0 }}>{title}</h2>
          <button style={{
            border: 'none', background: '#f1f5f9', cursor: 'pointer',
            width: '32px', height: '32px', borderRadius: '10px',
            fontSize: '1.2rem', color: '#64748b', display: 'flex',
            alignItems: 'center', justifyContent: 'center'
          }} onClick={onClose}>×</button>
        </div>
        <div style={{ padding: '32px', overflowY: 'auto', flex: 1 }}>{children}</div>
        {footer && (
          <div style={{
            padding: '20px 32px', background: '#f8fafc',
            borderTop: '1px solid #f1f5f9', display: 'flex',
            justifyContent: 'flex-end', gap: 12
          }}>
            {footer}
          </div>
        )}
      </div>
    </div>
  )
}
