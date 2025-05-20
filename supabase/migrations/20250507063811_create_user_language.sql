create table public."UserLanguage" (
  "Id" serial not null,
  "UserId" uuid not null,
  "LanguageId" integer not null,
  "UpdatedAt" timestamp with time zone not null default CURRENT_TIMESTAMP,
  "CreatedAt" timestamp with time zone not null default CURRENT_TIMESTAMP,
  constraint UserLanguage_pkey primary key ("Id"),
  constraint UserLanguage_UserId_LanguageId_key unique ("UserId", "LanguageId"),
  constraint UserLanguage_LanguageId_fkey foreign KEY ("LanguageId") references "Language" ("Id") on delete CASCADE,
  constraint UserLanguage_UserId_fkey foreign KEY ("UserId") references "User" ("Id") on delete CASCADE
) TABLESPACE pg_default;

create index IF not exists idx_user_language_language_id on public."UserLanguage" using btree ("LanguageId") TABLESPACE pg_default;

create index IF not exists idx_user_language_user_id on public."UserLanguage" using btree ("UserId") TABLESPACE pg_default;

create trigger update_user_language_updated_at BEFORE
update on "UserLanguage" for EACH row
execute FUNCTION update_user_language_updated_at_column ();