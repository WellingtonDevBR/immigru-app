create table public."ChatMessageRead" (
  "Id" uuid not null default gen_random_uuid (),
  "MessageId" uuid not null,
  "UserId" uuid not null,
  "ReadAt" timestamp with time zone not null default now(),
  constraint ChatMessageRead_pkey primary key ("Id"),
  constraint ChatMessageRead_MessageId_UserId_key unique ("MessageId", "UserId"),
  constraint ChatMessageRead_MessageId_fkey foreign KEY ("MessageId") references "ChatMessage" ("Id")
) TABLESPACE pg_default;