export class PostService {
  supabase;
  constructor(supabaseClient){
    this.supabase = supabaseClient;
  }
  async createPost(payload) {
    try {
      // Handle media items
      let mediaUrls = null;
      // First check if we have media items in the metadata
      if (payload.metadata?.mediaItems && payload.metadata.mediaItems.length > 0) {
        mediaUrls = JSON.stringify(payload.metadata.mediaItems);
      } else if (payload.mediaUrl) {
        mediaUrls = payload.mediaUrl;
      } else {}
      // Create post
      const { data: post, error: postError } = await this.supabase.from('Post').insert({
        UserId: payload.userId,
        Content: payload.content,
        Type: payload.type,
        MediaUrl: mediaUrls
      }).select().single();
      if (postError) {
        console.error('Error creating post:', postError);
        throw postError;
      }
      // If we have link preview data, save it and associate with the post
      if (payload.metadata?.linkPreview && post) {
        // First, save the link preview
        const { data: linkPreview, error: previewError } = await this.supabase.from('LinkPreview').insert({
          Url: payload.metadata.linkPreview.Url,
          Title: payload.metadata.linkPreview.Title || null,
          Description: payload.metadata.linkPreview.Description || null,
          ImageUrl: payload.metadata.linkPreview.ImageUrl || null,
          SiteName: payload.metadata.linkPreview.SiteName || null,
          FaviconUrl: payload.metadata.linkPreview.FaviconUrl || null,
          CreatedAt: new Date().toISOString()
        }).select().single();
        if (previewError) {
          console.error('Error saving link preview:', previewError);
        } else if (linkPreview) {
          // Then, associate the link preview with the post
          const { error: updateError } = await this.supabase.from('Post').update({
            LinkPreviewId: linkPreview.Id
          }).eq('Id', post.Id);
          if (updateError) {
            console.error('Error associating link preview with post:', updateError);
          } else {}
        }
      } else if (payload.linkPreview && post) {
        // Handle legacy linkPreview format
        const { error: previewError } = await this.supabase.from('LinkPreview').insert({
          Url: payload.linkPreview.url,
          Title: payload.linkPreview.title || null,
          Description: payload.linkPreview.description || null,
          ImageUrl: payload.linkPreview.imageUrl || null,
          SiteName: payload.linkPreview.siteName || null,
          FaviconUrl: payload.linkPreview.faviconUrl || null,
          CreatedAt: new Date().toISOString()
        });
        if (previewError) {
          console.error('Error saving link preview:', previewError);
        }
      }
      return {
        success: true,
        data: post
      };
    } catch (error) {
      console.error('Error in createPost:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }
}
