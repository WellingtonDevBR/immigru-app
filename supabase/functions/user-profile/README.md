# User Profile Edge Function

This Supabase Edge Function handles user profile management for the Immigru application.

## Structure

The code has been split into multiple files for better organization and maintainability:

- `index.ts`: Main entry point that handles HTTP requests
- `cors.ts`: CORS headers configuration
- `/models/types.ts`: Type definitions for the application
- `/utils/sanitize.ts`: Utility functions for sanitizing user input
- `/utils/validation.ts`: Utility functions for data validation
- `/handlers/profileHandler.ts`: Handlers for profile-related operations
- `/handlers/migrationHandler.ts`: Handlers for migration step operations
- `/handlers/onboardingHandler.ts`: Handlers for onboarding process

## Deployment

To deploy the function:

```bash
cd immigru-flutter
supabase functions deploy user-profile
```

## Features

- User profile management
- Onboarding process handling
- Migration journey tracking
- Security measures (input sanitization, validation)
- Proper error handling

## Onboarding Steps

1. Birth Country - Saved to MigrationStep table (Order=1)
2. Current Immigration Status - Saved to UserProfile.MigrationStage
3. Migration Journey - Saved to MigrationStep table (multiple records)
4. Profession - Saved to UserProfile.Profession and UserProfile.Industry
5. Languages - Saved to UserLanguage table (multiple records)
6. Interests - Saved to UserInterest table (multiple records)
7. Name and Avatar - Saved to UserProfile.FullName and UserProfile.AvatarUrl
8. Display Name - Saved to UserProfile.DisplayName
9. Bio - Saved to UserProfile.Bio
10. Location - Saved to UserProfile.CurrentCity and UserProfile.DestinationCity
11. Recommended ImmiGroves - Queries ImmiGrove and inserts into UserImmiGrove

## API Actions

- `save`: Saves data for a specific onboarding step
- `get`: Retrieves the user's profile data
- `checkStatus`: Checks if the user has completed onboarding
