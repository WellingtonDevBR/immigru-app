create table public."UserInterest" (
  "Id" serial not null,
  "UserId" uuid not null,
  "InterestId" integer not null,
  "UpdatedAt" timestamp with time zone not null default CURRENT_TIMESTAMP,
  "CreatedAt" timestamp with time zone not null default CURRENT_TIMESTAMP,
  constraint UserInterest_pkey primary key ("Id"),
  constraint UserInterest_UserId_InterestId_key unique ("UserId", "InterestId"),
  constraint UserInterest_InterestId_fkey foreign KEY ("InterestId") references "Interest" ("Id") on delete CASCADE,
  constraint UserInterest_UserId_fkey foreign KEY ("UserId") references "User" ("Id") on delete CASCADE
) TABLESPACE pg_default;

create index IF not exists idx_user_interest_interest_id on public."UserInterest" using btree ("InterestId") TABLESPACE pg_default;

create index IF not exists idx_user_interest_user_id on public."UserInterest" using btree ("UserId") TABLESPACE pg_default;

create trigger update_user_interest_updated_at BEFORE
update on "UserInterest" for EACH row
execute FUNCTION update_user_interest_updated_at_column ();