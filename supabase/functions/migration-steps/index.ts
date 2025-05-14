// supabase/functions/migration-steps/index.ts
// @deno-types="https://deno.land/std@0.168.0/http/server.ts"
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
// @deno-types="https://esm.sh/@supabase/supabase-js@2"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders } from "./shared/cors.ts";
import {
    getMigrationSteps,
    handleMigrationSteps,
} from "./handlers/migrationHandler.ts";
import { ResponseData } from "./models/types.ts";

// This is needed because some runtime APIs are not available in Deno Deploy
// @ts-ignore - Deno is available in Supabase Edge Functions
const supabaseUrl = Deno?.env.get("SUPABASE_URL") ?? "";
// @ts-ignore - Deno is available in Supabase Edge Functions
const supabaseKey = Deno?.env.get("SUPABASE_ANON_KEY") ?? "";

serve(async (req) => {
    console.log(`[${new Date().toISOString()}] Received ${req.method} request to migration-steps`);
    
    // Initialize action and data with default values
    let action: string = "get"; // Default action
    let data: any = null;
    
    try {
        // Handle request based on HTTP method
        if (req.method === "POST") {
            console.log(`[${new Date().toISOString()}] Processing POST request to migration-steps`);
            
            // Clone the request to read the body
            const clonedReq = req.clone();
            const rawBody = await clonedReq.text();
            console.log(`[${new Date().toISOString()}] Raw request body: ${rawBody.substring(0, 200)}${rawBody.length > 200 ? '...' : ''}`);
            
            try {
                // CRITICAL DEBUG: Log the raw request body to see exactly what's being received
                console.log(`[${new Date().toISOString()}] 📣 FULL RAW REQUEST BODY: ${rawBody}`);
                
                // Parse the request data
                const requestData = JSON.parse(rawBody);
                
                // CRITICAL: Extract action with explicit logging
                action = requestData.action || "get";
                console.log(`[${new Date().toISOString()}] 📣 ACTION PARAMETER: "${action}"`);
                
                // Extract data with explicit type checking
                data = requestData.data;
                console.log(`[${new Date().toISOString()}] 📣 DATA TYPE: ${typeof data}`);
                
                // Enhanced logging for debugging
                if (Array.isArray(data)) {
                    console.log(`[${new Date().toISOString()}] 📣 DATA IS ARRAY: Length=${data.length}`);
                    if (data.length > 0) {
                        // Log the first item for debugging
                        console.log(`[${new Date().toISOString()}] 📣 FIRST ITEM:`, JSON.stringify(data[0]).substring(0, 200));
                    }
                } else if (data === null) {
                    console.log(`[${new Date().toISOString()}] 📣 DATA IS NULL - This is likely an error`);
                } else if (typeof data === 'object') {
                    console.log(`[${new Date().toISOString()}] 📣 DATA IS OBJECT with keys:`, Object.keys(data));
                } else {
                    console.log(`[${new Date().toISOString()}] 📣 UNEXPECTED DATA FORMAT: ${typeof data}`);
                }
                
                // CRITICAL: Force action to 'save' if we have data array
                if (Array.isArray(data) && data.length > 0) {
                    if (action !== 'save') {
                        console.log(`[${new Date().toISOString()}] 📣 CORRECTING ACTION: Changing "${action}" to "save" because data is an array`);
                        action = 'save';
                    }
                }
            } catch (e) {
                console.error(`[${new Date().toISOString()}] ❌ Error parsing request body:`, e);
                throw new Error(`Failed to parse request body: ${e.message}`);
            }
        } else if (req.method === "GET") {
            console.log(`[${new Date().toISOString()}] Processing GET request`);
            
            // Parse URL parameters
            const url = new URL(req.url);
            action = url.searchParams.get("action") || "get";
            console.log(`[${new Date().toISOString()}] GET request with action: ${action}`);
        }
    } catch (e) {
        console.error(`[${new Date().toISOString()}] Error processing request:`, e);
        throw e;
    }

    try {
        // Handle CORS preflight requests
        if (req.method === "OPTIONS") {
            console.log(`[${new Date().toISOString()}] Handling OPTIONS request (CORS preflight)`);
            return new Response("ok", { headers: corsHeaders });
        }
        
        // Validate the request method
        if (req.method !== "GET" && req.method !== "POST") {
            console.log(`[${new Date().toISOString()}] Unsupported method: ${req.method}`);
            throw new Error(`Unsupported method: ${req.method}`);
        }

        // Validate authentication header
        const authHeader = req.headers.get("Authorization");
        if (!authHeader) {
            console.log(`[${new Date().toISOString()}] Missing Authorization header`);
            throw new Error("Missing Authorization header");
        }

        console.log(`[${new Date().toISOString()}] Creating Supabase client`);
        const supabaseClient = createClient(supabaseUrl, supabaseKey, {
            global: {
                headers: {
                    Authorization: authHeader,
                },
            },
        });

        // Get the user from the token
        console.log(`[${new Date().toISOString()}] Authenticating user from token`);
        const {
            data: { user },
            error: userError,
        } = await supabaseClient.auth.getUser();

        if (userError) {
            console.error(`[${new Date().toISOString()}] Invalid user token:`, userError.message);
            throw new Error(`Invalid user token: ${userError.message}`);
        }

        if (!user) {
            console.error(`[${new Date().toISOString()}] Missing user in token`);
            throw new Error("Missing user in token");
        }
        
        console.log(`[${new Date().toISOString()}] Authenticated user: ${user.id}`);

        let responseData: ResponseData;

        console.log(`[${new Date().toISOString()}] Processing action: ${action}`);
        switch (action) {
            case "save":
                console.log(`[${new Date().toISOString()}] Handling save action`);
                if (req.method !== "POST") {
                    console.error(`[${new Date().toISOString()}] Save action requires POST method, got ${req.method}`);
                    throw new Error("Save action requires POST method");
                }

                if (!Array.isArray(data)) {
                    console.error(`[${new Date().toISOString()}] Data must be an array, got ${typeof data}`);
                    throw new Error("Data must be an array of migration steps");
                }

                try {
                    console.log(`[${new Date().toISOString()}] Calling handleMigrationSteps with ${data.length} steps`);
                    responseData = await handleMigrationSteps(
                        supabaseClient,
                        user.id,
                        data,
                    );
                    console.log(`[${new Date().toISOString()}] Successfully processed migration steps`);
                } catch (error) {
                    console.error(`[${new Date().toISOString()}] Error handling migration steps:`, error);
                    throw error;
                }
                break;

            case "get":
                console.log(`[${new Date().toISOString()}] Handling get action`);
                try {
                    console.log(`[${new Date().toISOString()}] Retrieving migration steps for user: ${user.id}`);
                    const steps = await getMigrationSteps(
                        supabaseClient,
                        user.id,
                    );

                    console.log(`[${new Date().toISOString()}] Retrieved ${steps.length} migration steps`);
                    responseData = { success: true, data: steps };
                } catch (error) {
                    console.error(`[${new Date().toISOString()}] Error getting migration steps:`, error);
                    throw error;
                }
                break;

            default:
                console.error(`[${new Date().toISOString()}] Unknown action: ${action}`);
                throw new Error(`Unknown action: ${action}`);
        }

        // Prepare successful response
        console.log(`[${new Date().toISOString()}] Preparing successful response`);
        const responseBody = JSON.stringify(responseData);
        console.log(`[${new Date().toISOString()}] Response body length: ${responseBody.length} bytes`);
        
        return new Response(responseBody, {
            headers: { ...corsHeaders, "Content-Type": "application/json" },
            status: 200,
        });
    } catch (error) {

        // Handle errors
        console.error(`[${new Date().toISOString()}] Error in edge function:`, error);
        
        const errorResponse = {
            success: false,
            message: "Error processing migration steps request",
            error: error.message,
            timestamp: new Date().toISOString(),
        };
        
        console.log(`[${new Date().toISOString()}] Sending error response: ${JSON.stringify(errorResponse)}`);
        
        return new Response(
            JSON.stringify(errorResponse),
            {
                headers: { ...corsHeaders, "Content-Type": "application/json" },
                status: 400,
            },
        );
    }
});
