-- Used to promote users to a group to allow extras like PMing

-- Should have a specific group for this.
-- We use the one named "Valid User"
-- It also uses the first post plugin column, first_discussion_approval_count
SET @validUserGroup=(SELECT id FROM groups WHERE name_singular='Valid User');
INSERT IGNORE INTO group_user (user_id, group_id)
  SELECT id, @validUserGroup FROM users u
  WHERE u.first_discussion_approval_count > 0
    AND u.id NOT IN (SELECT user_id FROM group_user WHERE group_id = @validUserGroup)
