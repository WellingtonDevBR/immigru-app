create table public."Interest" (
  "Id" serial not null,
  "Name" character varying(100) not null,
  "Category" character varying(100) not null,
  "IsActive" boolean not null default true,
  "UpdatedAt" timestamp with time zone not null default CURRENT_TIMESTAMP,
  "CreatedAt" timestamp with time zone not null default CURRENT_TIMESTAMP,
  constraint Interest_pkey primary key ("Id")
) TABLESPACE pg_default;

create index IF not exists idx_interest_category on public."Interest" using btree ("Category") TABLESPACE pg_default;

create index IF not exists idx_interest_is_active on public."Interest" using btree ("IsActive") TABLESPACE pg_default;

create index IF not exists idx_interest_name on public."Interest" using btree ("Name") TABLESPACE pg_default;

create trigger update_interest_updated_at BEFORE
update on "Interest" for EACH row
execute FUNCTION update_interest_updated_at_column ();