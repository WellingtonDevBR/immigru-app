create table public."ImmiGrove" (
  "Id" uuid not null default gen_random_uuid (),
  "Name" text not null,
  "Slug" text not null,
  "Description" text null,
  "Type" public.ImmiGroveType null,
  "CountryId" integer null,
  "VisaId" integer null,
  "LanguageId" integer null,
  "IsPublic" boolean not null default true,
  "CreatedBy" uuid not null,
  "CoverImageUrl" text null,
  "CreatedAt" timestamp with time zone not null default now(),
  "UpdatedAt" timestamp with time zone not null default now(),
  constraint ImmiGrove_pkey primary key ("Id"),
  constraint ImmiGrove_Slug_key unique ("Slug"),
  constraint ImmiGrove_CountryId_fkey foreign KEY ("CountryId") references "Country" ("Id"),
  constraint ImmiGrove_LanguageId_fkey foreign KEY ("LanguageId") references "Language" ("Id"),
  constraint ImmiGrove_VisaId_fkey foreign KEY ("VisaId") references "Visa" ("Id")
) TABLESPACE pg_default;

create trigger update_immigrove_timestamp BEFORE
update on "ImmiGrove" for EACH row
execute FUNCTION update_updated_at_column ();