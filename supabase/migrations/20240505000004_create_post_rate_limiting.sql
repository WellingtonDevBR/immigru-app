-- Create post rate limiting attempt table
CREATE TABLE IF NOT EXISTS "PostRateLimitingAttempt" (
  "Id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  "UserId" UUID NOT NULL REFERENCES "User"("Id"),
  "ActionType" TEXT NOT NULL,
  "IpAddress" TEXT,
  "Metadata" JSONB,
  "CreatedAt" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  "UpdatedAt" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS "idx_post_rate_limiting_user_action" ON "PostRateLimitingAttempt"("UserId", "ActionType");
CREATE INDEX IF NOT EXISTS "idx_post_rate_limiting_created_at" ON "PostRateLimitingAttempt"("CreatedAt");
CREATE INDEX IF NOT EXISTS "idx_post_rate_limiting_ip" ON "PostRateLimitingAttempt"("IpAddress");

-- Add RLS policies
ALTER TABLE "PostRateLimitingAttempt" ENABLE ROW LEVEL SECURITY;

-- Allow insert from authenticated users
CREATE POLICY "Allow insert from authenticated users"
  ON "PostRateLimitingAttempt"
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = "UserId");

-- Allow read from authenticated users for their own attempts
CREATE POLICY "Allow read from authenticated users"
  ON "PostRateLimitingAttempt"
  FOR SELECT
  TO authenticated
  USING (auth.uid() = "UserId");

-- Function to check rate limit
CREATE OR REPLACE FUNCTION check_post_rate_limit(
  user_id UUID,
  action_type TEXT,
  time_window_minutes INT,
  max_attempts INT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  attempt_count INT;
  window_start TIMESTAMP WITH TIME ZONE;
  next_allowed TIMESTAMP WITH TIME ZONE;
  remaining INT;
  reset_seconds INT;
BEGIN
  -- Calculate window start time
  window_start := NOW() - (time_window_minutes || ' minutes')::INTERVAL;
  
  -- Count attempts in window
  SELECT COUNT(*)
  INTO attempt_count
  FROM "PostRateLimitingAttempt"
  WHERE "UserId" = user_id
    AND "ActionType" = action_type
    AND "CreatedAt" > window_start;

  -- Calculate remaining attempts and reset time
  remaining := GREATEST(0, max_attempts - attempt_count);
  
  IF remaining = 0 THEN
    -- Find when the next attempt will be allowed
    SELECT MIN("CreatedAt") + (time_window_minutes || ' minutes')::INTERVAL
    INTO next_allowed
    FROM (
      SELECT "CreatedAt"
      FROM "PostRateLimitingAttempt"
      WHERE "UserId" = user_id
        AND "ActionType" = action_type
        AND "CreatedAt" > window_start
      ORDER BY "CreatedAt" DESC
      LIMIT max_attempts
    ) AS oldest_in_window;
    
    reset_seconds := EXTRACT(EPOCH FROM (next_allowed - NOW()))::INT;
  ELSE
    reset_seconds := 0;
  END IF;

  -- Return result as JSON
  RETURN json_build_object(
    'allowed', remaining > 0,
    'remaining_attempts', remaining,
    'reset_after', reset_seconds
  );
END;
$$;

-- Add trigger for UpdatedAt
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW."UpdatedAt" = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_post_rate_limiting_updated_at
  BEFORE UPDATE ON "PostRateLimitingAttempt"
  FOR EACH ROW
  EXECUTE PROCEDURE update_updated_at_column();
