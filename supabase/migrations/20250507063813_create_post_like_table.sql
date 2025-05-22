create table public."PostLike" (
  "Id" uuid not null default gen_random_uuid (),
  "PostId" uuid not null,
  "UserId" uuid not null,
  "CreatedAt" timestamp with time zone not null default now(),
  constraint post_likes_pkey primary key ("Id"),
  constraint post_likes_post_id_user_id_key unique ("PostId", "UserId"),
  constraint PostLike_PostId_fkey foreign KEY ("PostId") references "Post" ("Id") on update CASCADE on delete CASCADE,
  constraint post_likes_user_id_fkey foreign KEY ("UserId") references auth.users (id) on delete CASCADE
) TABLESPACE pg_default;