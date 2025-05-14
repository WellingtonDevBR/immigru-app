/**
 * Utility functions for validation
 */

/**
 * Validate migration step data
 * @param step The migration step to validate
 */
export function validateMigrationStep(step: any): void {
  
  
  
  // Check if we have a step object
  if (!step) {

    throw new Error('Migration step is undefined or null');
  }
  
  // Validate country ID (required)
  if (!step.countryId) {

    throw new Error('Country ID is required for migration steps');
  } else {
    
  }
  
  // Validate arrived date (make it optional)
  if (step.arrivedDate) {
    
  } else {
    
    // We'll make this optional to be more flexible
    // Instead of throwing an error, we'll just log a warning

  }
  
  // Validate that arrived date is not in the future (if provided)
  if (step.arrivedDate) {
    try {
      const arrivedAtDate = new Date(step.arrivedDate);
      const currentDate = new Date();
      
      
      
      // Add a small buffer (1 day) to account for timezone differences
      const oneDayBuffer = 24 * 60 * 60 * 1000; // 1 day in milliseconds
      if (arrivedAtDate.getTime() > (currentDate.getTime() + oneDayBuffer)) {

        // Instead of throwing an error, just warn about it
        // throw new Error('Arrived date cannot be in the future');
      }
    } catch (e) {

      throw new Error(`Invalid arrived date format: ${step.arrivedDate}`);
    }
  }
  
  // Validate that left date is after arrived date if both are provided
  if (step.leftDate && step.arrivedDate) {
    try {
      const leftAtDate = new Date(step.leftDate);
      const arrivedAtDate = new Date(step.arrivedDate);
      
      
      
      if (arrivedAtDate.getTime() > leftAtDate.getTime()) {

        // Instead of throwing an error, just warn about it
        // throw new Error('Left date must be after arrived date');
      }
    } catch (e) {

      // Just log the error but don't throw to be more flexible
    }
  } else if (step.leftDate) {
    
  }
  
  
}

/**
 * Validate migration reason
 * @param reason The migration reason to validate
 * @returns The validated reason or null if invalid
 */
export function validateMigrationReason(reason: string | null): string | null {
  if (!reason) return null;
  
  const validReasons = ['work', 'study', 'family', 'refugee', 'retirement', 'investment', 'lifestyle', 'other'];
  if (validReasons.includes(reason)) {
    return reason;
  }
  

  return null;
}

/**
 * Process boolean values consistently
 * @param value The value to convert to boolean
 * @param defaultValue The default value if conversion fails
 * @returns The processed boolean value
 */
export function processBoolean(value: any, defaultValue = false): boolean {
  if (typeof value === 'boolean') {
    return value;
  } else if (typeof value === 'string') {
    return value.toLowerCase() === 'true';
  } else if (value === 1 || value === '1') {
    return true;
  }
  return defaultValue;
}
