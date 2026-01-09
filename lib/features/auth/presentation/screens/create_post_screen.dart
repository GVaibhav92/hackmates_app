import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '/features/feed/bloc/feed_bloc.dart';
import '/features/feed/bloc/feed_event.dart';
import '/features/feed/bloc/feed_state.dart';
import '../widgets/category_dropdown.dart';
import '../widgets/image_picker_grid.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();

  String _title = '';
  String _description = '';
  String _category = 'hackathon';
  String _duration = '';
  List<File> _images = [];

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    context.read<FeedBloc>().add(
      CreatePostRequested(
        title: _title,
        description: _description,
        category: _category,
        images: _images,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FeedBloc, FeedState>(
      listener: (context, state) {
        if (state is PostCreated) {
          context.go('/feed');
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Create Post')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                /// Title
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  onSaved: (v) => _title = v!,
                ),
                const SizedBox(height: 16),

                /// Description
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  onSaved: (v) => _description = v!,
                ),
                const SizedBox(height: 16),

                /// Category
                CategoryDropdown(
                  value: _category,
                  onChanged: (val) {
                    setState(() => _category = val);
                  },
                ),
                const SizedBox(height: 16),

                /// Duration
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Duration',
                    border: OutlineInputBorder(),
                    hintText: 'e.g. 3 days',
                  ),
                  onSaved: (v) => _duration = v ?? '',
                ),
                const SizedBox(height: 20),

                /// Image Picker Grid
                ImagePickerGrid(
                  images: _images,
                  onChanged: (updated) {
                    setState(() => _images = updated);
                  },
                ),

                const SizedBox(height: 32),

                /// Submit Button
                BlocBuilder<FeedBloc, FeedState>(
                  builder: (context, state) {
                    return SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: state is PostCreating ? null : _submit,
                        child: state is PostCreating
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Post'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
