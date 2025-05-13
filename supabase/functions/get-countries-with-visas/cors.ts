// Allowed frontend origins (adjust as needed)
export const ALLOWED_ORIGINS = [
  'https://immigru.com',
  'https://www.immigru.com',
  'http://localhost:3000',
  'http://localhost:5173',
  'http://localhost:8080'
];
/**
 * Get CORS headers for a valid request origin
 */ export function getSecureCorsHeaders(requestOrigin) {
  const origin = requestOrigin || '';
  const allowedOrigin = ALLOWED_ORIGINS.includes(origin) ? origin : '';
  return {
    ...allowedOrigin && {
      'Access-Control-Allow-Origin': allowedOrigin
    },
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Max-Age': '86400' // Cache preflight response for 24h
  };
}
/**
 * Check if request is preflight and return early response if so
 */ export function handlePreflight(req) {
  if (req.method === 'OPTIONS') {
    const headers = getSecureCorsHeaders(req.headers.get('origin'));
    return new Response('ok', {
      status: 200,
      headers
    });
  }
  return null;
}
