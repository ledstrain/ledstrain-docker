-- We use the group named "Valid User" aka valid to for users to have extra capabilities.
SET @validUserGroup=(SELECT id FROM groups WHERE name_singular='Valid User');

-- Used to promote users to a group to allow extras like PMing
-- It uses the first post plugin column, first_discussion_approval_count
INSERT IGNORE INTO group_user (user_id, group_id)
  SELECT id, @validUserGroup FROM users u
  WHERE u.first_discussion_approval_count > 0
    AND u.id NOT IN (SELECT user_id FROM group_user WHERE group_id = @validUserGroup);

-- If a user
-- - Has not been active for 6 months
-- - Has fewer then 10 posts
-- Then they are removed from the valid group.
DELETE FROM group_user gu
  WHERE gu.group_id = @validUserGroup
    AND gu.user_id IN (SELECT id FROM users u
                       WHERE u.last_seen_at < (NOW() - INTERVAL 6 MONTH)
                         AND u.comment_count < 10);
