create view public.AlbumWithCoverPhoto as
select
  a."Id",
  a."UserId",
  a."Name",
  a."Description",
  a."CoverPhotoId",
  a."Visibility",
  a."PhotoCount",
  a."UpdatedAt",
  a."CreatedAt",
  p."Url" as "CoverPhotoUrl",
  p."Title" as "CoverPhotoTitle",
  p."Description" as "CoverPhotoDescription"
from
  "PhotoAlbum" a
  left join "Photo" p on a."CoverPhotoId" = p."Id";