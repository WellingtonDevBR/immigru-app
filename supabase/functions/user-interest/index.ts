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
    const {
      data: { user },
      error: userError,
    } = await supabase.auth.getUser();

    if (userError || !user) {
      throw new Error('Invalid user token');
    }

    const method = req.method;

    if (method === 'GET') {
      
      
      try {
        // For GET requests, we don't need to parse the request body
        
        
        const { data: interests, error } = await supabase
          .from('UserInterest')
          .select('InterestId, Interest(Id, Name, Category)')
          .eq('UserId', user.id);

        if (error) {
          console.error('Database error:', error);
          throw new Error(error.message);
        }

        
        
        // Ensure interests is always an array, even if null
        const safeInterests = interests || [];
        
        // Log each interest for debugging
        safeInterests.forEach((interest, index) => {
          
        });
        
        const response = JSON.stringify({ data: safeInterests });
        
        
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
      
      
      try {
        const body = await req.json();
        const interestIds: number[] = body.interestIds;
        
        

        if (!Array.isArray(interestIds)) {
          console.error('Invalid interestIds array:', interestIds);
          return new Response(JSON.stringify({ error: 'Invalid interestIds array' }), {
            headers: corsHeaders,
            status: 400,
          });
        }
        
        

        // Delete existing interests
        
        const { error: deleteError } = await supabase
          .from('UserInterest')
          .delete()
          .eq('UserId', user.id);

        if (deleteError) {
          console.error('Error deleting existing interests:', deleteError);
          throw new Error(`Failed to delete existing interests: ${deleteError.message}`);
        }
        
        

        // Only insert new interests if there are any to insert
        if (interestIds.length > 0) {
          // Insert new interests
          
          const inserts = interestIds.map((id) => ({
            UserId: user.id,
            InterestId: id,
          }));

          const { error: insertError } = await supabase
            .from('UserInterest')
            .insert(inserts);

          if (insertError) {
            console.error('Error inserting new interests:', insertError);
            throw new Error(`Failed to insert new interests: ${insertError.message}`);
          }
          
          
        } else {
          
        }

        return new Response(JSON.stringify({ success: true }), {
          headers: {
            ...corsHeaders,
            'Content-Type': 'application/json',
          },
          status: 200,
        });
      } catch (error) {
        console.error('Error processing POST request:', error);
        return new Response(JSON.stringify({ error: error.message }), {
          headers: corsHeaders,
          status: 500,
        });
      }
    }

    return new Response(JSON.stringify({ error: 'Method not allowed' }), {
      headers: corsHeaders,
      status: 405,
    });

  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), {
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json',
      },
      status: 500,
    });
  }
});
