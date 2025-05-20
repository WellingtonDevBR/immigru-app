import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { getSecureCorsHeaders, handlePreflight } from "./cors.ts";

serve(async (req) => {
  const preflight = handlePreflight(req);
  if (preflight) return preflight;

  const corsHeaders = getSecureCorsHeaders(req.headers.get("origin"));

  // Access environment variables using Deno's API
  const supabaseUrl = Deno.env.get("SUPABASE_URL") || "";
  const supabaseKey = Deno.env.get("SUPABASE_ANON_KEY") || "";
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || "";
  const authHeader = req.headers.get("Authorization");

  if (!authHeader) {
    return new Response(
      JSON.stringify({ error: "Missing Authorization header" }),
      {
        headers: corsHeaders,
        status: 401,
      },
    );
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
      throw new Error("Invalid user token");
    }

    const method = req.method;

    if (method === "GET") {
      try {
        // For GET requests, we don't need to parse the request body

        const { data: languages, error } = await supabaseClient
          .from("UserLanguage")
          .select("LanguageId, Language(Id, Name, NativeName, Code)")
          .eq("UserId", user.id);

        if (error) {
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
            "Content-Type": "application/json",
          },
          status: 200,
        });
      } catch (dbError) {
        throw dbError;
      }
    }

    if (method === "POST") {
      let body;
      // Log with timestamp for better debugging
      console.log(`[${new Date().toISOString()}] Processing request for user: ${user.id}`);
      try {
        // Safely parse the request body
        const bodyText = await req.text();

        if (!bodyText || bodyText.trim() === "") {
          return new Response(JSON.stringify({ error: "Empty request body" }), {
            headers: corsHeaders,
            status: 400,
          });
        }

        body = JSON.parse(bodyText);
        
        // Log the request body for debugging
        console.log(`[${new Date().toISOString()}] Request body: ${bodyText}`);
      } catch (parseError) {
        console.log(`[${new Date().toISOString()}] Error parsing request body: ${parseError}`);
        return new Response(
          JSON.stringify({ error: "Invalid JSON in request body" }),
          {
            headers: corsHeaders,
            status: 400,
          },
        );
      }

      const languageIds = body.languageIds;

      if (!Array.isArray(languageIds)) {
        return new Response(
          JSON.stringify({ error: "Invalid languageIds array" }),
          {
            headers: corsHeaders,
            status: 400,
          },
        );
      }

      const upsertData = languageIds.map((langId) => ({
        UserId: user.id,
        LanguageId: langId,
      }));

      console.log(`[${new Date().toISOString()}] Data to upsert: ${JSON.stringify(upsertData)}`);
      
      // Create admin client with service role key for all database operations
      console.log(`[${new Date().toISOString()}] Creating admin client with service role key`);
      console.log(`[${new Date().toISOString()}] Service role key available: ${!!serviceRoleKey}`);
      console.log(`[${new Date().toISOString()}] Service role key length: ${serviceRoleKey.length}`);
      console.log(`[${new Date().toISOString()}] Supabase URL: ${supabaseUrl}`);
      
      // Log the request details for debugging
      console.log(`[${new Date().toISOString()}] Request method: ${req.method}`);
      console.log(`[${new Date().toISOString()}] Request URL: ${req.url}`);
      console.log(`[${new Date().toISOString()}] Request headers: ${JSON.stringify(Object.fromEntries(req.headers))}`);
      
      // Create admin client with service role key
      if (!serviceRoleKey || serviceRoleKey.length < 10) {
        console.log(`[${new Date().toISOString()}] ERROR: Invalid service role key`);
        return new Response(
          JSON.stringify({ error: "Server configuration error: Invalid service role key" }),
          {
            headers: corsHeaders,
            status: 500,
          }
        );
      }
      
      const adminClient = createClient(supabaseUrl, serviceRoleKey);
      
      // Verify admin client was created successfully
      try {
        // Test the admin client with a simple query
        const { data: testData, error: testError } = await adminClient
          .from("Language")
          .select("count")
          .limit(1);
          
        if (testError) {
          console.log(`[${new Date().toISOString()}] Admin client test failed: ${JSON.stringify(testError)}`);
          return new Response(
            JSON.stringify({ error: "Failed to initialize admin client", details: testError }),
            {
              headers: corsHeaders,
              status: 500,
            }
          );
        }
        
        console.log(`[${new Date().toISOString()}] Admin client test successful`);
      } catch (testError) {
        console.log(`[${new Date().toISOString()}] Exception testing admin client: ${testError}`);
        return new Response(
          JSON.stringify({ error: "Exception testing admin client", details: String(testError) }),
          {
            headers: corsHeaders,
            status: 500,
          }
        );
      }
      
      // First, get existing user languages using admin client
      console.log(`[${new Date().toISOString()}] Fetching existing languages for user: ${user.id}`);
      const { data: existingLanguages, error: fetchError } = await adminClient
        .from("UserLanguage")
        .select("LanguageId")
        .eq("UserId", user.id);
        
      if (fetchError) {
        console.log(`[${new Date().toISOString()}] Error fetching existing languages: ${JSON.stringify(fetchError)}`);
        throw new Error(fetchError.message);
      }
      
      console.log(`[${new Date().toISOString()}] Existing languages: ${JSON.stringify(existingLanguages)}`);
      
      // Get the existing language IDs
      const existingIds = existingLanguages?.map(lang => lang.LanguageId) || [];
      console.log(`[${new Date().toISOString()}] Existing language IDs: ${JSON.stringify(existingIds)}`);
      
      // Find IDs to delete (existing but not in new selection)
      const idsToDelete = existingIds.filter(id => !languageIds.includes(id));
      console.log(`[${new Date().toISOString()}] Language IDs to delete: ${JSON.stringify(idsToDelete)}`);
      
      // Find IDs to insert (in new selection but not existing)
      const idsToInsert = languageIds.filter(id => !existingIds.includes(id));
      console.log(`[${new Date().toISOString()}] Language IDs to insert: ${JSON.stringify(idsToInsert)}`);
      
      // Log the current user's authentication status
      const { data: authData, error: authError } = await supabaseClient.auth.getSession();
      console.log(`[${new Date().toISOString()}] Auth session valid: ${!!authData.session}`);
      if (authError) {
        console.log(`[${new Date().toISOString()}] Auth error: ${JSON.stringify(authError)}`);
      }
      
      // Delete languages that are no longer selected using admin client
      if (idsToDelete.length > 0) {
        console.log(`[${new Date().toISOString()}] Deleting languages for user: ${user.id}, languages: ${JSON.stringify(idsToDelete)}`);
        
        const { error: deleteError } = await adminClient
          .from("UserLanguage")
          .delete()
          .eq("UserId", user.id)
          .in("LanguageId", idsToDelete);
          
        if (deleteError) {
          console.log(`[${new Date().toISOString()}] Error deleting languages: ${JSON.stringify(deleteError)}`);
          throw new Error(deleteError.message);
        }
        
        console.log(`[${new Date().toISOString()}] Successfully deleted languages`);
      } else {
        console.log(`[${new Date().toISOString()}] No languages to delete`);
      }
      
      // Insert newly selected languages using the admin client
      if (idsToInsert.length > 0) {
        const insertData = idsToInsert.map(langId => ({
          UserId: user.id,
          LanguageId: langId,
        }));
        
        console.log(`[${new Date().toISOString()}] Inserting new languages: ${JSON.stringify(insertData)}`);
        
        try {
          // Try with insert first
          console.log(`[${new Date().toISOString()}] Attempting direct insert with admin client`);
          const { data: insertData1, error: insertError1 } = await adminClient
            .from("UserLanguage")
            .insert(insertData)
            .select();
            
          if (insertError1) {
            console.log(`[${new Date().toISOString()}] Insert error: ${JSON.stringify(insertError1)}`);
            
            // If insert fails, try upsert
            console.log(`[${new Date().toISOString()}] Insert failed, trying upsert with admin client`);
            const { data: insertData2, error: insertError2 } = await adminClient
              .from("UserLanguage")
              .upsert(insertData, { onConflict: "UserId,LanguageId" })
              .select();
              
            if (insertError2) {
              console.log(`[${new Date().toISOString()}] Upsert error: ${JSON.stringify(insertError2)}`);
              throw new Error(insertError2.message);
            }
            
            console.log(`[${new Date().toISOString()}] Successfully upserted languages with admin client: ${JSON.stringify(insertData2)}`);
          } else {
            console.log(`[${new Date().toISOString()}] Successfully inserted languages with admin client: ${JSON.stringify(insertData1)}`);
          }
        } catch (dbError) {
          console.log(`[${new Date().toISOString()}] Database operation failed: ${dbError}`);
          throw new Error(`Database operation failed: ${dbError}`);
        }
        
        console.log(`[${new Date().toISOString()}] Successfully inserted/upserted languages`);
      } else {
        console.log(`[${new Date().toISOString()}] No new languages to insert`);
      }
      
      // No need to check for error here as we've already handled errors above

      return new Response(JSON.stringify({ success: true }), {
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
        status: 200,
      });
    }

    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      headers: corsHeaders,
      status: 405,
    });
  } catch (err) {
    // Create a safe error response
    let errorMessage = "Unknown error";

    if (err instanceof Error) {
      errorMessage = err.message;
    } else if (typeof err === "string") {
      errorMessage = err;
    } else if (err && typeof err === "object") {
      errorMessage = JSON.stringify(err);
    }

    return new Response(JSON.stringify({ error: errorMessage }), {
      headers: {
        ...corsHeaders,
        "Content-Type": "application/json",
      },
      status: 500,
    });
  }
});
