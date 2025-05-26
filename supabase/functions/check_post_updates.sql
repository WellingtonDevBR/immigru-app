-- Function to check for post updates (new likes, comments, or posts)
CREATE OR REPLACE FUNCTION public.check_post_updates(
  last_check_time TIMESTAMP WITH TIME ZONE,
  user_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  new_posts_count INTEGER;
  updated_posts_count INTEGER;
  new_likes_count INTEGER;
  new_comments_count INTEGER;
  result JSON;
BEGIN
  -- Count new posts created since last check
  SELECT COUNT(*)
  INTO new_posts_count
  FROM "Post"
  WHERE "CreatedAt" > last_check_time;
  
  -- Count posts that have new likes since last check
  SELECT COUNT(DISTINCT "PostId")
  INTO new_likes_count
  FROM "PostLike"
  WHERE "CreatedAt" > last_check_time;
  
  -- Count posts that have new comments since last check
  SELECT COUNT(DISTINCT "PostId")
  INTO new_comments_count
  FROM "PostComment"
  WHERE "CreatedAt" > last_check_time;
  
  -- Count total updated posts (either new likes or comments)
  SELECT COUNT(DISTINCT p."Id")
  INTO updated_posts_count
  FROM "Post" p
  WHERE EXISTS (
    SELECT 1 FROM "PostLike" pl 
    WHERE pl."PostId" = p."Id" AND pl."CreatedAt" > last_check_time
  )
  OR EXISTS (
    SELECT 1 FROM "PostComment" pc 
    WHERE pc."PostId" = p."Id" AND pc."CreatedAt" > last_check_time
  );
  
  -- Construct the result JSON
  SELECT json_build_object(
    'newPostsCount', new_posts_count,
    'updatedPostsCount', updated_posts_count,
    'newLikesCount', new_likes_count,
    'newCommentsCount', new_comments_count,
    'hasUpdates', (new_posts_count > 0 OR updated_posts_count > 0)
  ) INTO result;
  
  RETURN result;
END;
$$;
