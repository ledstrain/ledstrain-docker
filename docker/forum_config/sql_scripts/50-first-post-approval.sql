-- For verified users, auto set to first post approved
UPDATE users u SET first_post_approval_count=1,
                   first_discussion_approval_count=1
WHERE verified_user = 1
