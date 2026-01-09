import 'package:hackmates_app/features/auth/models/post_model.dart';

abstract class FeedState {}

class FeedInitial extends FeedState {}

class FeedLoading extends FeedState {}

class FeedLoaded extends FeedState {
  final List<PostModel> posts;
  FeedLoaded(this.posts);
}

class PostCreating extends FeedState {}

class PostCreated extends FeedState {}

class FeedError extends FeedState {
  final String message;
  FeedError(this.message);
}
