import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:hackmates_app/features/auth/data/feed_repository.dart';
import 'package:hackmates_app/features/auth/models/post_model.dart';
import 'feed_event.dart';
import 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  FeedBloc(this.feedRepository) : super(FeedInitial()) {
    on<FetchFeed>(_onFetchFeed);
    on<CreatePostRequested>(_onCreatePost);
  }

  final FeedRepository feedRepository;

  Future<void> _onFetchFeed(
      FetchFeed event, Emitter<FeedState> emit) async {
    emit(FeedLoading());
    try {
      final List<PostModel> posts =
      await feedRepository.fetchPosts();
      emit(FeedLoaded(posts));
    } catch (e) {
      emit(FeedError(e.toString()));
    }
  }

  Future<void> _onCreatePost(
      CreatePostRequested event, Emitter<FeedState> emit) async {
    emit(PostCreating());
    try {
      await feedRepository.createPost(
        title: event.title,
        description: event.description,
        category: event.category,
        images: event.images,
      );
      emit(PostCreated());
      add(FetchFeed()); // refresh feed
    } catch (e) {
      emit(FeedError(e.toString()));
    }
  }
}
