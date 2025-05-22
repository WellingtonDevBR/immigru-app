create table public."PostComment" (
  "Id" uuid not null default gen_random_uuid (),
  "PostId" uuid not null,
  "UserId" uuid not null,
  "ParentCommentId" uuid null,
  "Content" text not null,
  "UpdatedAt" timestamp with time zone not null default now(),
  "CreatedAt" timestamp with time zone not null default now(),
  constraint comments_pkey primary key ("Id"),
  constraint Comment_UserId_fkey foreign KEY ("UserId") references "User" ("Id"),
  constraint comments_parent_comment_id_fkey foreign KEY ("ParentCommentId") references "PostComment" ("Id") on delete CASCADE,
  constraint comments_post_id_fkey foreign KEY ("PostId") references "Post" ("Id") on delete CASCADE,
  constraint comments_user_id_fkey foreign KEY ("UserId") references auth.users (id) on delete CASCADE
) TABLESPACE pg_default;

create trigger update_comments_updated_at BEFORE
update on "PostComment" for EACH row
execute FUNCTION update_updated_at_column ();