import 'package:calcount/components/my_button.dart';
import 'package:calcount/components/my_textfield.dart';
import 'package:calcount/firebase/user_firebase_data.dart';
import 'package:calcount/model/user.dart';
import 'package:calcount/providers/user_provider.dart';
import 'package:calcount/screens/login_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

class AccountOptionsPage extends StatelessWidget {
  AccountOptionsPage({super.key});

  final passwordController = TextEditingController();
  final passwordControllerConfirm = TextEditingController();
  final ValueNotifier<bool> passwordsMatch = ValueNotifier<bool>(true);
  final UserFirebaseData userFirebaseData = UserFirebaseData();

  void changePassword(User? user) async {
    if (user != null) {
      final passwordChanged =
          await userFirebaseData.changePassword(user, passwordController.text);
      if (passwordChanged) {
        toastification.show(
          title: const Text('Senha alterada com sucesso.'),
          autoCloseDuration: const Duration(seconds: 5),
          type: ToastificationType.success,
          style: ToastificationStyle.flat,
        );
      }
    }
  }

  void deleteAccount(User? user, BuildContext context) async {
    if (user != null) {
      final accountDeleted = await userFirebaseData.deleteAccount(user);
      if (accountDeleted) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
            ModalRoute.withName('/login'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, userProvider, child) {
      return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text(
              "Conta",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Center(
              child: Column(children: [
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
                        : const Text("Senhas não coincidem",
                            style: TextStyle(color: Colors.red));
                  },
                ),
                const SizedBox(height: 15),
                ValueListenableBuilder<bool>(
                  valueListenable: passwordsMatch,
                  builder: (context, value, child) {
                    return MyButton(
                      onTap: value
                          ? () => changePassword(userProvider.currentUser)
                          : null,
                      contentText: "Alterar Senha",
                      buttonColor: Colors.deepPurple,
                      textColor: Colors.white,
                    );
                  },
                ),
                const SizedBox(height: 50),
                MyButton(
                  onTap: () => deleteAccount(userProvider.currentUser, context),
                  contentText: "Excluir minha conta",
                  buttonColor: null,
                  textColor: Colors.redAccent,
                )
              ]),
            ),
          ));
    });
  }
}
