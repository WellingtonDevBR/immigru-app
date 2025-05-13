create table public."AuthRateLimitingAttempt" (
  "Id" uuid not null default gen_random_uuid (),
  "Identifier" text not null,
  "AttemptType" text not null,
  "Successful" boolean not null default false,
  "IpAddress" text null,
  "Metadata" jsonb null,
  "CreatedAt" timestamp with time zone not null default now(),
  constraint AuthRateLimitingAttempt_pkey primary key ("Id")
) TABLESPACE pg_default;

create index IF not exists idx_auth_rate_limiting_identifier on public."AuthRateLimitingAttempt" using btree ("Identifier") TABLESPACE pg_default;

create index IF not exists idx_auth_rate_limiting_attempt_type on public."AuthRateLimitingAttempt" using btree ("AttemptType") TABLESPACE pg_default;

create index IF not exists idx_auth_rate_limiting_created_at on public."AuthRateLimitingAttempt" using btree ("CreatedAt") TABLESPACE pg_default;

create index IF not exists idx_auth_rate_limiting_combined on public."AuthRateLimitingAttempt" using btree (
  "Identifier",
  "AttemptType",
  "Successful",
  "CreatedAt"
) TABLESPACE pg_default;

create index IF not exists idx_auth_rate_limiting_cleanup on public."AuthRateLimitingAttempt" using btree ("CreatedAt") TABLESPACE pg_default;

create trigger trigger_cleanup_auth_attempts
after INSERT on "AuthRateLimitingAttempt" for EACH STATEMENT
execute FUNCTION cleanup_old_auth_attempts ();