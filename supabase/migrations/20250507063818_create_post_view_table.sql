create table public."PostView" (
  "Id" uuid not null default gen_random_uuid (),
  "UserId" uuid not null,
  "PostId" uuid not null,
  "ViewedAt" timestamp with time zone not null default now(),
  "TimeSpentSeconds" integer null default 0,
  constraint PostView_pkey primary key ("Id"),
  constraint PostView_UserId_PostId_key unique ("UserId", "PostId")
) TABLESPACE pg_default;