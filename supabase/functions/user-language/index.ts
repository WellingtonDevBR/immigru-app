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

  const supabaseClient = createClient(supabaseUrl, supabaseKey, {
    global: {
      headers: {
        Authorization: authHeader,
      },
    },
  });

  try {
    
    
    const {
      data: { user },
      error: userError,
    } = await supabaseClient.auth.getUser();

    if (userError || !user) {
      console.error('Invalid user token:', userError);
      throw new Error('Invalid user token');
    }

    
    const method = req.method;

    if (method === 'GET') {
      
      
      try {
        // For GET requests, we don't need to parse the request body
        
        
        const { data: languages, error } = await supabaseClient
          .from('UserLanguage')
          .select('LanguageId, Language(Id, Name, NativeName, Code)')
          .eq('UserId', user.id);

        if (error) {
          console.error('Database error:', error);
          throw new Error(error.message);
        }

        
        
        // Ensure languages is always an array, even if null
        const safeLanguages = languages || [];
        
        // Log each language for debugging
        safeLanguages.forEach((lang, index) => {
          
        });
        
        const response = JSON.stringify({ data: safeLanguages });
        
        
        return new Response(response, {
          headers: {
            ...corsHeaders,
            'Content-Type': 'application/json',
          },
          status: 200,
        });
      } catch (dbError) {
        console.error('Error in database query:', dbError);
        throw dbError;
      }
    }

    if (method === 'POST') {
      
      
      let body;
      try {
        // Safely parse the request body
        const bodyText = await req.text();
        
        
        if (!bodyText || bodyText.trim() === '') {
          console.error('Empty request body');
          return new Response(JSON.stringify({ error: 'Empty request body' }), {
            headers: corsHeaders,
            status: 400,
          });
        }
        
        body = JSON.parse(bodyText);
        
      } catch (parseError) {
        console.error('Error parsing request body:', parseError);
        return new Response(JSON.stringify({ error: 'Invalid JSON in request body' }), {
          headers: corsHeaders,
          status: 400,
        });
      }
      
      const languageIds = body.languageIds;
      

      if (!Array.isArray(languageIds)) {
        console.error('languageIds is not an array:', languageIds);
        return new Response(JSON.stringify({ error: 'Invalid languageIds array' }), {
          headers: corsHeaders,
          status: 400,
        });
      }

      const upsertData = languageIds.map((langId) => ({
        UserId: user.id,
        LanguageId: langId,
      }));

      const { error } = await supabaseClient
        .from('UserLanguage')
        .upsert(upsertData, { onConflict: 'UserId,LanguageId' });

      if (error) throw new Error(error.message);

      return new Response(JSON.stringify({ success: true }), {
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json',
        },
        status: 200,
      });
    }

    return new Response(JSON.stringify({ error: 'Method not allowed' }), {
      headers: corsHeaders,
      status: 405,
    });
  } catch (err) {
    console.error('Error in user-language function:', err);
    
    // Create a safe error response
    let errorMessage = 'Unknown error';
    
    if (err instanceof Error) {
      errorMessage = err.message;
    } else if (typeof err === 'string') {
      errorMessage = err;
    } else if (err && typeof err === 'object') {
      errorMessage = JSON.stringify(err);
    }
    
    
    
    return new Response(JSON.stringify({ error: errorMessage }), {
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json',
      },
      status: 500,
    });
  }
});
