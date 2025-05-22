create table public."UserConnection" (
  "Id" uuid not null default gen_random_uuid (),
  "SenderId" uuid not null,
  "ReceiverId" uuid not null,
  "Status" text not null,
  "Message" text null,
  "SentAt" timestamp with time zone not null default now(),
  "RespondedAt" timestamp with time zone null,
  "CreatedAt" timestamp with time zone not null default now(),
  "UpdatedAt" timestamp with time zone not null default now(),
  constraint UserConnection_pkey primary key ("Id"),
  constraint UserConnection_SenderId_ReceiverId_key unique ("SenderId", "ReceiverId"),
  constraint UserConnection_ReceiverId_fkey foreign KEY ("ReceiverId") references auth.users (id),
  constraint UserConnection_SenderId_fkey foreign KEY ("SenderId") references auth.users (id),
  constraint UserConnection_Status_check check (
    (
      "Status" = any (
        array[
          'pending'::text,
          'accepted'::text,
          'declined'::text,
          'blocked'::text
        ]
      )
    )
  )
) TABLESPACE pg_default;

create trigger update_user_connection_updated_at BEFORE
update on "UserConnection" for EACH row
execute FUNCTION update_updated_at_column ();