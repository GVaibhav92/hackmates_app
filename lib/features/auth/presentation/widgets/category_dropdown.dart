import 'package:flutter/material.dart';

class CategoryDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const CategoryDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: const InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'hackathon', child: Text('Hackathon')),
        DropdownMenuItem(value: 'project', child: Text('Project')),
        DropdownMenuItem(value: 'startup', child: Text('Startup')),
        DropdownMenuItem(value: 'non-tech', child: Text('Non-Tech')),
      ],
      onChanged: (val) {
        if (val != null) {
          onChanged(val);
        }
      },
    );
  }
}
