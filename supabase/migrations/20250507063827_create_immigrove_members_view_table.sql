create view public.immigrovemembersview as
select
  ui."Id",
  ui."UserId",
  ui."ImmiGroveId",
  ui."IsAdmin",
  ui."JoinedAt",
  ui."DeletedAt",
  up."FullName",
  up."UserName",
  up."AvatarUrl",
  up."CurrentCity",
  up."OriginCountry",
  ig."IsPublic" as "ImmiGroveIsPublic"
from
  "UserImmiGrove" ui
  left join "UserProfile" up on ui."UserId" = up."UserId"
  left join "ImmiGrove" ig on ui."ImmiGroveId" = ig."Id"
where
  ui."DeletedAt" is null
  and (
    ig."IsPublic" = true
    or (
      exists (
        select
          1
        from
          "UserImmiGrove"
        where
          "UserImmiGrove"."ImmiGroveId" = ui."ImmiGroveId"
          and "UserImmiGrove"."UserId" = auth.uid ()
          and "UserImmiGrove"."DeletedAt" is null
      )
    )
  );