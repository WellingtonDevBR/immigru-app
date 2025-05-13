create table public."UserProfile" (
  "Id" uuid not null default gen_random_uuid (),
  "UserId" uuid not null,
  "FullName" character varying(255) not null,
  "UserName" character varying(50) not null,
  "DisplayName" character varying(100) not null,
  "Bio" text null default 'short'::"BioType",
  "AvatarUrl" public.AvatarType null default 'default'::"AvatarType",
  "Gender" character varying(20) null,
  "Birthdate" date null,
  "CurrentCity" character varying(100) null,
  "Profession" character varying(100) null,
  "Industry" character varying(100) null,
  "ShowEmail" public.VisibilityType null default 'private'::"VisibilityType",
  "ShowLocation" public.VisibilityType null default 'private'::"VisibilityType",
  "IsMentor" boolean null default false,
  "UpdatedAt" timestamp with time zone not null default CURRENT_TIMESTAMP,
  "CreatedAt" timestamp with time zone not null default CURRENT_TIMESTAMP,
  "OriginCountry" character varying null,
  "MigrationStage" character varying null,
  "DestinationCity" character varying null,
  "ShowBirthdate" public.VisibilityType null default 'private'::"VisibilityType",
  "ShowProfession" public.VisibilityType null default 'private'::"VisibilityType",
  "ShowJourneyInfo" public.VisibilityType null default 'private'::"VisibilityType",
  "LastUpdateIP" character varying(45) null,
  "CoverImageUrl" character varying(500) null,
  "RelationshipStatus" character varying(50) null,
  "ShowRelationshipStatus" public.VisibilityType null default 'private'::"VisibilityType",
  constraint UserProfile_pkey primary key ("Id"),
  constraint UserProfile_UserName_key unique ("UserName"),
  constraint UserProfile_UserId_fkey foreign KEY ("UserId") references "User" ("Id") on delete CASCADE
) TABLESPACE pg_default;

create index IF not exists idx_user_profile_display_name on public."UserProfile" using btree ("DisplayName") TABLESPACE pg_default;

create index IF not exists idx_user_profile_is_mentor on public."UserProfile" using btree ("IsMentor") TABLESPACE pg_default;

create index IF not exists idx_user_profile_user_id on public."UserProfile" using btree ("UserId") TABLESPACE pg_default;

create index IF not exists idx_user_profile_user_name on public."UserProfile" using btree ("UserName") TABLESPACE pg_default;

create index IF not exists idx_user_profile_privacy on public."UserProfile" using btree ("ShowEmail", "ShowLocation", "ShowBirthdate") TABLESPACE pg_default;

create trigger update_user_profile_updated_at BEFORE
update on "UserProfile" for EACH row
execute FUNCTION update_user_profile_updated_at_column ();