// CORS headers for Edge Functions with enhanced security
export const ALLOWED_ORIGINS = [
  'https://immigru.com',
  'https://www.immigru.com',
  'http://localhost:3000',
  'http://localhost:5173',
  'http://localhost:8080'
];
/**
 * Get secure CORS headers based on the request origin
 * @param requestOrigin The origin from the request headers
 * @returns CORS headers with the appropriate Access-Control-Allow-Origin
 */ export function getSecureCorsHeaders(requestOrigin) {
  const origin = requestOrigin || '';
  const allowedOrigin = ALLOWED_ORIGINS.includes(origin) ? origin : ALLOWED_ORIGINS[0];
  return {
    'Access-Control-Allow-Origin': allowedOrigin,
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS'
  };
}
