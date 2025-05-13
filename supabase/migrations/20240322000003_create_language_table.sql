create table public."Language" (
  "Id" serial not null,
  "Code" character varying(10) not null,
  "Name" character varying(100) not null,
  "NativeName" character varying(100) not null,
  "Direction" character varying not null,
  "IsActive" boolean not null default true,
  "UpdatedAt" timestamp with time zone not null default CURRENT_TIMESTAMP,
  "CreatedAt" timestamp with time zone not null default CURRENT_TIMESTAMP,
  constraint Language_pkey primary key ("Id"),
  constraint Language_Code_key unique ("Code")
) TABLESPACE pg_default;

create index IF not exists idx_language_code on public."Language" using btree ("Code") TABLESPACE pg_default;

create index IF not exists idx_language_is_active on public."Language" using btree ("IsActive") TABLESPACE pg_default;

create index IF not exists idx_language_name on public."Language" using btree ("Name") TABLESPACE pg_default;

create trigger update_language_updated_at BEFORE
update on "Language" for EACH row
execute FUNCTION update_language_updated_at_column ();