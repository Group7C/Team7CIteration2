-- Add meeting date fields to the project table

-- Add next_meeting_date column
ALTER TABLE project 
ADD COLUMN IF NOT EXISTS next_meeting_date TIMESTAMP;

-- Add last_meeting_date column
ALTER TABLE project 
ADD COLUMN IF NOT EXISTS last_meeting_date TIMESTAMP;

-- Create index for faster querying
CREATE INDEX IF NOT EXISTS idx_project_next_meeting ON project(next_meeting_date);
CREATE INDEX IF NOT EXISTS idx_project_last_meeting ON project(last_meeting_date);

-- Add comment explaining the columns
COMMENT ON COLUMN project.next_meeting_date IS 'Date of the next scheduled meeting for this project';
COMMENT ON COLUMN project.last_meeting_date IS 'Date of the last held meeting for this project';
