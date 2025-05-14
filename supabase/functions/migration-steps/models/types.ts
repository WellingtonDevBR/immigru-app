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
  