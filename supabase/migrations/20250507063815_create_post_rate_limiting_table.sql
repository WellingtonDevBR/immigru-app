create table public."PostRateLimitingAttempt" (
  "Id" uuid not null default gen_random_uuid (),
  "UserId" uuid not null,
  "ActionType" character varying(50) not null,
  "IpAddress" character varying(45) null,
  "Metadata" jsonb null,
  "CreatedAt" timestamp with time zone not null default CURRENT_TIMESTAMP,
  constraint PostRateLimitingAttempt_pkey primary key ("Id"),
  constraint PostRateLimitingAttempt_UserId_fkey foreign KEY ("UserId") references "User" ("Id") on delete CASCADE
) TABLESPACE pg_default;

create index IF not exists idx_post_rate_limit_user_id on public."PostRateLimitingAttempt" using btree ("UserId") TABLESPACE pg_default;

create index IF not exists idx_post_rate_limit_action_type on public."PostRateLimitingAttempt" using btree ("ActionType") TABLESPACE pg_default;

create index IF not exists idx_post_rate_limit_created_at on public."PostRateLimitingAttempt" using btree ("CreatedAt") TABLESPACE pg_default;

create index IF not exists idx_post_rate_limiting_user_action on public."PostRateLimitingAttempt" using btree ("UserId", "ActionType") TABLESPACE pg_default;

create index IF not exists idx_post_rate_limiting_created_at on public."PostRateLimitingAttempt" using btree ("CreatedAt") TABLESPACE pg_default;

create index IF not exists idx_post_rate_limiting_ip on public."PostRateLimitingAttempt" using btree ("IpAddress") TABLESPACE pg_default;

create trigger update_post_rate_limiting_updated_at BEFORE
update on "PostRateLimitingAttempt" for EACH row
execute FUNCTION update_updated_at_column ();