import 'package:calcount/screens/login_page.dart';
import 'package:flutter/material.dart';

import '../components/my_button.dart';
import '../components/my_textfield.dart';
import 'package:get/get.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordControllerConfirm = TextEditingController();
  final ValueNotifier<bool> passwordsMatch = ValueNotifier<bool>(true);

  void signUpUser() {
    //signUp logic
  }

  void checkPasswordsMatch() {
    passwordsMatch.value = passwordController.text == passwordControllerConfirm.text;
  }

  @override
  Widget build(BuildContext context) {
    passwordController.addListener(checkPasswordsMatch);
    passwordControllerConfirm.addListener(checkPasswordsMatch);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.deepPurple,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 100, // Define o tamanho do círculo
                backgroundImage: AssetImage('lib/images/logo.png'),
              ),
              const SizedBox(height: 25),

              Text(
                'Crie uma conta para começar! 😎',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 25),

              MyTextField(
                controller: emailController,
                hintText: 'Email',
                obscureText: false,
              ),

              const SizedBox(height: 10),

              MyTextField(
                controller: passwordController,
                hintText: 'Senha',
                obscureText: true,
              ),

              const SizedBox(height: 10),

              MyTextField(
                controller: passwordControllerConfirm,
                hintText: 'Confirme a Senha',
                obscureText: true,
              ),

              const SizedBox(height: 15),
              ValueListenableBuilder<bool>(
                valueListenable: passwordsMatch,
                builder: (context, value, child) {
                  return value
                      ? const SizedBox(height: 15)
                      : Text("Senhas não coincidem", style: TextStyle(color: Colors.red));
                },
              ),
              const SizedBox(height: 15),

              ValueListenableBuilder<bool>(
                valueListenable: passwordsMatch,
                builder: (context, value, child) {
                  return MyButton(
                    onTap: value ? signUpUser : null, 
                    contentText: "Registre-se",
                    buttonColor: Colors.white,
                    textColor: Colors.deepPurple,
                  );
                },
              ),

              const SizedBox(height: 60),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Já possui uma conta?',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => LoginPage(),
                          transition: Transition.circularReveal,
                          duration: Duration(seconds: 2));
                    },
                    child: const Text(
                      'Entrar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
