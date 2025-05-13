create table public."UserBlock" (
  "Id" uuid not null default extensions.uuid_generate_v4 (),
  "BlockerId" uuid not null,
  "BlockedId" uuid not null,
  "Reason" text null,
  "CreatedAt" timestamp with time zone not null default now(),
  "UpdatedAt" timestamp with time zone not null default now(),
  constraint UserBlock_pkey primary key ("Id"),
  constraint UserBlock_BlockerId_BlockedId_key unique ("BlockerId", "BlockedId"),
  constraint UserBlock_BlockedId_fkey foreign KEY ("BlockedId") references "User" ("Id") on delete CASCADE,
  constraint UserBlock_BlockerId_fkey foreign KEY ("BlockerId") references "User" ("Id") on delete CASCADE
) TABLESPACE pg_default;

create index IF not exists idx_user_block_blocker_id on public."UserBlock" using btree ("BlockerId") TABLESPACE pg_default;

create index IF not exists idx_user_block_blocked_id on public."UserBlock" using btree ("BlockedId") TABLESPACE pg_default;