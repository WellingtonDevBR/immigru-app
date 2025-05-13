-- Create security audit log table for tracking security events
CREATE TABLE "SecurityAuditLog" (
    "Id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "UserId" UUID NOT NULL REFERENCES "User"("Id") ON DELETE CASCADE,
    "EventType" VARCHAR(100) NOT NULL,
    "EventData" JSONB NULL,
    "IpAddress" VARCHAR(45) NULL,
    "UserAgent" TEXT NULL,
    "CreatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Add indexes for efficient querying
CREATE INDEX idx_security_audit_log_user_id ON "SecurityAuditLog"("UserId");
CREATE INDEX idx_security_audit_log_event_type ON "SecurityAuditLog"("EventType");
CREATE INDEX idx_security_audit_log_created_at ON "SecurityAuditLog"("CreatedAt");

-- Enable Row Level Security
ALTER TABLE "SecurityAuditLog" ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
-- Only system roles can insert records
CREATE POLICY "System roles can insert audit logs" ON "SecurityAuditLog"
    FOR INSERT
    WITH CHECK (
        auth.role() IN ('service_role', 'authenticated')
    );
