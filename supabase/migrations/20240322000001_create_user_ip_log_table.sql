create table public."UserIpLog" (
  "Id" serial not null,
  "UserId" uuid not null,
  "IPAddress" character varying(45) null,
  "Location" character varying(255) null,
  "Device" character varying(255) null,
  "UserAgent" character varying(255) not null,
  "LoginMethod" public.LoginMethod null,
  "GeoData" jsonb null,
  "IsSuccess" boolean not null default false,
  "AttemptAt" timestamp with time zone not null default CURRENT_TIMESTAMP,
  "CreatedAt" timestamp with time zone not null default CURRENT_TIMESTAMP,
  constraint UserIpLog_pkey primary key ("Id"),
  constraint UserIpLog_UserId_fkey foreign KEY ("UserId") references "User" ("Id")
) TABLESPACE pg_default;

create index IF not exists idx_user_ip_log_attempt_at on public."UserIpLog" using btree ("AttemptAt") TABLESPACE pg_default;

create index IF not exists idx_user_ip_log_ip_address on public."UserIpLog" using btree ("IPAddress") TABLESPACE pg_default;

create index IF not exists idx_user_ip_log_is_success on public."UserIpLog" using btree ("IsSuccess") TABLESPACE pg_default;

create index IF not exists idx_user_ip_log_login_method on public."UserIpLog" using btree ("LoginMethod") TABLESPACE pg_default;

create index IF not exists idx_user_ip_log_user_id on public."UserIpLog" using btree ("UserId") TABLESPACE pg_default;