create table public."Photo" (
  "Id" uuid not null default gen_random_uuid (),
  "AlbumId" uuid not null,
  "UserId" uuid not null,
  "StoragePath" character varying(500) not null,
  "Url" character varying(500) not null,
  "ThumbnailUrl" character varying(500) null,
  "Title" character varying(200) null,
  "Description" text null,
  "Width" integer null,
  "Height" integer null,
  "Size" integer null,
  "Format" character varying(10) null,
  "UpdatedAt" timestamp with time zone not null default CURRENT_TIMESTAMP,
  "CreatedAt" timestamp with time zone not null default CURRENT_TIMESTAMP,
  "Visibility" public.AlbumVisibilityType null,
  "LikeCount" integer not null default 0,
  "CommentCount" integer not null default 0,
  "PostId" uuid null,
  constraint Photo_pkey primary key ("Id"),
  constraint Photo_AlbumId_fkey foreign KEY ("AlbumId") references "PhotoAlbum" ("Id") on delete CASCADE,
  constraint Photo_PostId_fkey foreign KEY ("PostId") references "Post" ("Id") on delete set null,
  constraint Photo_UserId_fkey foreign KEY ("UserId") references "User" ("Id") on delete CASCADE
) TABLESPACE pg_default;

create index IF not exists idx_photo_album_id on public."Photo" using btree ("AlbumId") TABLESPACE pg_default;

create index IF not exists idx_photo_user_id on public."Photo" using btree ("UserId") TABLESPACE pg_default;

create index IF not exists idx_photo_post_id on public."Photo" using btree ("PostId") TABLESPACE pg_default;

create trigger update_photo_count_delete
after DELETE on "Photo" for EACH row
execute FUNCTION update_photo_count ();

create trigger update_photo_count_insert
after INSERT on "Photo" for EACH row
execute FUNCTION update_photo_count ();

create trigger update_photo_updated_at BEFORE
update on "Photo" for EACH row
execute FUNCTION update_photo_updated_at_column ();