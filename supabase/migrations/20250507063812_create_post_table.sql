create table public."Post" (
  "Id" uuid not null default gen_random_uuid (),
  "UserId" uuid not null,
  "Type" public.post_type not null default 'Update'::post_type,
  "Content" text null,
  "MediaUrl" text null,
  "Location" text null,
  "Language" public.post_language not null default 'English'::post_language,
  "Visibility" public.post_visibility not null default 'Public'::post_visibility,
  "Tags" jsonb null default '[]'::jsonb,
  "DeletedAt" timestamp with time zone null,
  "UpdatedAt" timestamp with time zone not null default now(),
  "CreatedAt" timestamp with time zone not null default now(),
  "ImmiGroveId" uuid null,
  "IsFeatured" boolean not null default false,
  "IsPinned" boolean not null default false,
  constraint posts_pkey primary key ("Id"),
  constraint Post_ImmiGroveId_fkey foreign KEY ("ImmiGroveId") references "ImmiGrove" ("Id"),
  constraint fk_post_user foreign KEY ("UserId") references "User" ("Id") on delete CASCADE,
  constraint posts_user_id_fkey foreign KEY ("UserId") references auth.users (id) on delete CASCADE
) TABLESPACE pg_default;

create trigger update_posts_updated_at BEFORE
update on "Post" for EACH row
execute FUNCTION update_updated_at_column ();