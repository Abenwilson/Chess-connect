import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photographers/features/auth/presentation/components/my_buttons.dart';
import 'package:photographers/features/auth/presentation/components/my_text_field.dart';
import 'package:photographers/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:photographers/reponsive/constrained_scaffold.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, required this.togglepage});
  final void Function()? togglepage;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final namecontroller = TextEditingController();
  final emailcontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  final confirmpasscontroller = TextEditingController();
  final professioncontroller = TextEditingController();

  // register button pressed

  void register() {
    final String name = namecontroller.text;
    final String email = emailcontroller.text;
    final String pw = passwordcontroller.text;
    final String cpw = confirmpasscontroller.text;
    final String pro = professioncontroller.text;

    //auth cubit

    final authcubit = context.read<AuthCubit>();

    if (name.isNotEmpty &&
        email.isNotEmpty &&
        pw.isNotEmpty &&
        cpw.isNotEmpty &&
        pro.isNotEmpty) {
      if (pw == cpw) {
        authcubit.register(
          name,
          email,
          pw,
          pro,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          "Password Not Matching",
          style: TextStyle(color: Colors.black),
        )));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        "Please Fill All Fields",
        style: TextStyle(color: Colors.black),
      )));
    }
  }

  @override
  void dispose() {
    namecontroller.dispose();
    emailcontroller.dispose();
    passwordcontroller.dispose();
    professioncontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedScaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 80,
                ),
                Image.asset(
                  'assets/images/icons.png',
                  scale: 6,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Hi, Nice To meet You",
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
                    controller: namecontroller,
                    hinttext: "Name",
                    obscureText: false),
                SizedBox(
                  height: 25,
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
                MyTextField(
                    controller: confirmpasscontroller,
                    hinttext: "Confirm Password",
                    obscureText: true),
                SizedBox(
                  height: 25,
                ),
                MyTextField(
                    controller: professioncontroller,
                    hinttext: "Profession",
                    obscureText: false),
                SizedBox(
                  height: 25,
                ),
                SizedBox(
                  height: 25,
                ),
                MyButtons(
                    onTap: () {
                      register();
                    },
                    text: "Register"),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already a Member?",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal),
                    ),
                    GestureDetector(
                      onTap: widget.togglepage,
                      child: Text(
                        " Login Now",
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
        ),
      ),
    );
  }
}
