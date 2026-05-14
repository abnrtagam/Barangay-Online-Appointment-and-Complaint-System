import React from 'react'
import { FiCheckCircle, FiClock, FiAlertCircle } from 'react-icons/fi'
import { formatDate } from '../utils/date'

export default function StatusTimeline({ history, type = 'complaint' }) {
  if (!history || history.length === 0) {
    return (
      <div style={{ padding: '20px', textAlign: 'center', color: 'var(--gray-400)' }}>
        No status history available
      </div>
    )
  }

  // Define all possible statuses for complaints and appointments
  const statusSequence = {
    complaint: ['Pending', 'Approved', 'Scheduled', 'Resolved', 'Rejected'],
    appointment: ['Pending', 'Approved', 'Completed', 'Rejected', 'Cancelled'],
  }

  const sequence = statusSequence[type] || statusSequence.complaint

  // Build timeline steps from history
  const steps = history.map((h, idx) => ({
    id: h.id,
    status: h.new_status,
    oldStatus: h.old_status,
    timestamp: h.changed_at,
    notes: h.notes,
    isCompleted: true,
  }))

  // Get the current/last status
  const currentStatus = history.length > 0 ? history[history.length - 1].new_status : 'Pending'

  // Determine step status
  const getStepStatus = (stepStatus) => {
    const stepIndex = sequence.indexOf(stepStatus)
    const currentIndex = sequence.indexOf(currentStatus)
    
    if (stepIndex < currentIndex) return 'completed'
    if (stepIndex === currentIndex) return 'current'
    return 'pending'
  }

  const getStepColor = (status) => {
    switch (status) {
      case 'completed':
        return { bg: 'var(--success-100)', border: 'var(--success-500)', text: 'var(--success-700)', icon: 'var(--success-500)' }
      case 'current':
        return { bg: 'var(--primary-100)', border: 'var(--primary-500)', text: 'var(--primary-700)', icon: 'var(--primary-500)' }
      case 'pending':
        return { bg: 'var(--gray-100)', border: 'var(--gray-300)', text: 'var(--gray-500)', icon: 'var(--gray-400)' }
      default:
        return { bg: 'var(--gray-100)', border: 'var(--gray-300)', text: 'var(--gray-500)', icon: 'var(--gray-400)' }
    }
  }

  return (
    <div style={{ padding: '24px 0' }}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: '24px', position: 'relative' }}>
        {/* Vertical line connecting all steps */}
        <div
          style={{
            position: 'absolute',
            left: '19px',
            top: '40px',
            bottom: '0',
            width: '2px',
            background: 'var(--gray-200)',
          }}
        />

        {/* Timeline steps */}
        {sequence.map((statusName, idx) => {
          const stepStatus = getStepStatus(statusName)
          const stepData = history.find(h => h.new_status === statusName)
          const colors = getStepColor(stepStatus)

          return (
            <div key={idx} style={{ display: 'flex', gap: '16px', position: 'relative', zIndex: 1 }}>
              {/* Circle indicator */}
              <div
                style={{
                  width: '40px',
                  height: '40px',
                  minWidth: '40px',
                  borderRadius: '50%',
                  background: colors.bg,
                  border: `2px solid ${colors.border}`,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  color: colors.icon,
                  fontSize: '1.2rem',
                }}
              >
                {stepStatus === 'completed' ? (
                  <FiCheckCircle size={20} />
                ) : stepStatus === 'current' ? (
                  <FiClock size={20} />
                ) : (
                  <FiAlertCircle size={20} style={{ opacity: 0.5 }} />
                )}
              </div>

              {/* Content */}
              <div style={{ flex: 1, paddingTop: '4px' }}>
                <div
                  style={{
                    fontFamily: 'var(--font-heading)',
                    fontWeight: 700,
                    fontSize: '0.95rem',
                    color: colors.text,
                    marginBottom: '4px',
                  }}
                >
                  {statusName}
                </div>

                {stepData ? (
                  <>
                    <div style={{ fontSize: '0.85rem', color: 'var(--gray-600)' }}>
                      {formatDate(stepData.changed_at, {
                        year: 'numeric',
                        month: 'short',
                        day: 'numeric',
                        hour: '2-digit',
                        minute: '2-digit',
                      })}
                    </div>
                    {stepData.notes && (
                      <div
                        style={{
                          marginTop: '8px',
                          padding: '10px 12px',
                          background: 'var(--gray-50)',
                          borderRadius: 'var(--radius-md)',
                          fontSize: '0.85rem',
                          color: 'var(--gray-700)',
                          borderLeft: `3px solid ${colors.border}`,
                        }}
                      >
                        {stepData.notes}
                      </div>
                    )}
                  </>
                ) : (
                  <div style={{ fontSize: '0.85rem', color: 'var(--gray-400)' }}>
                    Not yet reached
                  </div>
                )}
              </div>
            </div>
          )
        })}
      </div>
    </div>
  )
}
