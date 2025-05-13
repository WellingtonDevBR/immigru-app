create table public."Visa" (
  "Id" serial not null,
  "CountryId" integer not null,
  "VisaName" character varying(255) not null,
  "VisaCode" character varying(20) not null,
  "Type" character varying not null,
  "PathwayToPR" boolean not null default false,
  "AllowsWork" boolean not null default false,
  "Description" text not null,
  "ExternalLink" character varying(255) null,
  "IsPublic" boolean not null default true,
  "UpdatedAt" timestamp with time zone not null default CURRENT_TIMESTAMP,
  "CreatedAt" timestamp with time zone not null default CURRENT_TIMESTAMP,
  constraint Visa_pkey primary key ("Id"),
  constraint Visa_CountryId_VisaCode_key unique ("CountryId", "VisaCode"),
  constraint Visa_CountryId_fkey foreign KEY ("CountryId") references "Country" ("Id") on delete CASCADE
) TABLESPACE pg_default;

create index IF not exists idx_visa_allows_work on public."Visa" using btree ("AllowsWork") TABLESPACE pg_default;

create index IF not exists idx_visa_country_id on public."Visa" using btree ("CountryId") TABLESPACE pg_default;

create index IF not exists idx_visa_is_public on public."Visa" using btree ("IsPublic") TABLESPACE pg_default;

create index IF not exists idx_visa_pathway_to_pr on public."Visa" using btree ("PathwayToPR") TABLESPACE pg_default;

create index IF not exists idx_visa_visa_code on public."Visa" using btree ("VisaCode") TABLESPACE pg_default;

create index IF not exists idx_visa_type on public."Visa" using btree ("Type") TABLESPACE pg_default;

create trigger update_visa_updated_at BEFORE
update on "Visa" for EACH row
execute FUNCTION update_visa_updated_at_column ();