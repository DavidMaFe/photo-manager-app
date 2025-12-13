import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager_app/config/theme/photo_manager_colors.dart';


class LoginHeader extends StatelessWidget {

  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            gradient: RadialGradient(colors: [PhotoManagerColors.primary, Color(0xFF6F58ED), Color(0xFF7556EE)]),
            borderRadius: BorderRadius.circular(20)
          ),
          child: Icon(
            Icons.image_outlined,
            color: Colors.white,
            size: 48
          ),
        ),

        SizedBox(height: 16),

        Text(
          "Welcome",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black87
          ),
        ),
        Text(
          "Login into your account",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400
          ),
        )
      ],
    );
  }
}