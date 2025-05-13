create table public."User" (
  "Id" uuid not null default gen_random_uuid (),
  "Email" character varying(255) not null,
  "PasswordHash" character varying(255) not null,
  "PhoneNumber" character varying(20) null,
  "AuthProvider" public.AuthProvider null default 'email'::"AuthProvider",
  "Role" public.Role null default 'user'::"Role",
  "Status" public.Status null default 'active'::"Status",
  "EmailVerified" boolean null default false,
  "PhoneVerified" boolean null default false,
  "LastLoginAt" timestamp with time zone null,
  "DeletedAt" timestamp with time zone null,
  "ReferralCode" character varying(8) null,
  "LoginStreak" integer null default 0,
  "FailedLoginAttempt" integer null default 0,
  "LastFailedLogin" timestamp with time zone null,
  "TrustScore" integer null default 0,
  "Credits" integer null default 0,
  "Timezone" character varying(50) null,
  "ReferredBy" uuid null,
  "UpdatedAt" timestamp with time zone null default CURRENT_TIMESTAMP,
  "CreatedAt" timestamp with time zone null default CURRENT_TIMESTAMP,
  constraint User_pkey primary key ("Id"),
  constraint User_Email_key unique ("Email"),
  constraint User_ReferralCode_key unique ("ReferralCode"),
  constraint User_ReferredBy_fkey foreign KEY ("ReferredBy") references "User" ("Id")
) TABLESPACE pg_default;

create index IF not exists idx_user_auth_provider on public."User" using btree ("AuthProvider") TABLESPACE pg_default;

create index IF not exists idx_user_email on public."User" using btree ("Email") TABLESPACE pg_default;

create index IF not exists idx_user_phone on public."User" using btree ("PhoneNumber") TABLESPACE pg_default;

create index IF not exists idx_user_referral_code on public."User" using btree ("ReferralCode") TABLESPACE pg_default;

create index IF not exists idx_user_referred_by on public."User" using btree ("ReferredBy") TABLESPACE pg_default;

create index IF not exists idx_user_role on public."User" using btree ("Role") TABLESPACE pg_default;

create index IF not exists idx_user_status on public."User" using btree ("Status") TABLESPACE pg_default;

create trigger generate_user_referral_code BEFORE INSERT on "User" for EACH row
execute FUNCTION generate_referral_code ();

create trigger update_user_updated_at BEFORE
update on "User" for EACH row
execute FUNCTION update_updated_at_column ();