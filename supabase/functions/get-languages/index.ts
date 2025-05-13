import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { getSecureCorsHeaders, handlePreflight } from './cors.ts';

serve(async (req) => {
  // Handle CORS preflight request
  const preflight = handlePreflight(req);
  if (preflight) return preflight;
  
  // Get CORS headers
  const corsHeaders = getSecureCorsHeaders(req.headers.get('origin'));
  
  try {
    // Create Supabase client
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );
    
    // Parse search parameters
    const url = new URL(req.url);
    const searchQuery = url.searchParams.get('search')?.trim();
    
    // Query the Language table
    let query = supabaseClient
      .from('Language')
      .select(`
        Id,
        Code,
        Name,
        NativeName,
        Direction,
        IsActive
      `)
      .eq('IsActive', true)
      .order('Name', { ascending: true });
    
    // Apply search filter if provided
    if (searchQuery) {
      query = query.or(`Name.ilike.%${searchQuery}%,NativeName.ilike.%${searchQuery}%`);
    }
    
    // Execute the query
    const { data, error } = await query;
    
    if (error) {
      console.error('Error fetching languages:', error.message);
      throw new Error(error.message);
    }
    
    
    
    // Return the language data
    return new Response(
      JSON.stringify({
        data,
        error: null
      }),
      {
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json'
        },
        status: 200
      }
    );
  } catch (err) {
    console.error('Error in get-languages function:', err.message);
    
    return new Response(
      JSON.stringify({
        data: null,
        error: err.message
      }),
      {
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json'
        },
        status: 500
      }
    );
  }
});
