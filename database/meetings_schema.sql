-- Meeting tables for storing meeting data with attendance

-- Table for storing meeting details
CREATE TABLE IF NOT EXISTS meeting (
    meeting_id SERIAL PRIMARY KEY,
    project_uid INTEGER NOT NULL REFERENCES project(project_uid) ON DELETE CASCADE,
    meeting_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    title VARCHAR(255),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table for tracking attendance at meetings
CREATE TABLE IF NOT EXISTS meeting_attendance (
    attendance_id SERIAL PRIMARY KEY,
    meeting_id INTEGER NOT NULL REFERENCES meeting(meeting_id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES online_user(user_id) ON DELETE CASCADE,
    attended BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE(meeting_id, user_id)
);

-- Sample queries

-- Get all meetings for a project
SELECT 
    m.meeting_id, 
    m.meeting_date, 
    m.title, 
    m.notes,
    COUNT(ma.user_id) as total_attendees,
    SUM(CASE WHEN ma.attended THEN 1 ELSE 0 END) as present_attendees
FROM meeting m
LEFT JOIN meeting_attendance ma ON m.meeting_id = ma.meeting_id
WHERE m.project_uid = :project_id
GROUP BY m.meeting_id
ORDER BY m.meeting_date DESC;

-- Get meeting details with attendees
SELECT 
    m.meeting_id, 
    m.project_uid,
    m.meeting_date, 
    m.title, 
    m.notes,
    p.proj_name,
    u.user_id,
    u.username,
    u.email,
    ma.attended
FROM meeting m
JOIN project p ON m.project_uid = p.project_uid
LEFT JOIN meeting_attendance ma ON m.meeting_id = ma.meeting_id
LEFT JOIN online_user u ON ma.user_id = u.user_id
WHERE m.meeting_id = :meeting_id;

-- Get contribution metrics (meeting attendance + task completion)
WITH meeting_stats AS (
    SELECT 
        u.user_id,
        COUNT(m.meeting_id) as total_meetings,
        SUM(CASE WHEN ma.attended THEN 1 ELSE 0 END) as meetings_attended
    FROM online_user u
    JOIN user_project up ON u.user_id = up.user_id
    LEFT JOIN meeting m ON m.project_uid = up.project_uid
    LEFT JOIN meeting_attendance ma ON ma.meeting_id = m.meeting_id AND ma.user_id = u.user_id
    WHERE up.project_uid = :project_id
    GROUP BY u.user_id
),
task_stats AS (
    SELECT 
        u.user_id,
        COUNT(t.task_id) as total_tasks,
        SUM(CASE WHEN t.status = 'completed' THEN 1 ELSE 0 END) as completed_tasks
    FROM online_user u
    JOIN user_project up ON u.user_id = up.user_id
    LEFT JOIN task t ON t.project_uid = up.project_uid AND t.assignee_id = u.user_id
    WHERE up.project_uid = :project_id
    GROUP BY u.user_id
)
SELECT 
    u.user_id,
    u.username,
    u.profile_picture,
    COALESCE(ms.total_meetings, 0) as total_meetings,
    COALESCE(ms.meetings_attended, 0) as meetings_attended,
    COALESCE(ts.total_tasks, 0) as total_tasks,
    COALESCE(ts.completed_tasks, 0) as completed_tasks
FROM online_user u
JOIN user_project up ON u.user_id = up.user_id
LEFT JOIN meeting_stats ms ON u.user_id = ms.user_id
LEFT JOIN task_stats ts ON u.user_id = ts.user_id
WHERE up.project_uid = :project_id;
