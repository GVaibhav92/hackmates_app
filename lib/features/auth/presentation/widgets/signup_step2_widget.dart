import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/signup/signup_bloc.dart';
import '../../bloc/signup/signup_event.dart';
import '../../bloc/signup/signup_state.dart';
import '../../models/signup_data_model.dart';
import '../widgets/interest_chip_widget.dart';
import '../widgets/profile_photo_picker.dart';

class SignupStep2Widget extends StatefulWidget {
  const SignupStep2Widget({super.key});

  @override
  State<SignupStep2Widget> createState() => _SignupStep2WidgetState();
}

class _SignupStep2WidgetState extends State<SignupStep2Widget> {
  final _bioController = TextEditingController();

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupBloc, SignupState>(
      builder: (context, state) {
        SignupDataModel? data;

        if (state is SignupOtpVerified) {
          data = state.data;
        } else if (state is SignupCompletingProfile) {
          data = state.data;
        }

        final selectedInterests = data?.interests ?? [];
        final isSubmitting = state is SignupCompletingProfile;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Tell us more about yourself',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFF0F6FC),
                ),
                textAlign: TextAlign.center,
              ),
              // Profile Photo Picker (Optional)
              Center(
                child: ProfilePhotoPicker(
                  currentPhoto: data?.profilePhoto,
                  onPhotoSelected: (photo) {
                    context.read<SignupBloc>().add(
                      SignupProfilePhotoChanged(photo),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              const Text(
                'Select your interests to help us personalize your experience',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7D8590),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              Row(
                children: [
                  const Text(
                    'Interests',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF0F6FC),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '*',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFDA3633),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${selectedInterests.length} selected',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7D8590),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: InterestCategories.all.map((interest) {
                  final isSelected = selectedInterests.contains(interest);
                  return InterestChipWidget(
                    label: interest,
                    isSelected: isSelected,
                    onTap: () {
                      context
                          .read<SignupBloc>()
                          .add(SignupInterestToggled(interest));
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              const Text(
                'Bio (Optional)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFF0F6FC),
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _bioController,
                maxLines: 4,
                maxLength: 500,
                style: const TextStyle(
                  color: Color(0xFFF0F6FC),
                  fontSize: 14,
                ),
                onChanged: (value) {
                  context.read<SignupBloc>().add(SignupBioChanged(value));
                },
                decoration: InputDecoration(
                  hintText: 'Tell us a bit about yourself...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF7D8590),
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF0D1117),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(
                      color: Color(0xFF30363D),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(
                      color: Color(0xFF1F6FEB),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                  counterStyle: const TextStyle(
                    color: Color(0xFF7D8590),
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () {
                    if (selectedInterests.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Please select at least one interest'),
                          backgroundColor: Color(0xFFDA3633),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }

                    context
                        .read<SignupBloc>()
                        .add(SignupProfileCompleted());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF238636),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    elevation: 0,
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'Complete Signup',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
