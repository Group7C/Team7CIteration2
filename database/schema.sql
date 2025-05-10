-- DOUBLE CHECK THE DIFFERENT OPTIONS
CREATE TYPE notification_enum AS ENUM ('Daily', 'Weekly');

-- DOUBLE CHECK THE DIFFERENT OPTIONS
CREATE TYPE role_enum AS ENUM ('Editor', 'Viewer');

-- DOUBLE CHECK THE OPTIONS
CREATE TYPE tags_enum AS ENUM ('Science', 'Research', 'Maths', 'Group', 'Individual', 'Hard', 'Normal', 'Easy');

-- DOUBLE CHECK THE OPTIONS
--CREATE TYPE notification_enum AS ENUM ('Never', 'Daily', 'Weekly', 'Monthly');

-- DOUBLE CHECK THE OPTIONS
CREATE TYPE meeting_enum AS ENUM ('In-person', 'Online');

-- DOUBLE CHECK THE OPTIONS
CREATE TYPE theme_enum AS ENUM ('Light', 'Dark');

-- NOT DOING ANY OF THE FOREIGN KEYS YET FOR ANY TABLE

-- DONE
CREATE TABLE ONLINE_USER (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL ,
    email VARCHAR(150) NOT NULL ,
    user_password VARCHAR(100) NOT NULL ,
    theme theme_enum NOT NULL ,
    profile_picture BYTEA,
    currency_total INT NOT NULL ,
    customize_settings VARCHAR(1000)
);


-- DONE
CREATE TABLE PROJECT (
    project_uid SERIAL PRIMARY KEY,
    join_code VARCHAR(10) NOT NULL,
    proj_name VARCHAR(20) NOT NULL,
    deadline DATE NOT NULL ,
    notification_preference notification_enum NOT NULL ,
    google_drive_link VARCHAR(200),
    discord_link VARCHAR(200),
    uuid VARCHAR(50) NOT NULL
);


-- DONE
CREATE TABLE CONTRIBUTION_REPORT (
    contribution_id SERIAL PRIMARY KEY,
    project_uid INT NOT NULL REFERENCES PROJECT(project_uid),
    members_involved VARCHAR(1000),
    task_name VARCHAR(50),
    task_weighting INT NOT NULL,
    task_start DATE NOT NULL ,
    task_date DATE NOT NULL
);

-- DONE
CREATE TABLE MEETING (
    meeting_id SERIAL PRIMARY KEY,
    project_uid INT NOT NULL REFERENCES PROJECT(project_uid),
    meeting_type meeting_enum NOT NULL ,
    start_date DATE NOT NULL ,
    end_date DATE NOT NULL ,
    attendees VARCHAR(1000) NOT NULL ,
    subject VARCHAR(30) NOT NULL ,
    progress VARCHAR(200) NOT NULL ,
    takeaway VARCHAR(500) NOT NULL ,
    notes VARCHAR(300)
);


-- DONE
CREATE TABLE PROJECT_MEMBERS (
    members_id SERIAL PRIMARY KEY,
    project_uid INT NOT NULL REFERENCES PROJECT(project_uid),
    user_id INT NOT NULL REFERENCES ONLINE_USER(user_id),
    is_owner BOOL NOT NULL ,
    member_role role_enum NOT NULL ,
    join_date DATE NOT NULL
);


-- DONE
CREATE TABLE TASK (
    task_id SERIAL PRIMARY KEY,
    project_uid INT NOT NULL REFERENCES PROJECT(project_uid),
    task_name VARCHAR(50) NOT NULL,
    parent VARCHAR(50),
    weighting INT,
    tags tags_enum,
    priority INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    description VARCHAR(300),
    members VARCHAR(1000),
    notification_frequency notification_enum NOT NULL
);


-- INTERSECTIONS BELOW

CREATE TABLE MEMBERS_MEETING (
    meeting_id INT NOT NULL REFERENCES MEETING(meeting_id),
    members_id INT NOT NULL REFERENCES PROJECT_MEMBERS(members_id),
    PRIMARY KEY (meeting_id, members_id)
);


CREATE TABLE USER_PROJECT (
    user_id INT NOT NULL REFERENCES ONLINE_USER(user_id),
    project_uid INT NOT NULL REFERENCES PROJECT(project_uid),
    PRIMARY KEY (user_id, project_uid)
);

CREATE TABLE TASK_MEMBERS (
    task_id INT NOT NULL REFERENCES TASK(task_id),
    members_id INT NOT NULL REFERENCES PROJECT_MEMBERS(members_id),
    PRIMARY KEY (task_id, members_id)
);