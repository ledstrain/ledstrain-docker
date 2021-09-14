-- We use the group named "Verified User" aka verified to for users to have extra capabilities.
SET @verifiedUserGroup=(SELECT id FROM groups WHERE name_singular='Verified User');

-- Used to promote users to a group to allow extras like PMing
-- It uses the first post plugin column, first_discussion_approval_count
INSERT IGNORE INTO group_user (user_id, group_id)
  SELECT id, @verifiedUserGroup FROM users u
  WHERE u.verified_user = 1
    AND u.id NOT IN (SELECT user_id FROM group_user WHERE group_id = @verifiedUserGroup);

-- If a user
-- - Has not been active for 6 months
-- - Has fewer then 10 posts
-- Then they are removed from the verified group.
DELETE FROM group_user
  WHERE group_user.group_id = @verifiedUserGroup
    AND group_user.user_id IN (SELECT id FROM users u
                         WHERE u.last_seen_at < (NOW() - INTERVAL 6 MONTH)
                           AND u.comment_count < 10);
