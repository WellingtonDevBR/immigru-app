-- Create RPC functions for auth rate limiting
-- These functions enable secure interaction with the AuthRateLimitingAttempt table

-- Function to get authentication rate limiting attempts
CREATE OR REPLACE FUNCTION get_auth_rate_limiting_attempts(
  identifier_param TEXT,
  attempt_type_param TEXT,
  time_window_param INTEGER
)
RETURNS SETOF "AuthRateLimitingAttempt" AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM "AuthRateLimitingAttempt"
  WHERE "Identifier" = identifier_param
    AND "AttemptType" = attempt_type_param
    AND "CreatedAt" >= NOW() - (time_window_param * INTERVAL '1 second')
  ORDER BY "CreatedAt" DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to record an authentication rate limiting attempt
CREATE OR REPLACE FUNCTION record_auth_rate_limiting_attempt(
  identifier_param TEXT,
  attempt_type_param TEXT,
  successful_param BOOLEAN,
  ip_address_param TEXT DEFAULT NULL,
  metadata_param JSONB DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  inserted_id UUID;
BEGIN
  INSERT INTO "AuthRateLimitingAttempt" (
    "Identifier",
    "AttemptType",
    "Successful",
    "IpAddress",
    "Metadata",
    "CreatedAt"
  ) VALUES (
    identifier_param,
    attempt_type_param,
    successful_param,
    ip_address_param,
    metadata_param,
    NOW()
  )
  RETURNING "Id" INTO inserted_id;
  
  RETURN inserted_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant access to authenticated users
GRANT EXECUTE ON FUNCTION get_auth_rate_limiting_attempts TO authenticated;
GRANT EXECUTE ON FUNCTION record_auth_rate_limiting_attempt TO authenticated;

-- Create a function to clear old auth rate limiting attempts (for maintenance)
CREATE OR REPLACE FUNCTION clear_old_auth_rate_limiting_attempts(days_to_keep INTEGER DEFAULT 30)
RETURNS INTEGER AS $$
DECLARE
  deleted_count INTEGER;
BEGIN
  DELETE FROM "AuthRateLimitingAttempt"
  WHERE "CreatedAt" < NOW() - (days_to_keep * INTERVAL '1 day')
  RETURNING COUNT(*) INTO deleted_count;
  
  RETURN deleted_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- This function should only be accessible to service_role
REVOKE ALL ON FUNCTION clear_old_auth_rate_limiting_attempts FROM PUBLIC;
REVOKE ALL ON FUNCTION clear_old_auth_rate_limiting_attempts FROM authenticated;
GRANT EXECUTE ON FUNCTION clear_old_auth_rate_limiting_attempts TO service_role;
