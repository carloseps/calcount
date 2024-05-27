import 'package:calcount/firebase/user_firebase_data.dart';
import 'package:calcount/model/user.dart';
import 'package:calcount/providers/user_provider.dart';
import 'package:calcount/screens/app_home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

import '../components/my_button.dart';
import '../components/my_textfield.dart';
import 'register_page.dart';
import 'package:get/get.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final UserFirebaseData userFirebaseData = UserFirebaseData();

  void signUserIn(BuildContext context) async {
    User user = await userFirebaseData.findUserByAttribute(
        'email', emailController.text);

    if (user.id == null) {
      toastification.show(
        title: const Text('Não existe um usuário cadastrado com esse email.'),
        autoCloseDuration: const Duration(seconds: 5),
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
      );

      return;
    }

    if (user.password != passwordController.text) {
      toastification.show(
        title: const Text('Senha inválida.'),
        autoCloseDuration: const Duration(seconds: 5),
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
      );

      return;
    }

    Provider.of<UserProvider>(context, listen: false).setCurrentUser(user);

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => const AppHomePage(
                  title: 'CalCount',
                )),
        ModalRoute.withName('/home'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 100,
                backgroundImage: AssetImage('lib/images/logo2.png'),
              ),
              const SizedBox(height: 25),
              Text(
                'Bem vindo de volta! 😍',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
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
              const SizedBox(height: 25),
              MyButton(
                contentText: "Entrar",
                onTap: () => signUserIn(context),
                buttonColor: Colors.deepPurple,
                textColor: Colors.white,
              ),
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Não possui uma conta?',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => RegisterPage(),
                          transition: Transition.circularReveal,
                          duration: const Duration(seconds: 2));
                    },
                    child: const Text(
                      'Registre-se',
                      style: TextStyle(
                        color: Colors.deepPurple,
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
