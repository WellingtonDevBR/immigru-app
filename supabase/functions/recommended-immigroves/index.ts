// File: recommend-immigroves.ts

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { getSecureCorsHeaders, handlePreflight } from './cors.ts';

serve(async (req) => {
  const preflight = handlePreflight(req);
  if (preflight) return preflight;

  const corsHeaders = getSecureCorsHeaders(req.headers.get('origin'));

  const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
  const supabaseKey = Deno.env.get('SUPABASE_ANON_KEY') ?? '';
  const authHeader = req.headers.get('Authorization');

  if (!authHeader) {
    return new Response(JSON.stringify({ error: 'Missing Authorization header' }), {
      headers: corsHeaders,
      status: 401,
    });
  }

  const supabase = createClient(supabaseUrl, supabaseKey, {
    global: {
      headers: {
        Authorization: authHeader,
      },
    },
  });

  try {
    const { data: { user }, error: userError } = await supabase.auth.getUser();

    if (userError || !user) {
      throw new Error('Invalid user token');
    }

    if (req.method !== 'POST') {
      return new Response(JSON.stringify({ error: 'Method not allowed' }), {
        headers: corsHeaders,
        status: 405,
      });
    }

    const bodyText = await req.text();
    if (!bodyText?.trim()) {
      return new Response(JSON.stringify({ error: 'Empty request body' }), {
        headers: corsHeaders,
        status: 400,
      });
    }

    let body;
    try {
      body = JSON.parse(bodyText);
    } catch (e) {
      return new Response(JSON.stringify({ error: 'Invalid JSON' }), {
        headers: corsHeaders,
        status: 400,
      });
    }

    const userId = body.user_id || user.id;
    const limitCount = body.limit_count || 6;

    const { data: recommendations, error: recError } = await supabase
      .rpc('recommend_immigroves_you_may_like', {
        user_id: userId,
        limit_count: limitCount
      });

    if (recError) {
      throw new Error(`Recommendation RPC failed: ${recError.message}`);
    }

    const ids = (recommendations || []).map((r: any) => r.ImmiGroveId);

    if (ids.length === 0) {
      return new Response(JSON.stringify({ data: [] }), {
        headers: corsHeaders,
        status: 200,
      });
    }

    const { data: immigroves, error: fetchError } = await supabase
      .from('ImmiGrove')
      .select('*')
      .in('Id', ids);

    if (fetchError) {
      throw new Error(`Failed to fetch ImmiGroves: ${fetchError.message}`);
    }

    return new Response(JSON.stringify({ data: immigroves }), {
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json',
      },
      status: 200,
    });

  } catch (err) {
    const errorMessage = err instanceof Error ? err.message : 'Unknown error';

    return new Response(JSON.stringify({ error: errorMessage }), {
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json',
      },
      status: 500,
    });
  }
});
