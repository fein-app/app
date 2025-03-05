import 'package:flutter/material.dart';

class SearchbarHuggingface extends StatelessWidget {
  final Future<void> Function(String) onSubmitted;

  const SearchbarHuggingface({super.key, required this.onSubmitted,});

  @override
  Widget build(BuildContext context) {    
    return SearchBar(
      backgroundColor: WidgetStateProperty.all(Color(0xFF2c2c2c)),
      hintText: 'Search for models on Huggingface ...',
      onSubmitted: (value) {
        onSubmitted(value);
      },
      trailing: [
        IconButton(
          icon: Icon(Icons.search, color: Colors.white),
          onPressed: () {
            // Get the current text value from the SearchBar
            final searchText = context.findAncestorWidgetOfExactType<SearchBar>()?.controller?.text ?? '';
            onSubmitted(searchText);
          },
        ),
      ],
    );
  }
}