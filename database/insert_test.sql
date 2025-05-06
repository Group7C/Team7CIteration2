-- THIS IS A TEST INSERT SO YOU CAN TRY QUERYING AN ONLINE USER
-- changed values to work with min constraints e.g email length
INSERT INTO ONLINE_USER (username, email, user_password, theme, profile_picture, currency_total, customize_settings)
VALUES 
    ('test_user', 'test123456@gmail.com', 'P@ssword1234', 'Light', NULL, 0, '');