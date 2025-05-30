create table public."PhotoLike" (
  "Id" uuid not null default gen_random_uuid (),
  "PhotoId" uuid not null,
  "UserId" uuid not null,
  "CreatedAt" timestamp with time zone not null default now(),
  constraint PhotoLike_pkey primary key ("Id"),
  constraint PhotoLike_PhotoId_UserId_key unique ("PhotoId", "UserId"),
  constraint PhotoLike_PhotoId_fkey foreign KEY ("PhotoId") references "Photo" ("Id") on delete CASCADE,
  constraint PhotoLike_UserId_fkey foreign KEY ("UserId") references "User" ("Id") on delete CASCADE
) TABLESPACE pg_default;

create index IF not exists idx_photo_like_photo_id on public."PhotoLike" using btree ("PhotoId") TABLESPACE pg_default;

create trigger photo_like_count_trigger
after INSERT
or DELETE on "PhotoLike" for EACH row
execute FUNCTION update_photo_like_count ();