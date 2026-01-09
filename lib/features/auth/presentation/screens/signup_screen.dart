import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/signup/signup_bloc.dart';
import '../../bloc/signup/signup_state.dart';
import '../widgets/signup_step1_widget.dart';
import '../widgets/signup_step2_widget.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignupBloc, SignupState>(
      listener: (context, state) {
        ///OTP sent -> navigate to OTP screen
        if (state is SignupOtpSent) {
          context.go(
            '/otp-verification',
            extra: {'email': state.email},
          );

        }

        ///OTP verified -> pop back and move to step 2
        if (state is SignupOtpVerified) {
          // Then animate to step 2
          Future.delayed(const Duration(milliseconds: 100), () {
            _pageController.animateToPage(
              1,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email verified! Complete your profile.'),
              backgroundColor: Color(0xFF238636),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }

        ///Signup fully completed
        if (state is SignupCompleted) {
          context.go('/feed');

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created successfully!'),
              backgroundColor: Color(0xFF238636),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        ///Errors
        if (state is SignupFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      builder: (context, state) {
        int currentStep = 0;
        if (state is SignupOtpVerified || state is SignupCompletingProfile) {
          currentStep = 1;
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (currentStep == 1 && _pageController.hasClients) {
            _pageController.jumpToPage(1);
          }
        });

        return Scaffold(
          backgroundColor: const Color(0xFF0D1117),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0D1117),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFFF0F6FC)),
              onPressed: () {
                if (currentStep == 1 && state is! SignupCompletingProfile) {
                  _pageController.animateToPage(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else {
                  context.go('/login');
                }
              },
            ),
            title: const Text(
              'Create Account',
              style: TextStyle(
                color: Color(0xFFF0F6FC),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              _buildProgressIndicator(currentStep),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    SignupStep1Widget(),
                    SignupStep2Widget(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator(int currentStep) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          _buildStepIndicator(
            step: 1,
            label: 'Basic Info',
            isActive: currentStep == 0,
            isCompleted: currentStep > 0,
          ),
          Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              color: currentStep > 0
                  ? const Color(0xFF238636)
                  : const Color(0xFF30363D),
            ),
          ),
          _buildStepIndicator(
            step: 2,
            label: 'Complete Profile',
            isActive: currentStep == 1,
            isCompleted: false,
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator({
    required int step,
    required String label,
    required bool isActive,
    required bool isCompleted,
  }) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted || isActive
                ? const Color(0xFF238636)
                : const Color(0xFF21262D),
            border: Border.all(
              color: isActive
                  ? const Color(0xFF238636)
                  : const Color(0xFF30363D),
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Text(
              '$step',
              style: TextStyle(
                color: isActive || isCompleted
                    ? Colors.white
                    : const Color(0xFF7D8590),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive
                ? const Color(0xFFF0F6FC)
                : const Color(0xFF7D8590),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}