import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final Function(String) onChanged;

  const CustomSearchBar({Key? key, required this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4.0,
      borderRadius: BorderRadius.circular(8),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Rechercher...',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(12),
        ),
      ),
    );
  }
}
