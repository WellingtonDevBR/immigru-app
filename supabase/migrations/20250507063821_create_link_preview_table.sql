create table public."LinkPreview" (
  "Id" uuid not null default gen_random_uuid (),
  "Url" text not null,
  "Title" text null,
  "Description" text null,
  "ImageUrl" text null,
  "SiteName" text null,
  "FaviconUrl" text null,
  "CreatedAt" timestamp with time zone null default now(),
  "UpdatedAt" timestamp with time zone null default now(),
  "LastUpdated" timestamp with time zone not null default now(),
  constraint LinkPreview_pkey primary key ("Id"),
  constraint LinkPreview_Url_key unique ("Url")
) TABLESPACE pg_default;

create index IF not exists idx_link_preview_last_updated on public."LinkPreview" using btree ("LastUpdated") TABLESPACE pg_default;