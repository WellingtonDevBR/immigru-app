create table public."ChatParticipant" (
  "Id" uuid not null default gen_random_uuid (),
  "ChatRoomId" uuid not null,
  "UserId" uuid not null,
  "Role" text not null default 'member'::text,
  "JoinedAt" timestamp with time zone not null default now(),
  "LeftAt" timestamp with time zone null,
  "IsMuted" boolean not null default false,
  "DeletedAt" timestamp with time zone null,
  constraint ChatParticipant_pkey primary key ("Id"),
  constraint ChatParticipant_ChatRoomId_UserId_key unique ("ChatRoomId", "UserId"),
  constraint ChatParticipant_ChatRoomId_fkey foreign KEY ("ChatRoomId") references "ChatRoom" ("Id"),
  constraint ChatParticipant_Role_check check (
    (
      "Role" = any (array['member'::text, 'admin'::text])
    )
  )
) TABLESPACE pg_default;