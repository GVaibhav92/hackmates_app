import 'dart:io';

abstract class FeedEvent {}

class FetchFeed extends FeedEvent {}

class CreatePostRequested extends FeedEvent {
  final String title;
  final String description;
  final String category;
  final List<File> images;

  CreatePostRequested({
    required this.title,
    required this.description,
    required this.category,
    required this.images,
  });
}