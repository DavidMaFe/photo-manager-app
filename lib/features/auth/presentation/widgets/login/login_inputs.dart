import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager_app/config/theme/photo_manager_colors.dart';


class LoginInputs extends StatefulWidget{

  final TextEditingController emailInputController;
  final TextEditingController passwordInputController;
  final bool enabled;

  const LoginInputs({
    super.key,
    required this.emailInputController,
    required this.passwordInputController,
    this.enabled = true
  });

  @override
  State<StatefulWidget> createState() => _LoginInputsState();
}

class _LoginInputsState extends State<LoginInputs> {

  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Email",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87
          ),
        ),

        SizedBox(height: 8),

        TextFormField(
          controller: widget.emailInputController,
          keyboardType: TextInputType.emailAddress,
          enabled: widget.enabled,

          validator: (value) {
            if(value == null || value.trim().isEmpty) {
              return 'Please, write an email address';
            }

            if(!value.contains('@') || !value.contains('.')) {
              return 'Email address not valid';
            }

            return null;
          },

          decoration: InputDecoration(
            hintText: "your@email.com",
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[50],

            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2)
            ),

            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2)
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!)
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!)
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: PhotoManagerColors.primary, width: 2)
            ),

            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16)
          ),
        ),

        SizedBox(height: 20),

        Text(
          "Password",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87
          ),
        ),

        SizedBox(height: 8),

        TextFormField(
          controller: widget.passwordInputController,
          obscureText: _obscurePassword,
          enabled: widget.enabled,

          validator: (value) {
            if(value == null || value.trim().isEmpty) {
              return 'Please, write a password';
            }

            return null;
          },

          decoration: InputDecoration(
            hintText: "*********",
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[50],

            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2)
            ),

            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2)
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!)
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!)
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: PhotoManagerColors.primary, width: 2)
            ),

            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: IconButton(icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey[600],
            ),

            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            })
          ),
        )
      ],
    );
  }
}