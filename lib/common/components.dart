import 'package:flutter/material.dart';

class InforvixEdit extends StatelessWidget {
  InforvixEdit({
    super.key,
    required this.controller,
    required this.onEnter,
    required this.label,
    required this.avancarNoEnter,
  });

  final TextEditingController controller;
  final String label;
  Function onEnter;
  final bool avancarNoEnter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: TextFormField(
        autofocus: true,
        textInputAction: avancarNoEnter ? TextInputAction.next : null,
        controller: controller,
        onFieldSubmitted: (_) {
          onEnter;
        },
        decoration: InputDecoration(
          label: Text(label),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

class InforvixButton extends StatelessWidget {
  InforvixButton({
    super.key,
    required this.title,
    required this.onClick,
  });

  final String title;
  final Function onClick;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onClick();
      },
      child: Card(
        elevation: 10,
        child: Container(
          width: MediaQuery.sizeOf(context).width * 0.8,
          height: 60,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: Colors.blue),
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
