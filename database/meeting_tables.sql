-- Schema updates for meeting tracking

-- Create meetings table
CREATE TABLE IF NOT EXISTS meeting (
    meeting_id SERIAL PRIMARY KEY,
    project_uid INTEGER NOT NULL REFERENCES project(project_uid) ON DELETE CASCADE,
    meeting_date TIMESTAMP NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create meeting_attendance junction table for who attended each meeting
CREATE TABLE IF NOT EXISTS meeting_attendance (
    meeting_id INTEGER REFERENCES meeting(meeting_id) ON DELETE CASCADE,
    user_id INTEGER REFERENCES online_user(user_id) ON DELETE CASCADE,
    attended BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (meeting_id, user_id)
);

-- Create index for faster querying of meetings by project
CREATE INDEX idx_meeting_project ON meeting(project_uid);

-- Add comment explaining the schema
COMMENT ON TABLE meeting IS 'Stores project meeting details including date and notes';
COMMENT ON TABLE meeting_attendance IS 'Junction table tracking which users attended which meetings';
