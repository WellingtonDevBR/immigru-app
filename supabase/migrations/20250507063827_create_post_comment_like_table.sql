create table public."PostCommentLike" (
  "Id" uuid not null default gen_random_uuid (),
  "CommentId" uuid not null,
  "UserId" uuid not null,
  "CreatedAt" timestamp with time zone not null default now(),
  constraint post_comment_likes_pkey primary key ("Id"),
  constraint post_comment_likes_unique unique ("CommentId", "UserId"),
  constraint postcommentlike_commentid_fkey foreign KEY ("CommentId") references "PostComment" ("Id") on delete CASCADE,
  constraint postcommentlike_userid_fkey foreign KEY ("UserId") references auth.users (id) on delete CASCADE
) TABLESPACE pg_default;