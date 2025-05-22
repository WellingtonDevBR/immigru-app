create table public."PostScore" (
  "Id" uuid not null default gen_random_uuid (),
  "PostId" uuid not null,
  "UserId" uuid not null,
  "Score" double precision not null,
  "CalculatedAt" timestamp with time zone not null default now(),
  constraint PostScore_pkey primary key ("Id"),
  constraint PostScore_UserId_PostId_key unique ("UserId", "PostId")
) TABLESPACE pg_default;