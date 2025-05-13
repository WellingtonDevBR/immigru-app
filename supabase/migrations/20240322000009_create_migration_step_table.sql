create table public."MigrationStep" (
  "Id" serial not null,
  "UserId" uuid not null,
  "Order" integer not null,
  "CountryId" integer not null,
  "VisaId" integer null,
  "IsCurrent" boolean not null default false,
  "IsTarget" boolean not null default false,
  "ArrivedAt" date null,
  "LeftAt" date null,
  "Notes" text null,
  "MigrationReason" public.MigrationReason null,
  "WasSuccessful" boolean not null default false,
  "UpdatedAt" timestamp with time zone not null default CURRENT_TIMESTAMP,
  "CreatedAt" timestamp with time zone not null default CURRENT_TIMESTAMP,
  constraint MigrationStep_pkey primary key ("Id"),
  constraint MigrationStep_UserId_Order_key unique ("UserId", "Order"),
  constraint MigrationStep_CountryId_fkey foreign KEY ("CountryId") references "Country" ("Id") on delete CASCADE,
  constraint MigrationStep_UserId_fkey foreign KEY ("UserId") references "User" ("Id") on delete CASCADE,
  constraint MigrationStep_VisaId_fkey foreign KEY ("VisaId") references "Visa" ("Id") on delete CASCADE
) TABLESPACE pg_default;

create index IF not exists idx_migration_step_country_id on public."MigrationStep" using btree ("CountryId") TABLESPACE pg_default;

create index IF not exists idx_migration_step_is_current on public."MigrationStep" using btree ("IsCurrent") TABLESPACE pg_default;

create index IF not exists idx_migration_step_is_target on public."MigrationStep" using btree ("IsTarget") TABLESPACE pg_default;

create index IF not exists idx_migration_step_migration_reason on public."MigrationStep" using btree ("MigrationReason") TABLESPACE pg_default;

create index IF not exists idx_migration_step_order on public."MigrationStep" using btree ("Order") TABLESPACE pg_default;

create index IF not exists idx_migration_step_user_id on public."MigrationStep" using btree ("UserId") TABLESPACE pg_default;

create index IF not exists idx_migration_step_visa_id on public."MigrationStep" using btree ("VisaId") TABLESPACE pg_default;

create index IF not exists idx_migration_step_was_successful on public."MigrationStep" using btree ("WasSuccessful") TABLESPACE pg_default;

create trigger update_migration_step_updated_at BEFORE
update on "MigrationStep" for EACH row
execute FUNCTION update_migration_step_updated_at_column ();