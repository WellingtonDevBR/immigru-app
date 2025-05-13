/**
 * Type definitions for the user profile edge function
 */

export interface UserProfile {
  Id: string;
  FullName?: string;
  DisplayName?: string;
  Bio?: string | null;
  AvatarUrl?: string;
  CurrentCity?: string;
  DestinationCity?: string;
  OriginCountry?: string;
  MigrationStage?: string;
  Profession?: string;
  Industry?: string;
  IsPrivate?: boolean;
  IsOnboardingCompleted?: boolean;
  CreatedAt?: string;
  UpdatedAt?: string;
}

export interface MigrationStep {
  Id?: number;
  UserId: string;
  Order: number;
  CountryId: number;
  VisaId?: number | null;
  IsCurrent: boolean;
  IsTarget: boolean;
  ArrivedAt: string | null;
  LeftAt?: string | null;
  Notes?: string | null;
  MigrationReason?: string | null;
  WasSuccessful: boolean;
  CreatedAt?: string;
  UpdatedAt: string;
}

export interface UserLanguage {
  Id?: number;
  UserId: string;
  LanguageId: number;
  Proficiency?: string;
  CreatedAt?: string;
  UpdatedAt?: string;
}

export interface UserInterest {
  Id?: number;
  UserId: string;
  InterestId: number;
  CreatedAt?: string;
  UpdatedAt?: string;
}

export interface RequestPayload {
  action: string;
  step?: string;
  data?: any;
}

export interface ResponseData {
  success: boolean;
  message?: string;
  data?: any;
  error?: any;
}
