create table public."PhotoAlbum" (
  "Id" uuid not null default gen_random_uuid (),
  "UserId" uuid not null,
  "Name" character varying(100) not null,
  "Description" text null,
  "CoverPhotoId" uuid null,
  "Visibility" public.AlbumVisibilityType null default 'public'::"AlbumVisibilityType",
  "PhotoCount" integer null default 0,
  "UpdatedAt" timestamp with time zone not null default CURRENT_TIMESTAMP,
  "CreatedAt" timestamp with time zone not null default CURRENT_TIMESTAMP,
  constraint PhotoAlbum_pkey primary key ("Id"),
  constraint FK_PhotoAlbum_CoverPhoto foreign KEY ("CoverPhotoId") references "Photo" ("Id") on delete set null deferrable initially DEFERRED,
  constraint PhotoAlbum_UserId_fkey foreign KEY ("UserId") references "User" ("Id") on delete CASCADE
) TABLESPACE pg_default;

create index IF not exists idx_photo_album_user_id on public."PhotoAlbum" using btree ("UserId") TABLESPACE pg_default;

create index IF not exists idx_photo_album_visibility on public."PhotoAlbum" using btree ("Visibility") TABLESPACE pg_default;

create trigger sync_album_photo_visibility_trigger
after
update on "PhotoAlbum" for EACH row when (
  old."Visibility" is distinct from new."Visibility"
)
execute FUNCTION sync_album_photo_visibility ();

create trigger update_photo_album_updated_at BEFORE
update on "PhotoAlbum" for EACH row
execute FUNCTION update_photo_album_updated_at_column ();