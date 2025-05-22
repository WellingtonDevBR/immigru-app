// Supabase Edge Function for creating posts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { getSecureCorsHeaders } from "../_shared/cors.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.38.4";
import { PostService } from "./service.ts";
serve(async (req)=>{
  // Handle CORS
  const corsHeaders = getSecureCorsHeaders(req.headers.get('origin'));
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: corsHeaders
    });
  }
  try {
    // Get the request payload
    const payload = await req.json();
    const { userId, content, type } = payload;
    // Validate request
    if (!userId || !type) {
      return new Response(JSON.stringify({
        error: 'Missing required fields: userId or type'
      }), {
        status: 400,
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json'
        }
      });
    }
    // Check for empty content after sanitization
    const sanitizedContent = content ? content.trim() : '';
    if (!sanitizedContent && !payload.mediaUrl && !payload.metadata?.mediaItems?.length) {
      return new Response(JSON.stringify({
        error: 'Post content cannot be empty. Please enter a message or add media.'
      }), {
        status: 400,
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json'
        }
      });
    }
    // Check for potential XSS attempts (simple check for script tags)
    if (sanitizedContent.includes('<script') || sanitizedContent.includes('javascript:')) {
      return new Response(JSON.stringify({
        error: 'Invalid content detected. Please remove any script tags or JavaScript code.'
      }), {
        status: 400,
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json'
        }
      });
    }
    // Initialize Supabase client
    const supabaseClient = createClient(Deno.env.get('SUPABASE_URL') ?? '', Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '');
    const postService = new PostService(supabaseClient);
    const result = await postService.createPost(payload);
    if (!result.success) {
      throw new Error(result.error);
    }
    return new Response(JSON.stringify(result), {
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json'
      },
      status: 200
    });
  } catch (error) {
    return new Response(JSON.stringify({
      success: false,
      error: error.message
    }), {
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json'
      },
      status: 500
    });
  }
});
