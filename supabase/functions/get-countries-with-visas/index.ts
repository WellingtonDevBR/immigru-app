import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { getSecureCorsHeaders, handlePreflight } from './cors.ts';
serve(async (req)=>{
  const preflight = handlePreflight(req);
  if (preflight) return preflight;
  const corsHeaders = getSecureCorsHeaders(req.headers.get('origin'));
  const url = new URL(req.url, 'http://localhost'); // ✅ required for proper param parsing
  const countryIdRaw = url.searchParams.get('countryId');
  try {
    const countryId = parseInt(countryIdRaw || '', 10);
    // Validate the countryId
    if (!countryId || isNaN(countryId)) {
      return new Response(JSON.stringify({
        data: [],
        error: 'Invalid or missing countryId.',
        debug: {
          received: countryIdRaw
        }
      }), {
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json'
        },
        status: 400
      });
    }
    const supabaseClient = createClient(Deno.env.get('SUPABASE_URL') ?? '', Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '');
    const { data, error } = await supabaseClient.from('Visa').select(`
        Id,
        CountryId,
        VisaName,
        VisaCode,
        Type,
        PathwayToPR,
        AllowsWork,
        Description,
        ExternalLink,
        IsPublic,
        UpdatedAt,
        CreatedAt
      `).eq('CountryId', countryId).eq('IsPublic', true).order('UpdatedAt', {
      ascending: false
    });
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
