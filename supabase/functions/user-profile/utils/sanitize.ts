/**
 * Utility functions for sanitizing user input
 */

/**
 * Sanitize notes to prevent XSS attacks
 * @param input The input string to sanitize
 * @returns Sanitized string or null if input is empty
 */
export function sanitizeNotes(input: string): string | null {
  if (!input) return null;
  
  console.log(`Sanitizing notes: ${input}`);
  
  // Remove potentially dangerous HTML/script tags
  let sanitized = input
    .replace(/<script[^>]*>[\s\S]*?<\/script>/gi, '') // Remove script tags
    .replace(/<[^>]*>/g, '') // Remove any HTML tags
    .replace(/javascript:/gi, '') // Remove javascript: protocol
    .replace(/on\w+\s*=/gi, '') // Remove event handlers
    .replace(/\\x[0-9a-fA-F]{2}/g, '') // Remove hex escapes
    .replace(/\\u[0-9a-fA-F]{4}/g, ''); // Remove unicode escapes
  
  // Limit the length of notes to prevent excessive data
  if (sanitized.length > 500) {
    sanitized = sanitized.substring(0, 500);
  }
  
  console.log(`Sanitized notes: ${sanitized}`);
  return sanitized;
}

/**
 * Validate email format
 * @param email Email to validate
 * @returns True if email is valid
 */
export function isValidEmail(email: string): boolean {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}
