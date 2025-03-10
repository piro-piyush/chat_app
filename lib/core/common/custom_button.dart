import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Function()? onPressed;
  final String? text;
  final Widget? child;

  const CustomButton({super.key, this.onPressed, this.text, this.child})
    : assert(
        text != null || child != null,
        'Either text or child must be provided.',
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            onPressed == null
                ? null
                : () async {
                  await onPressed?.call();
                },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.black87,
          padding: EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child:
            child ??
            Text(text!, style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }
}
