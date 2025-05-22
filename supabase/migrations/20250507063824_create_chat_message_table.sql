create table public."ChatMessage" (
  "Id" uuid not null default gen_random_uuid (),
  "ChatRoomId" uuid not null,
  "SenderId" uuid not null,
  "Content" text null,
  "ContentType" text not null default 'text'::text,
  "MediaUrl" text null,
  "CreatedAt" timestamp with time zone not null default now(),
  "UpdatedAt" timestamp with time zone not null default now(),
  "IsEdited" boolean not null default false,
  "DeletedAt" timestamp with time zone null,
  constraint ChatMessage_pkey primary key ("Id"),
  constraint ChatMessage_ChatRoomId_fkey foreign KEY ("ChatRoomId") references "ChatRoom" ("Id"),
  constraint ChatMessage_ContentType_check check (
    (
      "ContentType" = any (array['text'::text, 'image'::text, 'file'::text])
    )
  )
) TABLESPACE pg_default;

create trigger on_chat_message_inserted
after INSERT on "ChatMessage" for EACH row
execute FUNCTION handle_chat_message_notification ();

create trigger update_chatmessage_updated_at BEFORE
update on "ChatMessage" for EACH row
execute FUNCTION update_chatmessage_updated_at_column ();