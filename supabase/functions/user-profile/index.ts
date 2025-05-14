// Supabase Edge Function for User Profile Management
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders } from "./cors.ts";
import { RequestPayload, ResponseData } from "./models/types.ts";
import {
  createProfileIfNotExists,
  getUserProfile,
  updateUserProfile,
} from "./handlers/profileHandler.ts";
import {
  checkOnboardingStatus,
  getOnboardingStepData,
  processStepData,
} from "./handlers/onboardingHandler.ts";
import { getMigrationSteps } from "./handlers/migrationHandler.ts";

// Create a Supabase client
const supabaseUrl = Deno.env.get("SUPABASE_URL") || "";
const supabaseKey = Deno.env.get("SUPABASE_ANON_KEY") || "";

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // Get the request body
    const requestData = await req.json();
    const { action, step, data } = requestData as RequestPayload;

    // Get the authorization header
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      throw new Error("Missing Authorization header");
    }

    // Create a Supabase client with the user's JWT
    const supabaseClient = createClient(supabaseUrl, supabaseKey, {
      global: {
        headers: {
          Authorization: authHeader,
        },
      },
    });

    // Get the user from the JWT
    const {
      data: { user },
      error: userError,
    } = await supabaseClient.auth.getUser();

    if (userError || !user) {
      throw new Error("Invalid user token");
    }

    // Get or create the user profile
    const existingProfile = await createProfileIfNotExists(
      supabaseClient,
      user.id,
    );

    // Process the request based on the action
    let responseData: ResponseData;

    switch (action) {
      case "save":
        if (!step) {
          throw new Error("Missing step parameter");
        }

        const isCompleted = existingProfile?.IsOnboardingCompleted === true;
        const result = await processStepData(
          supabaseClient,
          step,
          data,
          user.id,
          existingProfile,
          isCompleted,
        );

        responseData = {
          success: result.success,
          message: result.success
            ? "Data saved successfully"
            : "Failed to save data",
          data: result.data,
          error: result.error,
        };
        break;

      case "update":
        // Update user profile data
        if (!data) {
          throw new Error("Missing profile data");
        }

        const updateResult = await updateUserProfile(
          supabaseClient,
          user.id,
          data,
        );

        responseData = {
          success: updateResult.success,
          message: updateResult.success
            ? "Profile updated successfully"
            : "Failed to update profile",
          data: updateResult.data,
          error: updateResult.error,
        };
        break;

      case "getOnboardingData":
        // Get data for a specific onboarding step
        if (!step) {
          throw new Error("Missing step parameter");
        }

        const onboardingData = await getOnboardingStepData(
          supabaseClient,
          step,
          user.id,
        );

        responseData = {
          success: onboardingData.success,
          message: onboardingData.success
            ? "Onboarding data retrieved successfully"
            : "Failed to retrieve onboarding data",
          data: onboardingData.data,
          error: onboardingData.error,
        };
        break;

      case "get":
        // Get the user's profile data
        const profile = await getUserProfile(supabaseClient, user.id);
        const migrationSteps = await getMigrationSteps(supabaseClient, user.id);

        // Get languages
        const { data: languages } = await supabaseClient
          .from("UserLanguage")
          .select("LanguageId, Language(Id, Name, NativeName, Code)")
          .eq("UserId", user.id);

        // Get interests
        const { data: interests } = await supabaseClient
          .from("UserInterest")
          .select(
            "InterestId, Interest(Id, Name, CategoryId, Category(Id, Name))",
          )
          .eq("UserId", user.id);

        responseData = {
          success: true,
          message: "Profile data retrieved successfully",
          data: {
            profile,
            migrationSteps,
            languages: languages || [],
            interests: interests || [],
          },
        };
        break;

      case "checkStatus":
        // Check if the user has completed onboarding
        const status = await checkOnboardingStatus(supabaseClient, user.id);

        responseData = {
          success: true,
          message: "Onboarding status retrieved successfully",
          data: status,
        };
        break;

      default:
        throw new Error(`Unknown action: ${action}`);
    }

    // Log the response

    // Return the response
    return new Response(JSON.stringify(responseData), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });
  } catch (error) {




    // Log more details about the request that caused the error
    try {
      // We can't directly access requestData here as it might not be defined in case of parsing errors
      // Instead, try to parse the request body again
      const rawBody = await req.text();
      const parsedData = JSON.parse(rawBody);
      console.error(
        `Failed request details - Action: ${parsedData.action}, Step: ${
          parsedData.step || "none"
        }`,
      );
      console.error(
        `Request data that caused error:`,
        JSON.stringify(parsedData.data, null, 2),
      );
    } catch (e) {

    }

    // Return the error
    const errorResponse = {
      success: false,
      message: "Error processing request",
      error: error.message,
      errorType: error.constructor.name,
    };

    console.error(
      `Returning error response:`,
      JSON.stringify(errorResponse, null, 2),
    );

    return new Response(JSON.stringify(errorResponse), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 400,
    });
  }
});
