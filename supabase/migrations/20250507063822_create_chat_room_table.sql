create table public."ChatRoom" (
  "Id" uuid not null default gen_random_uuid (),
  "Type" text not null,
  "Name" text null,
  "CreatedBy" uuid not null,
  "CreatedAt" timestamp with time zone not null default now(),
  "UpdatedAt" timestamp with time zone not null default now(),
  "DeletedAt" timestamp with time zone null,
  constraint ChatRoom_pkey primary key ("Id"),
  constraint ChatRoom_Type_check check (
    (
      "Type" = any (array['one-on-one'::text, 'group'::text])
    )
  )
) TABLESPACE pg_default;

create trigger update_chatroom_updated_at BEFORE
update on "ChatRoom" for EACH row
execute FUNCTION update_chatroom_updated_at_column ();