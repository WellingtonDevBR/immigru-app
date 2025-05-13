create table public."UserImmiGrove" (
  "Id" uuid not null default gen_random_uuid (),
  "UserId" uuid not null,
  "ImmiGroveId" uuid not null,
  "IsAdmin" boolean not null default false,
  "JoinedAt" timestamp with time zone not null default now(),
  "DeletedAt" timestamp with time zone null,
  "CreatedAt" timestamp with time zone not null default now(),
  "UpdatedAt" timestamp with time zone not null default now(),
  constraint UserImmiGrove_pkey primary key ("Id"),
  constraint UserImmiGrove_UserId_ImmiGroveId_key unique ("UserId", "ImmiGroveId"),
  constraint UserImmiGrove_ImmiGroveId_fkey foreign KEY ("ImmiGroveId") references "ImmiGrove" ("Id") on delete CASCADE
) TABLESPACE pg_default;

create trigger update_user_immigrove_timestamp BEFORE
update on "UserImmiGrove" for EACH row
execute FUNCTION update_updated_at_column ();