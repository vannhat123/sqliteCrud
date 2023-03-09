import 'package:flutter/material.dart';

class UnderlineInputField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final FormFieldValidator? validator;
  const UnderlineInputField({Key? key,required this.hint,this.controller,this.validator}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: TextFormField(
        validator: validator,
         controller: controller,
        decoration: InputDecoration(
           hintText: hint,
        ),
      ),
    );
  }
}
