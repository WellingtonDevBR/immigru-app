import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { getSecureCorsHeaders, handlePreflight } from './cors.ts';
serve(async (req)=>{
  const preflight = handlePreflight(req);
  if (preflight) return preflight;
  const corsHeaders = getSecureCorsHeaders(req.headers.get('origin'));
  const url = new URL(req.url);
  const name = url.searchParams.get('name')?.trim();
  const category = url.searchParams.get('category')?.trim();
  try {
    const supabaseClient = createClient(Deno.env.get('SUPABASE_URL') ?? '', Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '');
    let query = supabaseClient.from('Interest').select(`
      Id,
      Name,
      Category,
      IsActive,
      UpdatedAt,
      CreatedAt
    `).eq('IsActive', true).order('Name', {
      ascending: true
    });
    if (name) {
      query = query.ilike('Name', `%${name}%`);
    }
    if (category) {
      query = query.ilike('Category', `%${category}%`);
    }
    const { data, error } = await query;
    if (error) throw new Error(error.message);
    return new Response(JSON.stringify({
      data,
      error: null
    }), {
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json'
      },
      status: 200
    });
  } catch (err) {
    return new Response(JSON.stringify({
      data: null,
      error: err.message
    }), {
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json'
      },
      status: 500
    });
  }
});
