//login page

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photographers/features/auth/presentation/components/my_buttons.dart';
import 'package:photographers/features/auth/presentation/components/my_text_field.dart';
import 'package:photographers/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:photographers/reponsive/constrained_scaffold.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.togglepage});
  final void Function()? togglepage;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailcontroller = TextEditingController();
  final passwordcontroller = TextEditingController();

  void login() {
    //prepare email and pass
    final email = emailcontroller.text;
    final pw = passwordcontroller.text;

    // auth eamil
    final authcubit = context.read<AuthCubit>();

    //auth eamil and pass not empty
    if (email.isNotEmpty && pw.isNotEmpty) {
      authcubit.login(email, pw);
    }
    //else show error
    else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please enter both email and password")));
    }
  }

  @override
  void dispose() {
    emailcontroller.dispose();
    passwordcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedScaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 100,
              ),
              Image.asset('assets/images/icons.png', scale: 5),
              SizedBox(
                height: 20,
              ),
              Text(
                "Welcome back! ",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.normal),
              ),
              SizedBox(
                height: 20,
              ),
              MyTextField(
                  controller: emailcontroller,
                  hinttext: "Email",
                  obscureText: false),
              SizedBox(
                height: 25,
              ),
              MyTextField(
                  controller: passwordcontroller,
                  hinttext: "Password",
                  obscureText: true),
              SizedBox(
                height: 25,
              ),
              MyButtons(
                  onTap: () {
                    login();
                  },
                  text: "Login"),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Not a Member?",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.normal),
                  ),
                  GestureDetector(
                    onTap: widget.togglepage,
                    child: Text(
                      " Register Now",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      )),
    );
  }
}
