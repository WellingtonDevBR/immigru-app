-- Function to get the like count for a post
CREATE OR REPLACE FUNCTION public.get_post_like_count(post_id UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  like_count INTEGER;
BEGIN
  -- Count likes for the given post
  SELECT COUNT(*)
  INTO like_count
  FROM "PostLike"
  WHERE "PostId" = post_id;
  
  RETURN like_count;
END;
$$;

-- Function to get the comment count for a post
CREATE OR REPLACE FUNCTION public.get_post_comment_count(post_id UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  comment_count INTEGER;
BEGIN
  -- Count comments for the given post
  SELECT COUNT(*)
  INTO comment_count
  FROM "PostComment"
  WHERE "PostId" = post_id
  AND "DeletedAt" IS NULL;
  
  RETURN comment_count;
END;
$$;

-- Function to check if a user has liked a post
CREATE OR REPLACE FUNCTION public.has_user_liked_post(post_id UUID, user_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  has_liked BOOLEAN;
BEGIN
  -- Check if the user has liked the post
  SELECT EXISTS (
    SELECT 1
    FROM "PostLike"
    WHERE "PostId" = post_id
    AND "UserId" = user_id
  )
  INTO has_liked;
  
  RETURN has_liked;
END;
$$;

-- Function to check if a user has commented on a post
CREATE OR REPLACE FUNCTION public.has_user_commented_post(post_id UUID, user_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  has_commented BOOLEAN;
BEGIN
  -- Check if the user has commented on the post
  SELECT EXISTS (
    SELECT 1
    FROM "PostComment"
    WHERE "PostId" = post_id
    AND "UserId" = user_id
    AND "DeletedAt" IS NULL
  )
  INTO has_commented;
  
  RETURN has_commented;
END;
$$;

-- Function to get all post interaction data in a single call
CREATE OR REPLACE FUNCTION public.get_post_interaction_data(post_id UUID, user_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  like_count INTEGER;
  comment_count INTEGER;
  has_liked BOOLEAN;
  has_commented BOOLEAN;
  result JSON;
BEGIN
  -- Get like count
  SELECT public.get_post_like_count(post_id) INTO like_count;
  
  -- Get comment count
  SELECT public.get_post_comment_count(post_id) INTO comment_count;
  
  -- Check if user has liked the post
  SELECT public.has_user_liked_post(post_id, user_id) INTO has_liked;
  
  -- Check if user has commented on the post
  SELECT public.has_user_commented_post(post_id, user_id) INTO has_commented;
  
  -- Construct the result JSON
  SELECT json_build_object(
    'likeCount', like_count,
    'commentCount', comment_count,
    'isLiked', has_liked,
    'hasUserComment', has_commented
  ) INTO result;
  
  RETURN result;
END;
$$;
