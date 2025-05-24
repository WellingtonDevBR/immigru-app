# Fix for Comments Disappearing Issue

## The Problem

When updating comments, the rest of the comments are disappearing from the UI even though they still exist in the database. This happens because:

1. The `rootCommentId` and `depth` fields are not being included in the returned `PostCommentModel` objects
2. The CommentsBloc is not properly reloading all comments after operations

## Solution Steps

### 1. Update PostCommentModel.fromJson

In `lib/features/home/data/models/post_comment_model.dart`, ensure the `fromJson` method correctly handles PascalCase field names from the database:

```dart
return PostCommentModel(
  id: json['Id']?.toString() ?? '',
  postId: json['PostId']?.toString() ?? '',
  userId: json['UserId']?.toString() ?? '',
  parentCommentId: json['ParentCommentId']?.toString(),
  rootCommentId: json['RootCommentId']?.toString(),
  depth: json['Depth'] ?? 1,
  content: json['Content']?.toString() ?? '',
  createdAt: json['CreatedAt'] != null
      ? DateTime.parse(json['CreatedAt'].toString())
      : DateTime.now(),
  userName: json['DisplayName']?.toString() ?? 'User',
  userAvatar: json['AvatarUrl']?.toString(),
  isCurrentUserComment: 
      currentUserId != null && json['UserId']?.toString() == currentUserId,
);
```

### 2. Update HomeDataSourceImpl.createComment

In `lib/features/home/data/datasources/home_data_source.dart`, update the return statement in the `createComment` method:

```dart
return PostCommentModel(
  id: response['Id'],
  postId: response['PostId'],
  userId: response['UserId'],
  parentCommentId: response['ParentCommentId'],
  rootCommentId: response['RootCommentId'],
  depth: response['Depth'] ?? 1,
  content: response['Content'],
  createdAt: DateTime.parse(response['CreatedAt']),
  userName: userProfileResponse['DisplayName'],
  userAvatar: userProfileResponse['AvatarUrl'],
);
```

### 3. Update HomeDataSourceImpl.editComment

In `lib/features/home/data/datasources/home_data_source.dart`, update the return statement in the `editComment` method:

```dart
return PostCommentModel(
  id: response['Id'],
  postId: response['PostId'],
  userId: response['UserId'],
  parentCommentId: response['ParentCommentId'],
  rootCommentId: response['RootCommentId'],
  depth: response['Depth'] ?? 1,
  content: response['Content'],
  createdAt: DateTime.parse(response['CreatedAt']),
  userName: userProfileResponse['DisplayName'],
  userAvatar: userProfileResponse['AvatarUrl'],
);
```

### 4. Update HomeDataSourceImpl.getComments

In `lib/features/home/data/datasources/home_data_source.dart`, ensure the `getComments` method fetches all replies for a post:

```dart
// Get ALL replies for this post to ensure we have complete data
final repliesResponse = await supabase
    .from('PostComment')
    .select()
    .eq('PostId', postId)
    .not('ParentCommentId', 'is', null) // Get all comments with a parent
    .order('CreatedAt', ascending: true);
```

Also ensure that when creating the `PostCommentModel` objects for both comments and replies, the `rootCommentId` and `depth` fields are included:

```dart
// For replies
final replyModel = PostCommentModel(
  id: reply['Id'],
  postId: reply['PostId'],
  userId: replyUserId,
  parentCommentId: parentId,
  rootCommentId: reply['RootCommentId'],
  depth: reply['Depth'] ?? 1,
  content: reply['Content'],
  createdAt: DateTime.parse(reply['CreatedAt']),
  userName: userProfile?['DisplayName'] ?? 'User',
  userAvatar: userProfile?['AvatarUrl'],
);

// For top-level comments
final commentModel = PostCommentModel(
  id: commentId,
  postId: comment['PostId'],
  userId: commentUserId,
  rootCommentId: comment['RootCommentId'],
  depth: comment['Depth'] ?? 1,
  content: comment['Content'],
  createdAt: DateTime.parse(comment['CreatedAt']),
  userName: userProfile?['DisplayName'] ?? 'User',
  userAvatar: userProfile?['AvatarUrl'],
  replies: repliesMap[commentId] ?? [],
);
```

### 5. Update CommentsBloc

In `lib/features/home/presentation/bloc/comments/comments_bloc.dart`, ensure that after each operation (create, edit, delete), all comments are reloaded:

```dart
// After successful comment creation, edit, or deletion:
add(LoadComments(postId: event.postId));
```

## Testing the Fix

1. Make these changes to the codebase
2. Test creating, editing, and deleting comments
3. Verify that comments don't disappear after updates
4. Check that the comment hierarchy is properly maintained

## Future Improvements

To better organize the codebase according to clean architecture principles, consider:

1. Creating a separate `CommentDataSource` interface and implementation
2. Creating a separate `CommentRepository` interface and implementation
3. Creating a dedicated dependency injection module for comments

This would reduce the size of the `HomeDataSource` file and make the codebase more maintainable.
