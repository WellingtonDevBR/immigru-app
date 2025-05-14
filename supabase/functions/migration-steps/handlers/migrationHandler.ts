/**
 * Handler for migration-related operations
 */
import { MigrationStep } from "../models/types.ts";
import { sanitizeNotes } from "../utils/sanitize.ts";
import {
  processBoolean,
  validateMigrationReason,
  validateMigrationStep,
} from "../utils/validation.ts";

// Use type from Supabase client without importing the module
type SupabaseClient = any;

/**
 * Process and save migration steps
 * @param supabaseClient The Supabase client
 * @param userId The user ID
 * @param migrationSteps The migration steps to save
 * @returns Success status and saved steps
 */
export async function handleMigrationSteps(
  supabaseClient: SupabaseClient,
  userId: string,
  migrationSteps: any[],
): Promise<{ success: boolean; data?: any; error?: any }> {
  // Log the received data from the client

  const results: any[] = [];

  // Process each migration step
  for (let i = 0; i < migrationSteps.length; i++) {
    const step = migrationSteps[i];
    // Order will be determined later based on existing steps

    try {
      // Check if this is a deletion request
      if (step.isDeleted === true || step.isDeleted === "true") {
        console.log(`Processing deletion request for step ID: ${step.id}`);

        if (!step.id) {
          console.error("Cannot delete step without ID");
          throw new Error("Cannot delete step without ID");
        }

        try {
          // First verify the step exists
          const { data: existingStep, error: checkError } = await supabaseClient
            .from("MigrationStep")
            .select("Id, CountryId, Order")
            .eq("Id", step.id)
            .single();

          if (checkError) {
            console.error(
              `Error checking if step ${step.id} exists:`,
              checkError.message,
            );
            throw checkError;
          } else if (!existingStep) {
            console.warn(
              `Step ${step.id} not found, may have been already deleted`,
            );
            continue; // Skip to the next step
          } else {
            console.log(
              `Found step ${step.id} with order ${existingStep.Order}, proceeding with deletion`,
            );
          }

          // Delete the step
          try {
            const { data: deletedStep, error: deleteError } =
              await supabaseClient
                .from("MigrationStep")
                .delete()
                .eq("Id", step.id)
                .select("*");

            if (deleteError) {
              console.error(
                `Error deleting step ${step.id}:`,
                deleteError.message,
              );
              throw deleteError;
            }

            if (!deletedStep || deletedStep.length === 0) {
              console.warn(`No data returned after deleting step ${step.id}`);
            } else {
              console.log(`Successfully deleted step ${step.id}`);
            }

            // Get all remaining steps for this user to update their order
            const { data: remainingSteps, error: remainingError } =
              await supabaseClient
                .from("MigrationStep")
                .select("Id, Order, ArrivedAt")
                .eq("UserId", userId)
                .order("ArrivedAt", { ascending: true });

            if (remainingError) {
              console.error(
                "Error fetching remaining steps:",
                remainingError.message,
              );
            } else if (remainingSteps && remainingSteps.length > 0) {
              console.log(
                `Found ${remainingSteps.length} remaining steps, updating their order`,
              );

              // Update the order of each remaining step
              for (let i = 0; i < remainingSteps.length; i++) {
                const newOrder = i + 1; // 1-based ordering
                const stepId = remainingSteps[i].Id;

                if (remainingSteps[i].Order !== newOrder) {
                  console.log(
                    `Updating step ${stepId} order from ${
                      remainingSteps[i].Order
                    } to ${newOrder}`,
                  );

                  const { error: updateError } = await supabaseClient
                    .from("MigrationStep")
                    .update({ Order: newOrder })
                    .eq("Id", stepId);

                  if (updateError) {
                    console.error(
                      `Error updating order for step ${stepId}:`,
                      updateError.message,
                    );
                  }
                }
              }
            }

            // Add the deleted step to the results
            results.push({ id: step.id, deleted: true });
            continue; // Skip to the next step
          } catch (error) {
            console.error(
              `Error in deletion process for step ${step.id}:`,
              error,
            );
            throw error;
          }
        } catch (error) {
          console.error(
            `Error in deletion verification for step ${step.id}:`,
            error,
          );
          throw error;
        }
      }

      // For non-deletion requests, validate the step data

      // Ensure countryId is a number
      if (step.countryId && typeof step.countryId !== "number") {
        step.countryId = Number(step.countryId);
      }

      validateMigrationStep(step);

      // First get all existing steps for this user to determine proper ordering

      const { data: allExistingSteps, error: existingStepsError } =
        await supabaseClient
          .from("MigrationStep")
          .select("Id, Order, CountryId, VisaId")
          .eq("UserId", userId)
          .order("Order", { ascending: true });

      if (existingStepsError) {
        throw existingStepsError;
      }

      if (allExistingSteps && allExistingSteps.length > 0) {
      }

      // Check if this step already exists by matching country and visa
      let existingStep: { Id: number; Order: number } | null = null;

      // If step has an ID, try to find it directly
      if (step.id) {
        const { data: stepById } = await supabaseClient
          .from("MigrationStep")
          .select("Id, Order")
          .eq("Id", step.id)
          .single();

        if (stepById) {
          existingStep = stepById as { Id: number; Order: number };
        }
      }

      // If no ID or step not found by ID, try to match by country and visa
      if (!existingStep && step.countryId) {
        const { data: matchingSteps } = await supabaseClient
          .from("MigrationStep")
          .select("Id, Order, CountryId, VisaId")
          .eq("UserId", userId)
          .eq("CountryId", step.countryId);

        if (matchingSteps && matchingSteps.length > 0) {
          // If visa is specified, try to match that too
          if (step.visaId) {
            const exactMatch = matchingSteps.find((s) =>
              s.VisaId === Number(step.visaId)
            );
            if (exactMatch) {
              existingStep = exactMatch as { Id: number; Order: number };
            }
          } else {
            // If no visa specified, just use the first matching country
            existingStep = matchingSteps[0] as { Id: number; Order: number };
          }
        }
      }

      // Determine the order for this step
      let stepOrder: number;

      if (existingStep && existingStep.Order) {
        // If updating an existing step, keep its order
        stepOrder = existingStep.Order;
      } else {
        // For a new step, assign the next available order
        const maxOrder = allExistingSteps && allExistingSteps.length > 0
          ? Math.max(...allExistingSteps.map((s) => s.Order || 0))
          : 0;
        stepOrder = maxOrder + 1;
      }

      // Process visa ID
      let visaIdValue: number | null = null;
      if (step.visaId) {
        try {
          visaIdValue = Number(step.visaId);
        } catch (e) {
          console.error(
            `Failed to convert visaId to number: ${step.visaId}`,
            e,
          );
        }
      }

      // Verify if the visa ID actually exists in the database
      if (visaIdValue !== null && !Number.isNaN(visaIdValue)) {
        try {
          const { data: visaData, error: visaError } = await supabaseClient
            .from("Visa")
            .select("Id")
            .eq("Id", visaIdValue)
            .single();

          if (visaError || !visaData) {
            console.warn(
              `Visa ID ${visaIdValue} does not exist in the database. Setting to null.`,
            );
            visaIdValue = null;
          }
        } catch (e) {
          visaIdValue = null;
        }
      }

      // If visa ID is not found, try to find by name and country
      if (visaIdValue === null && step.visaName && step.countryId) {
        try {
          const { data: visaByNameData, error: visaByNameError } =
            await supabaseClient
              .from("Visa")
              .select("Id")
              .eq("VisaName", step.visaName)
              .eq("CountryId", step.countryId)
              .single();

          if (!visaByNameError && visaByNameData) {
            visaIdValue = visaByNameData.Id;
          }
        } catch (e) {
        }
      }

      // Process boolean values
      const isCurrentValue = processBoolean(step.isCurrentLocation);
      const isTargetValue = processBoolean(step.isTargetDestination);
      const wasSuccessfulValue = processBoolean(step.wasSuccessful, true); // Default to true

      // Sanitize notes
      const sanitizedNotes = step.notes ? sanitizeNotes(step.notes) : null;

      // Validate migration reason
      const migrationReason = validateMigrationReason(step.migrationReason);

      // Create the step data
      // Ensure dates are properly formatted for database
      let arrivedAt: string | null = null;
      if (step.arrivedDate) {
        try {
          const date = new Date(step.arrivedDate);
          arrivedAt = date.toISOString();
        } catch (e) {
        }
      }

      let leftAt: string | null = null;
      if (step.leftDate) {
        try {
          const date = new Date(step.leftDate);
          leftAt = date.toISOString();
        } catch (e) {
        }
      }

      // Final step data to insert or update
      const stepData = {
        UserId: userId,
        CountryId: step.countryId,
        CountryName: step.countryName, // CRITICAL: Preserve the country name
        VisaId: visaIdValue,
        VisaName: step.visaName, // CRITICAL: Preserve the visa name
        IsCurrent: isCurrentValue,
        IsTarget: isTargetValue,
        ArrivedAt: arrivedAt,
        LeftAt: leftAt,
        Notes: sanitizedNotes,
        MigrationReason: migrationReason,
        WasSuccessful: wasSuccessfulValue,
        Order: stepOrder,
        UpdatedAt: new Date().toISOString(),
      };

      let result;

      if (existingStep) {
        // Update existing step

        const { data, error } = await supabaseClient
          .from("MigrationStep")
          .update(stepData)
          .eq("Id", existingStep.Id)
          .select()
          .single();

        if (error) {
          throw error;
        }

        result = data;
      } else {
        // Insert new step

        const { data, error } = await supabaseClient
          .from("MigrationStep")
          .insert(stepData)
          .select()
          .single();

        if (error) {
          throw error;
        }

        result = data;
      }

      results.push(result);
    } catch (error) {
      return { success: false, error };
    }
  }

  return { success: true, data: results };
}

export async function getMigrationSteps(
  supabaseClient: SupabaseClient,
  userId: string,
): Promise<MigrationStep[]> {
  const { data, error } = await supabaseClient
    .from("MigrationStep")
    .select(`
      Id, 
      UserId, 
      Order, 
      CountryId, 
      Country(Name), 
      VisaId, 
      Visa(VisaName), 
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
    .order("Order");

  if (error) {
    return [];
  }

  return data || [];
}
