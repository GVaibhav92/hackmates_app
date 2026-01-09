import 'package:flutter/material.dart';

class QuickApplyScreen extends StatelessWidget {
  const QuickApplyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quick Apply')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Why would you be a great fit for this opportunity?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Write a short note...',
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Application Submitted!')),
                );
                Navigator.pop(context);
              },
              child: const Text('Submit Application'),
            ),
          ],
        ),
      ),
    );
  }
}
