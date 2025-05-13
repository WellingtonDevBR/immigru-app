create table public."CountryLanguage" (
  "Id" serial not null,
  "CountryId" integer not null,
  "LanguageId" integer not null,
  "UpdatedAt" timestamp with time zone not null default CURRENT_TIMESTAMP,
  "CreatedAt" timestamp with time zone not null default CURRENT_TIMESTAMP,
  constraint CountryLanguage_pkey primary key ("Id"),
  constraint CountryLanguage_CountryId_LanguageId_key unique ("CountryId", "LanguageId"),
  constraint CountryLanguage_CountryId_fkey foreign KEY ("CountryId") references "Country" ("Id") on delete CASCADE,
  constraint CountryLanguage_LanguageId_fkey foreign KEY ("LanguageId") references "Language" ("Id") on delete CASCADE
) TABLESPACE pg_default;

create index IF not exists idx_country_language_country_id on public."CountryLanguage" using btree ("CountryId") TABLESPACE pg_default;

create index IF not exists idx_country_language_language_id on public."CountryLanguage" using btree ("LanguageId") TABLESPACE pg_default;

create trigger update_country_language_updated_at BEFORE
update on "CountryLanguage" for EACH row
execute FUNCTION update_country_language_updated_at_column ();