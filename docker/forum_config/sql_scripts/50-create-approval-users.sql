-- To determine users to allow approving posts
-- User should have at a min
-- - Joined more than 3 months ago
-- - Been seen in the last week
-- - 2 posts in the last 3 months
-- - 2 post likes in the last 3 months

SET @approverUserGroup=(SELECT id FROM groups WHERE name_singular='Approver');

-- How many posts the user has created in the last n months
CREATE OR REPLACE VIEW view_user_post_count AS
SELECT     u.id id, COUNT(p.id) recent_post_count
  FROM     users u
  JOIN     posts p ON u.id=p.user_id
  WHERE    p.created_at > (NOW() - INTERVAL 3 MONTH)
  GROUP BY u.id;

-- How many post likes the user has received in the last n months
CREATE OR REPLACE VIEW view_recent_post_likes AS
SELECT     u.id id, COUNT(pl.post_id) recent_post_likes
  FROM     users u
  JOIN     post_likes pl ON u.id=pl.user_id
  WHERE    (SELECT posts.created_at FROM posts WHERE pl.post_id = posts.id) > (NOW() - INTERVAL 3 MONTH)
  GROUP BY u.id;

-- So called "good users". Should be n months old, been on the forum at least n weeks ago
CREATE OR REPLACE VIEW good_users AS
  SELECT u.*, upc.recent_post_count, rpl.recent_post_likes
  FROM   users u
  JOIN   view_user_post_count upc   ON u.id=upc.id
  JOIN   view_recent_post_likes rpl ON u.id=rpl.id
  WHERE  u.joined_at < (NOW() - INTERVAL 12 MONTH)
    AND  u.last_seen_at > (NOW() - INTERVAL 1 WEEK)
    AND  upc.recent_post_count > 2
    AND  rpl.recent_post_likes > 2;

-- This is largely the same operation done 3 times over for each segment of time for time zones.
-- First for midnight to 8am, then 8-4pm, then 4pm to midnight (UTC).
-- A check is done to ensure the user isn't in the 1 or 4 groups (admin | mod)
-- It is ordered by focusing on first the post likes, the post count and then last seen.
-- These are rounded to allow it to be ordered by the other conditions

-- SELECT username, joined_at, last_seen_at, SEGMENT, recent_post_likes, recent_post_count
INSERT IGNORE INTO group_user (user_id, group_id)
SELECT id, @approverUserGroup
FROM (SELECT *, '0-8' SEGMENT FROM (SELECT * FROM good_users
                                     WHERE (   TIME(last_seen_at) > TIME('00:00:00')
                                           AND TIME(last_seen_at) < TIME('08:00:00'))
                                       AND id NOT IN (SELECT user_id FROM group_user WHERE group_id IN (1, 4))
                                     ORDER BY ROUND(recent_post_likes) DESC,
                                              ROUND(recent_post_count) DESC,
                                              DATE_FORMAT(last_seen_at, '%m.%d') DESC
                                     LIMIT 2) a
      UNION
      SELECT *, '8-16' SEGMENT FROM (SELECT * FROM good_users
                                     WHERE (   TIME(last_seen_at) > TIME('08:00:00')
                                           AND TIME(last_seen_at) < TIME('16:00:00'))
                                       AND id NOT IN (SELECT user_id FROM group_user WHERE group_id IN (1, 4))
                                     ORDER BY ROUND(recent_post_likes) DESC,
                                              ROUND(recent_post_count) DESC,
                                              DATE_FORMAT(last_seen_at, '%m.%d') DESC
                                     LIMIT 2) b
      UNION
      SELECT *, '16-24' SEGMENT FROM (SELECT * FROM good_users
                                      WHERE (   TIME(last_seen_at) > TIME('16:00:00')
                                            AND TIME(last_seen_at) < TIME('24:00:00'))
                                        AND id NOT IN (SELECT user_id FROM group_user WHERE group_id IN (1, 4))
                                      ORDER BY ROUND(recent_post_likes) DESC,
                                               ROUND(recent_post_count) DESC,
                                               DATE_FORMAT(last_seen_at, '%m.%d') DESC
                                      LIMIT 2) c
                                    ) time_grouped;


-- This removes users from the "good user" group if they
-- - Have not been seen in the last 4 weeks
-- - Have less then 5 recent posts
DELETE FROM group_user
  WHERE group_user.group_id = @approverUserGroup
    AND group_user.user_id IN (SELECT u.id FROM users u
                               JOIN   view_user_post_count upc   ON u.id=upc.id
                               JOIN   view_recent_post_likes rpl ON u.id=rpl.id
                               WHERE  u.last_seen_at < (NOW() - INTERVAL 4 WEEK)
                                 AND  upc.recent_post_count < 5);

DROP VIEW IF EXISTS view_user_post_count;
DROP VIEW IF EXISTS view_recent_post_likes;
DROP VIEW IF EXISTS good_users;
