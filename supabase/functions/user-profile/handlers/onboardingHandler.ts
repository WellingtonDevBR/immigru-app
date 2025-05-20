/**
 * Handler for onboarding-related operations
 */
import { UserProfile } from "../models/types.ts";
import { createProfileIfNotExists } from "./profileHandler.ts";
import { sanitizeNotes } from "../utils/sanitize.ts";
import { handleMigrationSteps } from "./migrationHandler.ts";

// Use type from Supabase client without importing the module
type SupabaseClient = any;

/**
 * Process onboarding data for a specific step
 * @param supabaseClient The Supabase client
 * @param step The onboarding step
 * @param data The step data
 * @param userId The user ID
 * @param existingProfile The existing user profile
 * @param isCompleted Whether onboarding is completed
 * @returns The processed data
 */
export async function processStepData(
  supabaseClient: SupabaseClient,
  step: string,
  data: any,
  userId: string,
  existingProfile: UserProfile | null,
  isCompleted: boolean,
): Promise<{ success: boolean; data?: any; error?: any }> {
  try {
    switch (step) {
      case "birthCountry":
        // Validate the birth country
        if (!data.birthCountry) {
          throw new Error("Birth country is required");
        }

        let countryName = data.birthCountry;
        let countryId = null;

        // If it looks like an ISO code, try to find by ISO code first
        if (data.birthCountry.length <= 3) {
          // Try to find country by ISO code (exact match)
          const { data: isoCountryData, error: isoCountryError } =
            await supabaseClient
              .from("Country")
              .select("Id, Name, IsoCode")
              .eq("IsoCode", data.birthCountry.toUpperCase())
              .single();

          if (!isoCountryError && isoCountryData) {
            countryName = isoCountryData.Name;
            countryId = isoCountryData.Id;
          } else {
            // Try name search as fallback
            const { data: nameCountryData, error: nameCountryError } =
              await supabaseClient
                .from("Country")
                .select("Id, Name")
                .ilike("Name", `%${data.birthCountry}%`)
                .limit(1);

            if (
              !nameCountryError && nameCountryData && nameCountryData.length > 0
            ) {
              countryName = nameCountryData[0].Name;
              countryId = nameCountryData[0].Id;
            } else {
            }
          }
        } else {
          // Try direct name match
          const { data: countryData, error: countryError } =
            await supabaseClient
              .from("Country")
              .select("Id, Name")
              .ilike("Name", `%${data.birthCountry}%`)
              .limit(1);

          if (!countryError && countryData && countryData.length > 0) {
            countryName = countryData[0].Name;
            countryId = countryData[0].Id;
          } else {
          }
        }

        // First ensure the UserProfile record exists
        await createProfileIfNotExists(supabaseClient, userId);

        // Update the user profile with origin country

        // Update UserProfile.OriginCountry using standard client update

        const { data: updateResult, error: updateError } = await supabaseClient
          .from("UserProfile")
          .update({
            OriginCountry: countryName,
            UpdatedAt: new Date().toISOString(),
          })
          .eq("UserId", userId)
          .select();

        if (updateError) {
        } else {
        }

        // Also add the birth country as the first migration step (Order=1) if we have a country ID
        if (countryId) {
          // Check for existing birth country step
          const { data: existingSteps, error: stepsError } =
            await supabaseClient
              .from("MigrationStep")
              .select("*")
              .eq("UserId", userId)
              .eq("Order", 1)
              .limit(1);

          if (stepsError) {
          } else if (existingSteps && existingSteps.length > 0) {
            // Update existing birth country step
            const { error: updateStepError } = await supabaseClient
              .from("MigrationStep")
              .update({
                CountryId: countryId,
                UpdatedAt: new Date().toISOString(),
              })
              .eq("Id", existingSteps[0].Id);

            if (updateStepError) {
            }
          } else {
            // Create new birth country step
            const { error: insertStepError } = await supabaseClient
              .from("MigrationStep")
              .insert({
                UserId: userId,
                CountryId: countryId,
                Order: 1, // Birth country is always first
                ArrivedDate: null, // No arrival date for birth country
                IsCurrentLocation: false,
                IsTargetDestination: false,
                WasSuccessful: true,
                CreatedAt: new Date().toISOString(),
                UpdatedAt: new Date().toISOString(),
              });

            if (insertStepError) {
            }
          }
        }

        return { success: true, data: { originCountry: countryName } };

      case "currentStatus":
        // Validate current status
        if (!data.currentStatus) {
          throw new Error("Current status is required");
        }

        // Validate that the status is a known value
        const validStatuses = [
          "planning",
          "gathering",
          "moved",
          "exploring",
          "permanent",
        ];
        if (!validStatuses.includes(data.currentStatus)) {
          throw new Error(`Invalid current status: ${data.currentStatus}`);
        }

        // First ensure the UserProfile record exists
        await createProfileIfNotExists(supabaseClient, userId);

        // Update the user profile with current status

        // Update the user profile with current status
        try {
          // Update using UserId
          const { data: updateResult, error: statusError } =
            await supabaseClient
              .from("UserProfile")
              .update({
                MigrationStage: data.currentStatus,
                UpdatedAt: new Date().toISOString(),
              })
              .eq("UserId", userId)
              .select();

          if (statusError) {
            throw statusError;
          } else {
            // Log the updated profile for debugging
            const { data: updatedProfile } = await supabaseClient
              .from("UserProfile")
              .select("*")
              .eq("UserId", userId)
              .single();

            return {
              success: true,
              data: { currentStatus: data.currentStatus },
            };
          }
        } catch (error) {
          throw error;
        }

      case "migrationJourney":
        // Handle migration steps
        if (!data.migrationSteps || !Array.isArray(data.migrationSteps)) {
          throw new Error("Migration steps must be an array");
        }

        if (data.migrationSteps.length === 0) {
          return {
            success: true,
            data: { message: "No migration steps to process" },
          };
        }

        // Log the steps for debugging
        data.migrationSteps.forEach((step: any, index: number) => {
          console.log(
            `Step ${index + 1}:`,
            JSON.stringify({
              countryId: step.countryId,
              visaId: step.visaId,
              arrivedDate: step.arrivedDate,
              leftDate: step.leftDate,
              isCurrentLocation: step.isCurrentLocation,
              isTargetDestination: step.isTargetDestination,
            }),
          );
        });

        try {
          const result = await handleMigrationSteps(
            supabaseClient,
            userId,
            data.migrationSteps,
          );

          return result;
        } catch (error) {
          throw error;
        }

      case "profession":
        // Update the user profile with profession and industry
        if (!data.profession) {
          throw new Error("Profession is required");
        }

        const { success: professionSuccess, error: professionError } =
          await supabaseClient
            .from("UserProfile")
            .update({
              Profession: data.profession,
              Industry: data.industry || null,
              UpdatedAt: new Date().toISOString(),
            })
            .eq("UserId", userId);

        if (professionError) {
          throw professionError;
        }

        return {
          success: true,
          data: { profession: data.profession, industry: data.industry },
        };

      case "languages":
        // Handle user languages
        if (
          !data.languages || !Array.isArray(data.languages) ||
          data.languages.length === 0
        ) {
          throw new Error("Languages are required");
        }

        // Define languageData outside the try block so it's accessible in the return statement
        let processedLanguages: any[] = [];
        
        try {
          // First delete existing languages
          await supabaseClient
            .from("UserLanguage")
            .delete()
            .eq("UserId", userId);

          // Then insert new languages with only the required fields
          // Note: Removed Proficiency field as it doesn't exist in the schema
          const languageData = data.languages.map((lang: any) => ({
            UserId: userId,
            LanguageId: typeof lang === "object" ? lang.id : lang,
          }));

          const { error: languageError } = await supabaseClient
            .from("UserLanguage")
            .insert(languageData);

          if (languageError) {
            throw languageError;
          }
          
          // Store the processed languages for the return value
          processedLanguages = languageData;
        } catch (error) {
          console.error("Error processing languages:", error);
          // Use the dedicated user-language edge function as a fallback
          // This is the same function that works with the language step directly
          try {
            // Convert language data to simple ID array
            const languageIds = data.languages.map((lang: any) => 
              typeof lang === "object" ? lang.id : lang
            );
            
            const { data: fallbackData, error: fallbackError } = await supabaseClient.functions.invoke(
              'user-language',
              {
                body: { languageIds }
              }
            );
            
            if (fallbackError) {
              throw fallbackError;
            }
            
            // Store the processed language IDs for the return value
            processedLanguages = languageIds.map((id: number) => ({
              UserId: userId,
              LanguageId: id,
            }));
          } catch (fallbackError) {
            console.error("Fallback language processing also failed:", fallbackError);
            // Continue with onboarding even if language processing fails
          }
        }

        return { success: true, data: { languages: processedLanguages } };

      case "interests":
        // Handle user interests
        if (
          !data.interests || !Array.isArray(data.interests) ||
          data.interests.length === 0
        ) {
          throw new Error("Interests are required");
        }

        // First delete existing interests
        await supabaseClient
          .from("UserInterest")
          .delete()
          .eq("UserId", userId);

        // Then insert new interests
        const interestData = data.interests.map((interest: any) => ({
          UserId: userId,
          InterestId: typeof interest === "object" ? interest.id : interest,
          CreatedAt: new Date().toISOString(),
          UpdatedAt: new Date().toISOString(),
        }));

        const { error: interestError } = await supabaseClient
          .from("UserInterest")
          .insert(interestData);

        if (interestError) {
          throw interestError;
        }

        return { success: true, data: { interests: interestData } };

      case "profileBasicInfo":
        // Update the user profile with basic info
        const { fullName, profilePhotoUrl } = data;

        if (!fullName) {
          throw new Error("Full name is required");
        }

        const { success: basicInfoSuccess, error: basicInfoError } =
          await supabaseClient
            .from("UserProfile")
            .update({
              FullName: fullName,
              AvatarUrl: profilePhotoUrl || null,
              UpdatedAt: new Date().toISOString(),
            })
            .eq("UserId", userId);

        if (basicInfoError) {
          throw basicInfoError;
        }

        return {
          success: true,
          data: { fullName, avatarUrl: profilePhotoUrl },
        };

      case "profileDisplayName":
        // Update the user profile with display name

        if (!data.displayName) {
          throw new Error("Display name is required");
        }

        try {
          const { data: displayNameData, error: displayNameError } =
            await supabaseClient
              .from("UserProfile")
              .update({
                DisplayName: data.displayName,
                UpdatedAt: new Date().toISOString(),
              })
              .eq("UserId", userId);

          if (displayNameError) {
            throw displayNameError;
          }
        } catch (error) {
          throw error;
        }

        return { success: true, data: { displayName: data.displayName } };

      case "profileBio":
        // Update the user profile with bio
        const sanitizedBio = data.bio ? sanitizeNotes(data.bio) : null;

        const { success: bioSuccess, error: bioError } = await supabaseClient
          .from("UserProfile")
          .update({
            Bio: sanitizedBio,
            UpdatedAt: new Date().toISOString(),
          })
          .eq("UserId", userId);

        if (bioError) {
          throw bioError;
        }

        return { success: true, data: { bio: sanitizedBio } };

      case "profileLocation":
        // Update the user profile with location
        const { currentCity, destinationCity } = data;

        const { success: locationSuccess, error: locationError } =
          await supabaseClient
            .from("UserProfile")
            .update({
              CurrentCity: currentCity || null,
              DestinationCity: destinationCity || null,
              UpdatedAt: new Date().toISOString(),
            })
            .eq("UserId", userId);

        if (locationError) {
          throw locationError;
        }

        return { success: true, data: { currentCity, destinationCity } };

      case "profilePrivacy":
        // Update the user profile with privacy settings
        const isPrivate = data.isPrivate === true;

        const { success: privacySuccess, error: privacyError } =
          await supabaseClient
            .from("UserProfile")
            .update({
              IsPrivate: isPrivate,
              UpdatedAt: new Date().toISOString(),
            })
            .eq("UserId", userId);

        if (privacyError) {
          throw privacyError;
        }

        return { success: true, data: { isPrivate } };

      case "completed":
        // Mark onboarding as completed in the User table
        const { success: completedSuccess, error: completedError } =
          await supabaseClient
            .from("User")
            .update({
              HasCompletedOnboarding: true,
              UpdatedAt: new Date().toISOString(),
            })
            .eq("Id", userId);

        if (completedError) {
          throw completedError;
        }

        // Also update the UserProfile table for backward compatibility
        try {
          await supabaseClient
            .from("UserProfile")
            .update({
              // Use the correct column name that exists in the UserProfile table
              HasCompletedOnboarding: true,
              UpdatedAt: new Date().toISOString(),
            })
            .eq("UserId", userId);
        } catch (profileError) {
          console.error("Error updating UserProfile:", profileError);
          // Don't throw here, as we've already updated the main User table
        }

        // Process ImmiGrove selections if provided
        if (
          data && data.immiGroveIds && Array.isArray(data.immiGroveIds) &&
          data.immiGroveIds.length > 0
        ) {
          try {
            // Insert selected ImmiGroves for the user
            const immiGroveInserts = data.immiGroveIds.map((
              immiGroveId: string,
            ) => ({
              UserId: userId,
              ImmiGroveId: immiGroveId,
              CreatedAt: new Date().toISOString(),
              UpdatedAt: new Date().toISOString(),
            }));

            const { error: immiGroveError } = await supabaseClient
              .from("UserImmiGrove")
              .upsert(immiGroveInserts, { onConflict: "UserId,ImmiGroveId" });

            if (immiGroveError) {
              console.error("Error saving ImmiGroves:", immiGroveError);
              // We don't throw here to avoid failing the entire onboarding completion
              // Just log the error and continue
            }
          } catch (immiGroveErr) {
            console.error("Exception saving ImmiGroves:", immiGroveErr);
            // We don't throw here to avoid failing the entire onboarding completion
          }
        }

        return { success: true, data: { hasCompletedOnboarding: true } };

      default:
        throw new Error(`Unknown step: ${step}`);
    }
  } catch (error) {
    return { success: false, error };
  }
}

/**
 * Check if onboarding is completed
 * @param supabaseClient The Supabase client
 * @param userId The user ID
 * @returns Whether onboarding is completed
 */
export async function checkOnboardingStatus(
  supabaseClient: SupabaseClient,
  userId: string,
): Promise<{ completed: boolean; profile?: UserProfile }> {
  const { data, error } = await supabaseClient
    .from("UserProfile")
    .select("*")
    .eq("UserId", userId)
    .single();

  if (error || !data) {
    return { completed: false };
  }

  return {
    completed: data.IsOnboardingCompleted === true,
    profile: data,
  };
}

/**
 * Get data for a specific onboarding step
 * @param supabaseClient The Supabase client
 * @param step The onboarding step
 * @param userId The user ID
 * @returns The step data
 */
export async function getOnboardingStepData(
  supabaseClient: SupabaseClient,
  step: string,
  userId: string,
): Promise<{ success: boolean; data?: any; error?: any }> {
  try {
    switch (step) {
      case "birthCountry":
        // Get the user's birth country
        const { data: profileData, error: profileError } = await supabaseClient
          .from("UserProfile")
          .select("OriginCountry")
          .eq("UserId", userId)
          .single();

        if (profileError) {
          throw profileError;
        }

        return {
          success: true,
          data: { birthCountry: profileData?.OriginCountry || null },
        };

      case "currentStatus":
        // Get the user's current migration status
        const { data: statusData, error: statusError } = await supabaseClient
          .from("UserProfile")
          .select("MigrationStage")
          .eq("UserId", userId)
          .single();

        if (statusError) {
          throw statusError;
        }

        return {
          success: true,
          data: { currentStatus: statusData?.MigrationStage || null },
        };

      case "migrationJourney":
        // Get the user's migration steps with detailed country and visa information
        const { data: migrationData, error: migrationError } =
          await supabaseClient
            .from("MigrationStep")
            .select(`
            Id, 
            UserId, 
            Order, 
            CountryId, 
            Country:CountryId(Id, Name, IsoCode), 
            VisaId, 
            Visa:VisaId(Id, VisaName, VisaType), 
            IsCurrent, 
            IsTarget, 
            ArrivedAt, 
            LeftAt, 
            Notes, 
            MigrationReason, 
            WasSuccessful, 
            CreatedAt, 
            UpdatedAt
          `)
            .eq("UserId", userId)
            .order("Order", { ascending: true });

        if (migrationError) {
          throw migrationError;
        }

        // Format the steps for the frontend
        const formattedSteps = (migrationData || []).map((step) => ({
          ...step,
          countryName: step.Country?.Name || "",
          countryIsoCode: step.Country?.IsoCode || "",
          visaName: step.Visa?.VisaName || null,
          visaType: step.Visa?.VisaType || null,
        }));

        return {
          success: true,
          data: { migrationSteps: formattedSteps },
        };

      case "languages":
        // Get the user's languages
        const { data: languageData, error: languageError } =
          await supabaseClient
            .from("UserLanguage")
            .select("*, Language(Id, Name, NativeName, IsoCode)")
            .eq("UserId", userId);

        if (languageError) {
          throw languageError;
        }

        return {
          success: true,
          data: { languages: languageData || [] },
        };

      case "interests":
        // Get the user's interests
        const { data: interestData, error: interestError } =
          await supabaseClient
            .from("UserInterest")
            .select("*, Interest(Id, Name, Category)")
            .eq("UserId", userId);

        if (interestError) {
          throw interestError;
        }

        return {
          success: true,
          data: { interests: interestData || [] },
        };

      default:
        throw new Error(`Unsupported onboarding step: ${step}`);
    }
  } catch (error) {
    return { success: false, error: error.message };
  }
}
