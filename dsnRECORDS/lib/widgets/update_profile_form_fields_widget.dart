import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileFormFields extends StatelessWidget {
  final TextEditingController controller;
  final IconData data;
  final String txtHint;
  bool obsecure = true;

  ProfileFormFields({
    super.key,
    required this.controller,
    required this.data,
    required this.txtHint,
    required this.obsecure,
    required String? Function(dynamic value) validator,

  });

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var isSmallScreen = width < 600;

    return Container(
      width: isSmallScreen ? width * 0.8 : width * 0.6,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      padding: EdgeInsets.all(0),
      margin: EdgeInsets.all(5),
      child: TextFormField(
        controller: controller,
        obscureText: obsecure,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(
            data,
            color: Colors.grey,
          ),
          hintText: txtHint,
          hintStyle: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
          ),
        ),
        style: TextStyle(
          fontSize: isSmallScreen ? 14 : 16,
        ),
      ),
    );
  }
}

