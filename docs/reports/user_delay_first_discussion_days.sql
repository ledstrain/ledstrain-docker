-- This is a report to find how many days a user has taken before creating
--  their first discussion

SELECT u.username username,
       TIMESTAMPDIFF(DAY, u.joined_at, MIN(d.created_at)) delay_first_discussion
 FROM users u
 JOIN discussions d ON u.id = d.user_id
 WHERE u.suspended_until IS NULL
   AND u.discussion_count > 0
 GROUP BY u.id
