import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { getSecureCorsHeaders } from './cors.ts';
serve(async (req)=>{
  const corsHeaders = getSecureCorsHeaders(req.headers.get('origin'));
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: corsHeaders
    });
  }
  try {
    const supabaseClient = createClient(Deno.env.get('SUPABASE_URL') ?? '', Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '');
    const requestBody = await req.json();
    const { filter = 'all', userId, immigroveId, excludeCurrentUser = true, currentUserId, limit = 10, offset = 0 // Default offset starting at 0
     } = requestBody;
    let query = supabaseClient.from('Post').select(`
      *,
      User!Post_UserId_fkey (
        Id,
        Email,
        UserProfile (
          Id,
          DisplayName,
          AvatarUrl,
          CurrentCity,
          ShowLocation,
          Username
        )
      ),
      ImmiGrove (
        Id,
        Name,
        CoverImageUrl
      ),
      PostLike:PostLike_PostId_fkey (count),
      Comment:comments_post_id_fkey (
        Id,
        Content,
        CreatedAt,
        ParentCommentId,
        User:UserId (
          Id,
          UserProfile (
            DisplayName,
            AvatarUrl
          )
        )
      )
    `).is('DeletedAt', null).order('CreatedAt', {
      ascending: false
    });
    const isViewingOwnProfile = userId && userId === currentUserId;
    if (filter === 'user' && userId) {
      query = query.eq('UserId', userId).is('ImmiGroveId', null);
    } else if (userId) {
      if (filter === 'all' && excludeCurrentUser && isViewingOwnProfile) {
        return new Response(JSON.stringify({
          data: [],
          error: null
        }), {
          headers: {
            ...corsHeaders,
            'Content-Type': 'application/json'
          },
          status: 200
        });
      }
      query = query.eq('UserId', userId).is('ImmiGroveId', null);
    } else if (excludeCurrentUser && currentUserId) {
      query = query.neq('UserId', currentUserId);
    }
    if (immigroveId) {
      query = query.eq('ImmiGroveId', immigroveId);
    }
    if (filter === 'following' && currentUserId) {
      const { data: followingData } = await supabaseClient.from('UserFollowing').select('FollowingId').eq('FollowerId', currentUserId);
      if (!followingData?.length) {
        return new Response(JSON.stringify({
          data: [],
          error: null
        }), {
          headers: {
            ...corsHeaders,
            'Content-Type': 'application/json'
          },
          status: 200
        });
      }
      const followingIds = followingData.map((f)=>f.FollowingId);
      query = query.in('UserId', followingIds);
    }
    if (filter === 'my-immigroves' && currentUserId) {
      const { data: memberships } = await supabaseClient.from('ImmiGroveMember').select('ImmiGroveId').eq('UserId', currentUserId);
      const { data: ownedGroves, error: ownerErr } = await supabaseClient.from('ImmiGrove').select('Id').eq('CreatedBy', currentUserId);
      if (ownerErr) throw ownerErr;
      const membershipIds = memberships?.map((m)=>m.ImmiGroveId) ?? [];
      const ownedIds = ownedGroves?.map((g)=>g.Id) ?? [];
      const allIds = [
        ...new Set([
          ...membershipIds,
          ...ownedIds
        ])
      ];
      if (!allIds.length) {
        return new Response(JSON.stringify({
          data: [],
          error: null
        }), {
          headers: {
            ...corsHeaders,
            'Content-Type': 'application/json'
          },
          status: 200
        });
      }
      query = query.in('ImmiGroveId', allIds);
    }
    // Apply pagination parameters
    query = query.range(offset, offset + limit - 1);
    const { data: posts, error } = await query;
    if (error) throw error;
    const transformedPosts = posts.map(({ User, ImmiGrove, PostLike, Comment, ...post })=>{
      // Get user profile data - handle both array and direct object formats
      const authorProfile = Array.isArray(User.UserProfile) ? User.UserProfile[0] : User.UserProfile;
      const transformed = {
        id: post.Id,
        user_id: post.UserId,
        type: post.Type,
        content: post.Content,
        media_url: post.MediaUrl,
        location: post.Location,
        language: post.Language,
        visibility: post.Visibility,
        tags: post.Tags,
        created_at: post.CreatedAt,
        updated_at: post.UpdatedAt,
        is_featured: post.IsFeatured,
        is_pinned: post.IsPinned,
        author: {
          id: User.Id,
          name: authorProfile.DisplayName,
          avatar_url: authorProfile.AvatarUrl,
          location: authorProfile.CurrentCity,
          showlocation: authorProfile.ShowLocation,
          username: authorProfile.UserName
        },
        likes_count: PostLike?.[0]?.count ?? 0,
        comments_count: Comment?.length ?? 0,
        comments: (Comment || []).map((c)=>({
            id: c.Id,
            content: c.Content,
            created_at: c.CreatedAt,
            parent_comment_id: c.ParentCommentId,
            author: {
              id: c.User.Id,
              name: c.User.UserProfile[0].DisplayName,
              avatar_url: c.User.UserProfile[0].AvatarUrl
            }
          })),
        user_has_liked: false
      };
      try {
        if (post.MediaUrl) {
          const parsed = JSON.parse(post.MediaUrl);
          transformed.media = Array.isArray(parsed) ? parsed : [
            parsed
          ];
        }
      } catch (e) {}
      if (ImmiGrove) {
        transformed.immigrove = {
          id: ImmiGrove.Id,
          name: ImmiGrove.Name,
          slug: ImmiGrove.Name.toLowerCase().replace(/\s+/g, '-'),
          cover_image_url: ImmiGrove.CoverImageUrl,
          avatar_url: ImmiGrove.CoverImageUrl // Ensure we have an avatar_url for the ImmiGrove
        };
      }
      return transformed;
    });
    return new Response(JSON.stringify({
      data: transformedPosts,
      error: null
    }), {
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json'
      },
      status: 200
    });
  } catch (error) {
    return new Response(JSON.stringify({
      data: null,
      error: error.message
    }), {
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json'
      },
      status: 400
    });
  }
});
