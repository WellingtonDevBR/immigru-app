/**
 * Handler for migration-related operations
 */
import { MigrationStep } from '../models/types.ts';
import { sanitizeNotes } from '../utils/sanitize.ts';
import { validateMigrationStep, validateMigrationReason, processBoolean } from '../utils/validation.ts';

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
  migrationSteps: any[]
): Promise<{ success: boolean; data?: any; error?: any }> {
  console.log(`=== MIGRATION HANDLER - START ===`);
  console.log(`Processing ${migrationSteps.length} migration steps for user ${userId}`);
  console.log(`Raw migration steps:`, JSON.stringify(migrationSteps, null, 2));
  console.log(`Migration steps data:`, JSON.stringify(migrationSteps, null, 2));
  
  const results: any[] = [];
  
  // Process each migration step
  for (let i = 0; i < migrationSteps.length; i++) {
    const step = migrationSteps[i];
    // Order will be determined later based on existing steps
    
    try {
      console.log(`=== PROCESSING STEP ${i + 1} ===`);
      console.log(`Step data:`, JSON.stringify(step, null, 2));
      
      // Validate the step data
      console.log(`Validating step ${i + 1}...`);
      
      // Ensure countryId is a number
      if (step.countryId && typeof step.countryId !== 'number') {
        step.countryId = Number(step.countryId);
        console.log(`Converted countryId to number: ${step.countryId}`);
      }
      
      validateMigrationStep(step);
      console.log(`Step ${i + 1} validation successful`);
      
      // First get all existing steps for this user to determine proper ordering
      const { data: allExistingSteps } = await supabaseClient
        .from('MigrationStep')
        .select('Id, Order')
        .eq('UserId', userId)
        .order('Order', { ascending: true });
      
      console.log(`Found ${allExistingSteps?.length || 0} existing migration steps for user`);
      
      // Check if this step already exists by matching country and visa
      let existingStep: { Id: number, Order: number } | null = null;
      
      // If step has an ID, try to find it directly
      if (step.id) {
        const { data: stepById } = await supabaseClient
          .from('MigrationStep')
          .select('Id, Order')
          .eq('Id', step.id)
          .single();
          
        if (stepById) {
          existingStep = stepById as { Id: number, Order: number };
          console.log(`Found existing step by ID: ${existingStep.Id}`);
        }
      }
      
      // If no ID or step not found by ID, try to match by country and visa
      if (!existingStep && step.countryId) {
        const { data: matchingSteps } = await supabaseClient
          .from('MigrationStep')
          .select('Id, Order, CountryId, VisaId')
          .eq('UserId', userId)
          .eq('CountryId', step.countryId);
          
        if (matchingSteps && matchingSteps.length > 0) {
          // If visa is specified, try to match that too
          if (step.visaId) {
            const exactMatch = matchingSteps.find(s => s.VisaId === Number(step.visaId));
            if (exactMatch) {
              existingStep = exactMatch as { Id: number, Order: number };
              console.log(`Found existing step with matching country and visa: ${existingStep.Id}`);
            }
          } else {
            // If no visa specified, just use the first matching country
            existingStep = matchingSteps[0] as { Id: number, Order: number };
            console.log(`Found existing step with matching country: ${existingStep.Id}`);
          }
        }
      }
      
      // Determine the order for this step
      let stepOrder: number;
      
      if (existingStep && existingStep.Order) {
        // If updating an existing step, keep its order
        stepOrder = existingStep.Order;
        console.log(`Using existing order ${stepOrder} for step with ID: ${existingStep.Id}`);
      } else {
        // For a new step, assign the next available order
        const maxOrder = allExistingSteps && allExistingSteps.length > 0
          ? Math.max(...allExistingSteps.map(s => s.Order || 0))
          : 0;
        stepOrder = maxOrder + 1;
        console.log(`Assigning new order ${stepOrder} for step`);
      }
      
      // Process visa ID
      let visaIdValue: number | null = null;
      if (step.visaId) {
        try {
          visaIdValue = Number(step.visaId);
          console.log(`Converted visaId to number: ${visaIdValue}`);
        } catch (e) {
          console.error(`Failed to convert visaId to number: ${step.visaId}`, e);
        }
      }
      
      // Verify if the visa ID actually exists in the database
      if (visaIdValue !== null && !Number.isNaN(visaIdValue)) {
        try {
          const { data: visaData, error: visaError } = await supabaseClient
            .from('Visa')
            .select('Id')
            .eq('Id', visaIdValue)
            .single();
            
          if (visaError || !visaData) {
            console.warn(`Visa ID ${visaIdValue} does not exist in the database. Setting to null.`);
            visaIdValue = null;
          }
        } catch (e) {
          console.error(`Failed to process visaId: ${step.visaId}`, e);
          visaIdValue = null;
        }
      }
      
      // If visa ID is not found, try to find by name and country
      if (visaIdValue === null && step.visaName && step.countryId) {
        try {
          const { data: visaByNameData, error: visaByNameError } = await supabaseClient
            .from('Visa')
            .select('Id')
            .eq('VisaName', step.visaName)
            .eq('CountryId', step.countryId)
            .single();
            
          if (!visaByNameError && visaByNameData) {
            visaIdValue = visaByNameData.Id;
            console.log(`Found visa ID ${visaIdValue} for visa name '${step.visaName}'`);
          }
        } catch (e) {
          console.error(`Error searching for visa by name:`, e);
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
          console.log(`Formatted arrived date: ${arrivedAt}`);
        } catch (e) {
          console.error(`Error formatting arrived date: ${step.arrivedDate}`, e);
        }
      }
      
      let leftAt: string | null = null;
      if (step.leftDate) {
        try {
          const date = new Date(step.leftDate);
          leftAt = date.toISOString();
          console.log(`Formatted left date: ${leftAt}`);
        } catch (e) {
          console.error(`Error formatting left date: ${step.leftDate}`, e);
        }
      }
      
      const stepData: Partial<MigrationStep> = {
        UserId: userId,
        Order: stepOrder,
        CountryId: Number(step.countryId),
        VisaId: visaIdValue,
        IsCurrent: isCurrentValue,
        IsTarget: isTargetValue,
        ArrivedAt: arrivedAt,
        LeftAt: leftAt,
        Notes: sanitizedNotes,
        MigrationReason: migrationReason,
        WasSuccessful: wasSuccessfulValue,
        UpdatedAt: new Date().toISOString()
      };
      
      console.log(`Final step data to save:`, JSON.stringify(stepData, null, 2));
      
      let result;
      
      if (existingStep) {
        // Update existing step
        console.log(`Updating existing migration step with ID: ${existingStep.Id}`);
        const { data, error } = await supabaseClient
          .from('MigrationStep')
          .update(stepData)
          .eq('Id', existingStep.Id)
          .select()
          .single();
          
        if (error) {
          console.error(`Error updating migration step:`, error);
          throw error;
        }
        
        result = data;
        console.log(`Updated migration step with ID: ${existingStep.Id}, order: ${stepData.Order}`);
      } else {
        // Insert new step
        console.log(`Inserting new migration step with order: ${stepData.Order}`);
        const { data, error } = await supabaseClient
          .from('MigrationStep')
          .insert(stepData)
          .select()
          .single();
          
        if (error) {
          console.error(`Error inserting migration step:`, error);
          throw error;
        }
        
        result = data;
        console.log(`Inserted new migration step with ID: ${result.Id}, order: ${result.Order}`);
      }
      
      results.push(result as any);
      
    } catch (error) {
      console.error(`Error processing migration step ${i + 1}:`, error);
      return { success: false, error };
    }
  }
  
  return { success: true, data: results };
}

/**
 * Get migration steps for a user
 * @param supabaseClient The Supabase client
 * @param userId The user ID
 * @returns The user's migration steps
 */
export async function getMigrationSteps(
  supabaseClient: SupabaseClient, 
  userId: string
): Promise<MigrationStep[]> {
  console.log(`Getting migration steps for user: ${userId}`);
  
  const { data, error } = await supabaseClient
    .from('MigrationStep')
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
    .eq('UserId', userId)
    .order('Order');
    
  if (error) {
    console.error(`Error getting migration steps:`, error);
    return [];
  }
  
  return data || [];
}
