export function formatDate(dateString, options = {}) {
  if (!dateString) return 'N/A'

  const date = new Date(dateString)
  if (Number.isNaN(date.getTime())) return 'N/A'

  return date.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    ...options,
  })
}
