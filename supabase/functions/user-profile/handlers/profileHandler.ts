/**
 * Handler for profile-related operations
 */
import { UserProfile } from '../models/types.ts';
import { sanitizeNotes } from '../utils/sanitize.ts';

// Use type from Supabase client without importing the module
type SupabaseClient = any;

/**
 * Get user profile data
 * @param supabaseClient The Supabase client
 * @param userId The user ID
 * @returns The user profile data
 */
export async function getUserProfile(supabaseClient: SupabaseClient, userId: string): Promise<UserProfile | null> {
  
  
  const { data, error } = await supabaseClient
    .from('UserProfile')
    .select('*')
    .eq('UserId', userId)
    .single();
    
  if (error) {
    console.error(`Error getting user profile:`, error);
    return null;
  }
  
  return data;
}

/**
 * Update user profile data
 * @param supabaseClient The Supabase client
 * @param userId The user ID
 * @param profileData The profile data to update
 * @returns Success status and updated profile
 */
export async function updateUserProfile(
  supabaseClient: SupabaseClient, 
  userId: string, 
  profileData: Partial<UserProfile>
): Promise<{ success: boolean; data?: UserProfile; error?: any }> {
  
  
  
  // Sanitize text fields to prevent XSS
  if (profileData.Bio) {
    profileData.Bio = profileData.Bio ? sanitizeNotes(profileData.Bio) : undefined;
  }
  
  // Add updated timestamp
  const dataToUpdate = {
    ...profileData,
    UpdatedAt: new Date().toISOString()
  };
  
  const { data, error } = await supabaseClient
    .from('UserProfile')
    .update(dataToUpdate)
    .eq('UserId', userId)
    .select()
    .single();
    
  if (error) {
    console.error(`Error updating user profile:`, error);
    return { success: false, error };
  }
  
  return { success: true, data };
}

/**
 * Create user profile if it doesn't exist
 * @param supabaseClient The Supabase client
 * @param userId The user ID
 * @returns The created or existing profile
 */
export async function createProfileIfNotExists(
  supabaseClient: SupabaseClient, 
  userId: string
): Promise<UserProfile | null> {
  
  // Check if profile exists
  const existingProfile = await getUserProfile(supabaseClient, userId);
  
  if (existingProfile) {
    return existingProfile;
  }

  
  const newProfile = {
    UserId: userId,
    IsOnboardingCompleted: false,
    CreatedAt: new Date().toISOString(),
    UpdatedAt: new Date().toISOString()
  };
  
  try {
    const { data, error } = await supabaseClient
      .from('UserProfile')
      .insert(newProfile)
      .select()
      .single();
      
    if (error) {

      return null;
    }
    
    return data;
  } catch (e) {
    return null;
  }
}
