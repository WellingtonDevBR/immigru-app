// Allowed frontend origins (adjust as needed)
export const ALLOWED_ORIGINS = [
  'https://immigru.com',
  'https://www.immigru.com',
  'http://localhost:3000',
  'http://localhost:5173',
  'http://localhost:8080',
  'http://localhost:9999'
];

// Default CORS headers for all responses
export const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Max-Age': '86400' // Cache preflight response for 24h
};

/**
 * Get CORS headers for a valid request origin
 */ 
export function getSecureCorsHeaders(requestOrigin: string | null) {
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
 * Handle CORS preflight requests
 */
export function handlePreflight(req: Request) {
  // Check if this is a preflight request
  if (req.method === 'OPTIONS') {
    // Return a response with CORS headers
    return new Response('ok', { headers: corsHeaders });
  }
  return null;
}
