create table public."PostMedia" (
  "Id" uuid not null default gen_random_uuid (),
  "PostId" uuid not null,
  "MediaUrl" text not null,
  "MediaType" text not null,
  "Position" integer not null,
  "ThumbnailUrl" text null,
  "CreatedAt" timestamp with time zone not null default now(),
  "UpdatedAt" timestamp with time zone not null default now(),
  constraint PostMedia_pkey primary key ("Id"),
  constraint PostMedia_PostId_fkey foreign KEY ("PostId") references "Post" ("Id") on delete CASCADE,
  constraint PostMedia_MediaType_check check (
    (
      "MediaType" = any (array['image'::text, 'video'::text])
    )
  )
) TABLESPACE pg_default;

create index IF not exists idx_post_media_post_id on public."PostMedia" using btree ("PostId") TABLESPACE pg_default;

create trigger update_post_media_updated_at BEFORE
update on "PostMedia" for EACH row
execute FUNCTION update_post_media_updated_at_column ();