/** Build a URL for files served from backend /uploads (works in dev via Vite proxy and in production on same host). */
export function uploadUrl(filename) {
  if (!filename) return ''
  const name = String(filename).replace(/^\/+/, '')
  return `/uploads/${name}`
}
