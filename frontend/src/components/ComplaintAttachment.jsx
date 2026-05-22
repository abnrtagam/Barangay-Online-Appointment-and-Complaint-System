import React from 'react'
import { FiFileText, FiImage, FiExternalLink } from 'react-icons/fi'
import { uploadUrl } from '../utils/uploads'

const IMAGE_EXT = /\.(jpe?g|png|gif|webp)$/i

export function isImageAttachment(filename) {
  return filename && IMAGE_EXT.test(filename)
}

export default function ComplaintAttachment({ attachmentPath, compact = false }) {
  if (!attachmentPath) {
    return (
      <div style={{
        padding: compact ? '12px 14px' : '16px 18px',
        borderRadius: 'var(--radius-md)',
        background: 'var(--gray-50)',
        border: '1px dashed var(--gray-200)',
        color: 'var(--gray-500)',
        fontSize: '.85rem',
      }}>
        No supporting attachment was submitted with this complaint.
      </div>
    )
  }

  const url = uploadUrl(attachmentPath)
  const isImage = isImageAttachment(attachmentPath)

  return (
    <div style={{
      marginTop: compact ? 0 : 4,
      padding: compact ? '12px 14px' : '16px 18px',
      borderRadius: 'var(--radius-md)',
      background: 'var(--gray-50)',
      border: '1px solid var(--gray-200)',
    }}>
      <div style={{
        display: 'flex',
        alignItems: 'center',
        gap: 8,
        marginBottom: isImage ? 12 : 10,
        fontFamily: 'var(--font-heading)',
        fontWeight: 700,
        fontSize: '.85rem',
        color: 'var(--primary-700)',
      }}>
        {isImage ? <FiImage size={16} /> : <FiFileText size={16} />}
        Supporting Attachment
      </div>

      <div style={{
        display: 'grid',
        gridTemplateColumns: isImage ? '1fr minmax(140px, 200px)' : '1fr',
        gap: 16,
        alignItems: 'start',
      }}>
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 10, alignItems: 'center' }}>
          <a
            href={url}
            target="_blank"
            rel="noreferrer"
            className="btn btn-primary btn-sm"
            style={{ display: 'inline-flex', alignItems: 'center', gap: 6 }}
          >
            <FiExternalLink size={14} />
            View Attachment
          </a>
          <span style={{ fontSize: '.78rem', color: 'var(--gray-500)', wordBreak: 'break-all' }}>
            {attachmentPath}
          </span>
        </div>

        {isImage && (
          <a href={url} target="_blank" rel="noreferrer" style={{ display: 'block' }}>
            <img
              src={url}
              alt="Complaint attachment"
              style={{
                width: '100%',
                maxHeight: 160,
                objectFit: 'cover',
                borderRadius: 8,
                border: '1px solid var(--gray-200)',
                boxShadow: '0 2px 8px rgba(0,0,0,0.08)',
              }}
              onError={(e) => { e.target.style.display = 'none' }}
            />
          </a>
        )}
      </div>
    </div>
  )
}
