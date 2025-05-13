create table public."Country" (
  "Id" serial not null,
  "IsoCode" character varying(2) not null,
  "Name" character varying(100) not null,
  "OfficialName" character varying(255) not null,
  "Continent" character varying(50) not null,
  "Region" character varying(100) not null,
  "SubRegion" character varying(100) not null,
  "Nationality" character varying(100) not null,
  "PhoneCode" character varying(10) not null,
  "Currency" character varying(50) not null default 'NULL'::character varying,
  "CurrencySymbol" character varying(10) not null default 'NULL'::character varying,
  "Timezones" character varying(255) not null default 'NULL'::character varying,
  "FlagUrl" character varying(255) not null default 'NULL'::character varying,
  "IsActive" boolean not null default true,
  "UpdatedAt" timestamp with time zone not null default CURRENT_TIMESTAMP,
  "CreatedAt" timestamp with time zone not null default CURRENT_TIMESTAMP,
  constraint Country_pkey primary key ("Id"),
  constraint Country_IsoCode_key unique ("IsoCode")
) TABLESPACE pg_default;

create index IF not exists idx_country_continent on public."Country" using btree ("Continent") TABLESPACE pg_default;

create index IF not exists idx_country_is_active on public."Country" using btree ("IsActive") TABLESPACE pg_default;

create index IF not exists idx_country_iso_code on public."Country" using btree ("IsoCode") TABLESPACE pg_default;

create index IF not exists idx_country_name on public."Country" using btree ("Name") TABLESPACE pg_default;

create index IF not exists idx_country_region on public."Country" using btree ("Region") TABLESPACE pg_default;

create index IF not exists idx_country_sub_region on public."Country" using btree ("SubRegion") TABLESPACE pg_default;

create trigger update_country_updated_at BEFORE
update on "Country" for EACH row
execute FUNCTION update_country_updated_at_column ();