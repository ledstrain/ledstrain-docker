-- To determine users to allow approving posts
-- User should have
-- - Joined more than a year ago
-- - Been seen in the last 2 weeks
-- - 10 posts in the last 6 months
-- - 20 post likes in the last 6 months

SET @approverUserGroup=(SELECT id FROM groups WHERE name_singular='Approver');

CREATE OR REPLACE VIEW view_user_post_count AS
SELECT u.id id, COUNT(p.id) recent_post_count
  FROM users u
  JOIN posts p ON u.id=p.user_id
  WHERE p.created_at > (NOW() - INTERVAL 6 MONTH)
  GROUP BY u.id;

CREATE OR REPLACE VIEW view_recent_post_likes AS
SELECT u.id id, COUNT(pl.post_id) recent_post_likes
  FROM users u
  JOIN post_likes pl ON u.id=pl.user_id
  WHERE (SELECT posts.created_at FROM posts WHERE pl.post_id = posts.id) > (NOW() - INTERVAL 6 MONTH)
  GROUP BY u.id
  ORDER BY recent_post_likes DESC;

INSERT IGNORE INTO group_user (user_id, group_id)
  SELECT u.id, @approverUserGroup
  FROM users u
  JOIN view_user_post_count upc   ON u.id=upc.id
  JOIN view_recent_post_likes rpl ON u.id=rpl.id
  WHERE u.joined_at < (NOW() - INTERVAL 1 YEAR)
    AND u.last_seen_at > (NOW() - INTERVAL 2 WEEK)
    AND upc.recent_post_count > 10
    AND rpl.recent_post_likes > 20;

DELETE FROM group_user
  WHERE group_user.group_id = @approverUserGroup
    AND group_user.user_id IN (SELECT u.id FROM users u
                       JOIN view_user_post_count upc   ON u.id=upc.id
                       JOIN view_recent_post_likes rpl ON u.id=rpl.id
                         AND u.last_seen_at < (NOW() - INTERVAL 2 WEEK)
                         AND upc.recent_post_count < 10);
