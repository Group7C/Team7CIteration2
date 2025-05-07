INSERT INTO ONLINE_USER (username, email, user_password, theme, profile_picture, currency_total, customize_settings)
VALUES (
    'Not Jib',
    'testuser123456@gmail.com',
    'P@ssword123',
    'Light',
    NULL,
    0,
    ''
);

INSERT INTO ONLINE_USER (username, email, user_password, theme, profile_picture, currency_total, customize_settings)
VALUES 
('Voula', 'voula@gmail.com', 'P@ssword123', 'Dark', NULL, 100, ''),
('Jamie', 'jamie@gmail.com', 'P@ssword123', 'Light', NULL, 50, ''),
('Tudor', 'tudor@gmail.com', 'P@ssword123', 'Dark', NULL, 75, ''),
('Harrison', 'harrison@gmail.com', 'P@ssword123', 'Light', NULL, 200, ''),
('Luke', 'luke@gmail.com', 'P@ssword123', 'Dark', NULL, 150, ''),
('Jib', 'jib@gmail.com', 'P@ssword123', 'Light', NULL, 125, ''),
('Claudia', 'claudia@gmail.com', 'P@ssword123', 'Dark', NULL, 175, '');

-- First, populate the PROJECT table
INSERT INTO PROJECT (join_code, proj_name, deadline, notification_preference, google_drive_link, discord_link, uuid)
VALUES 
('ABC123', 'Biology Research', '2025-06-30', 'Daily', 'https://drive.google.com/biology', 'https://discord.gg/biology', '550e8400-e29b-41d4-a716-446655440000'),
('DEF456', 'Math Homework', '2025-07-15', 'Weekly', 'https://drive.google.com/math', 'https://discord.gg/math', '550e8400-e29b-41d4-a716-446655440001'),
('GHI789', 'CS Project', '2025-08-01', 'Daily', 'https://drive.google.com/cs', 'https://discord.gg/cs', '550e8400-e29b-41d4-a716-446655440002'),
('JKL012', 'History Essay', '2025-08-15', 'Weekly', 'https://drive.google.com/history', 'https://discord.gg/history', '550e8400-e29b-41d4-a716-446655440003'),
('MNO345', 'Website Design', '2025-09-01', 'Daily', 'https://drive.google.com/website', 'https://discord.gg/website', '550e8400-e29b-41d4-a716-446655440004'),
('PQR678', 'Market Analysis', '2025-09-15', 'Weekly', 'https://drive.google.com/market', 'https://discord.gg/market', '550e8400-e29b-41d4-a716-446655440005'),
('STU901', 'App Development', '2025-10-01', 'Daily', 'https://drive.google.com/app', 'https://discord.gg/app', '550e8400-e29b-41d4-a716-446655440006'),
('VWX234', 'UX Research', '2025-10-15', 'Weekly', 'https://drive.google.com/ux', 'https://discord.gg/ux', '550e8400-e29b-41d4-a716-446655440007'),
('YZA567', 'Data Analysis', '2025-11-01', 'Daily', 'https://drive.google.com/data', 'https://discord.gg/data', '550e8400-e29b-41d4-a716-446655440008'),
('BCD890', 'ML Project', '2025-11-15', 'Weekly', 'https://drive.google.com/ml', 'https://discord.gg/ml', '550e8400-e29b-41d4-a716-446655440009'),
('EFG123', 'Game Design', '2025-12-01', 'Daily', 'https://drive.google.com/game', 'https://discord.gg/game', '550e8400-e29b-41d4-a716-446655440010'),
('HIJ456', 'Chemistry Lab', '2025-12-15', 'Weekly', 'https://drive.google.com/chemistry', 'https://discord.gg/chemistry', '550e8400-e29b-41d4-a716-446655440011'),
('KLM789', 'Physics Project', '2026-01-01', 'Daily', 'https://drive.google.com/physics', 'https://discord.gg/physics', '550e8400-e29b-41d4-a716-446655440012'),
('NOP012', 'English Essay', '2026-01-15', 'Weekly', 'https://drive.google.com/english', 'https://discord.gg/english', '550e8400-e29b-41d4-a716-446655440013'),
('QRS345', 'Art Project', '2026-02-01', 'Daily', 'https://drive.google.com/art', 'https://discord.gg/art', '550e8400-e29b-41d4-a716-446655440014'),
('TUV678', 'Music Project', '2026-02-15', 'Weekly', 'https://drive.google.com/music', 'https://discord.gg/music', '550e8400-e29b-41d4-a716-446655440015');

-- Now, populate the PROJECT_MEMBERS table to create relationships
-- Assuming users have IDs 1-8 (Not Jib, Voula, Jamie, Tudor, Harrison, Luke, Jib, Claudia)
-- Each user will be a member of at least 2 projects, and each project will have at least 3 members

INSERT INTO PROJECT_MEMBERS (project_uid, user_id, is_owner, member_role, join_date)
VALUES
-- Biology Research (project 1) members
(1, 1, TRUE, 'Editor', '2025-05-01'),  -- Not Jib (owner)
(1, 2, FALSE, 'Editor', '2025-05-02'), -- Voula
(1, 3, FALSE, 'Viewer', '2025-05-03'), -- Jamie

-- Math Homework (project 2) members
(2, 2, TRUE, 'Editor', '2025-05-01'),  -- Voula (owner)
(2, 3, FALSE, 'Editor', '2025-05-02'), -- Jamie
(2, 4, FALSE, 'Viewer', '2025-05-03'), -- Tudor

-- CS Project (project 3) members
(3, 3, TRUE, 'Editor', '2025-05-01'),  -- Jamie (owner)
(3, 4, FALSE, 'Editor', '2025-05-02'), -- Tudor
(3, 5, FALSE, 'Viewer', '2025-05-03'), -- Harrison

-- History Essay (project 4) members
(4, 4, TRUE, 'Editor', '2025-05-01'),  -- Tudor (owner)
(4, 5, FALSE, 'Editor', '2025-05-02'), -- Harrison
(4, 6, FALSE, 'Viewer', '2025-05-03'), -- Luke

-- Website Design (project 5) members
(5, 5, TRUE, 'Editor', '2025-05-01'),  -- Harrison (owner)
(5, 6, FALSE, 'Editor', '2025-05-02'), -- Luke
(5, 7, FALSE, 'Viewer', '2025-05-03'), -- Jib

-- Market Analysis (project 6) members
(6, 6, TRUE, 'Editor', '2025-05-01'),  -- Luke (owner)
(6, 7, FALSE, 'Editor', '2025-05-02'), -- Jib
(6, 8, FALSE, 'Viewer', '2025-05-03'), -- Claudia

-- App Development (project 7) members
(7, 7, TRUE, 'Editor', '2025-05-01'),  -- Jib (owner)
(7, 8, FALSE, 'Editor', '2025-05-02'), -- Claudia
(7, 1, FALSE, 'Viewer', '2025-05-03'), -- Not Jib

-- UX Research (project 8) members
(8, 8, TRUE, 'Editor', '2025-05-01'),  -- Claudia (owner)
(8, 1, FALSE, 'Editor', '2025-05-02'), -- Not Jib
(8, 2, FALSE, 'Viewer', '2025-05-03'), -- Voula

-- Data Analysis (project 9) members
(9, 1, TRUE, 'Editor', '2025-05-01'),  -- Not Jib (owner)
(9, 3, FALSE, 'Editor', '2025-05-02'), -- Jamie
(9, 5, FALSE, 'Viewer', '2025-05-03'), -- Harrison

-- ML Project (project 10) members
(10, 2, TRUE, 'Editor', '2025-05-01'), -- Voula (owner)
(10, 4, FALSE, 'Editor', '2025-05-02'), -- Tudor
(10, 6, FALSE, 'Viewer', '2025-05-03'), -- Luke

-- Game Design (project 11) members
(11, 3, TRUE, 'Editor', '2025-05-01'), -- Jamie (owner)
(11, 5, FALSE, 'Editor', '2025-05-02'), -- Harrison
(11, 7, FALSE, 'Viewer', '2025-05-03'), -- Jib

-- Chemistry Lab (project 12) members
(12, 4, TRUE, 'Editor', '2025-05-01'), -- Tudor (owner)
(12, 6, FALSE, 'Editor', '2025-05-02'), -- Luke
(12, 8, FALSE, 'Viewer', '2025-05-03'), -- Claudia

-- Physics Project (project 13) members
(13, 5, TRUE, 'Editor', '2025-05-01'), -- Harrison (owner)
(13, 7, FALSE, 'Editor', '2025-05-02'), -- Jib
(13, 1, FALSE, 'Viewer', '2025-05-03'), -- Not Jib

-- English Essay (project 14) members
(14, 6, TRUE, 'Editor', '2025-05-01'), -- Luke (owner)
(14, 8, FALSE, 'Editor', '2025-05-02'), -- Claudia
(14, 2, FALSE, 'Viewer', '2025-05-03'), -- Voula

-- Art Project (project 15) members
(15, 7, TRUE, 'Editor', '2025-05-01'), -- Jib (owner)
(15, 1, FALSE, 'Editor', '2025-05-02'), -- Not Jib
(15, 3, FALSE, 'Viewer', '2025-05-03'), -- Jamie

-- Music Project (project 16) members
(16, 8, TRUE, 'Editor', '2025-05-01'), -- Claudia (owner)
(16, 2, FALSE, 'Editor', '2025-05-02'), -- Voula
(16, 4, FALSE, 'Viewer', '2025-05-03'); -- Tudor