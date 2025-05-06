-- Add status column to track task status
ALTER TABLE task ADD COLUMN status VARCHAR(20) DEFAULT 'todo';

-- Add assignee_id column to track who the task is assigned to
ALTER TABLE task ADD COLUMN assignee_id INTEGER;

-- Add foreign key constraint to link assignee_id to online_user table
ALTER TABLE task ADD CONSTRAINT task_assignee_fk FOREIGN KEY (assignee_id) REFERENCES online_user(user_id);

-- Create an index on status for faster queries
CREATE INDEX task_status_idx ON task(status);

-- Add constraint to ensure valid status values
ALTER TABLE task ADD CONSTRAINT task_status_check CHECK (status IN ('todo', 'in_progress', 'completed'));