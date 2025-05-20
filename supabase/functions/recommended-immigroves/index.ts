// File: recommend-immigroves.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { getSecureCorsHeaders, handlePreflight } from './cors.ts';
serve(async (req)=>{
  const preflight = handlePreflight(req);
  if (preflight) return preflight;
  const corsHeaders = getSecureCorsHeaders(req.headers.get('origin'));
  const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
  const supabaseKey = Deno.env.get('SUPABASE_ANON_KEY') ?? '';
  const authHeader = req.headers.get('Authorization');
  if (!authHeader) {
    return new Response(JSON.stringify({
      error: 'Missing Authorization header'
    }), {
      headers: corsHeaders,
      status: 401
    });
  }
  const supabase = createClient(supabaseUrl, supabaseKey, {
    global: {
      headers: {
        Authorization: authHeader
      }
    },
    auth: {
      persistSession: false,
      autoRefreshToken: false,
      detectSessionInUrl: false
    }
  });
  try {
    const { data: { user }, error: userError } = await supabase.auth.getUser();
    if (userError || !user) {
      throw new Error('Invalid user token');
    }
    if (req.method !== 'GET') {
      return new Response(JSON.stringify({
        error: 'Method not allowed'
      }), {
        headers: corsHeaders,
        status: 405
      });
    }
    const url = new URL(req.url);
    const userId = url.searchParams.get('user_id') || user.id;
    const limitCount = parseInt(url.searchParams.get('limit_count') || '6');
    const { data: recommendations, error: recError } = await supabase.rpc('recommend_immigroves_you_may_like', {
      user_id: userId,
      limit_count: limitCount
    });
    if (recError) {
      throw new Error(`Recommendation RPC failed: ${recError.message}`);
    }
    const ids = (recommendations || []).map((r)=>r.ImmiGroveId);
    if (ids.length === 0) {
      return new Response(JSON.stringify({
        data: []
      }), {
        headers: corsHeaders,
        status: 200
      });
    }
    const { data: immigroves, error: fetchError } = await supabase.from('ImmiGrove').select('*').in('Id', ids);
    if (fetchError) {
      throw new Error(`Failed to fetch ImmiGroves: ${fetchError.message}`);
    }
    const transformedImmiGroves = (immigroves || []).map((grove)=>({
        id: grove.Id,
        name: grove.Name,
        description: grove.Description || '',
        icon_url: grove.IconUrl,
        member_count: grove.MemberCount || 0,
        is_joined: false,
        categories: grove.Categories || []
      }));
    return new Response(JSON.stringify({
      data: transformedImmiGroves
    }), {
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json'
      },
      status: 200
    });
  } catch (err) {
    const errorMessage = err instanceof Error ? err.message : 'Unknown error';
    return new Response(JSON.stringify({
      error: errorMessage
    }), {
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json'
      },
      status: 500
    });
  }
});
