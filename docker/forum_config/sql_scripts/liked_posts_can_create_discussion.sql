-- If a user has
--  - Been last seen in the last week
--  - An account that must be at least 2 days old
--  - An account that must not be suspended
--  - Not already been approved for creating a post or discussion
--  - A post with at least 1 like from another user
-- Then it will set approval to 1
-- tldr; If someone else liked your post, you can create discussions without needing
--  approval

UPDATE users u SET first_post_approval_count=1,
                   first_discussion_approval_count=1
 WHERE u.last_seen_at > (NOW() - INTERVAL 7 DAY)
  AND  u.joined_at    < (NOW() - INTERVAL 2 DAY)
  AND  u.suspended_until IS NULL
  AND (
          u.first_post_approval_count       = 0
       OR u.first_discussion_approval_count = 0
      )
  AND  u.id IN (SELECT p.user_id FROM posts p
                WHERE p.id IN (SELECT post_id FROM post_likes pl
                               WHERE pl.user_id != u.id)
               );
