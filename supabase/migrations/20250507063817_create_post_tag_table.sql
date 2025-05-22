create table public."PostTag" (
  "Id" uuid not null default gen_random_uuid (),
  "PostId" uuid not null,
  "Tag" text not null,
  constraint post_tags_pkey primary key ("Id"),
  constraint post_tags_post_id_tag_key unique ("PostId", "Tag"),
  constraint post_tags_post_id_fkey foreign KEY ("PostId") references "Post" ("Id") on delete CASCADE
) TABLESPACE pg_default;