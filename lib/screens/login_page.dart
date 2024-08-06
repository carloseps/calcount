import 'package:calcount/firebase/user_firebase_data.dart';
import 'package:calcount/model/user.dart';
import 'package:calcount/providers/user_provider.dart';
import 'package:calcount/screens/app_home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

import '../components/my_button.dart';
import '../components/my_textfield.dart';
import 'register_page.dart';

import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final UserFirebaseData userFirebaseData = UserFirebaseData();

  final SharedPreferencesAsync prefs = SharedPreferencesAsync();

  final LocalAuthentication auth = LocalAuthentication();
  bool _canAuthenticateWithBiometrics = false;

  Future<bool> _checkIfAuthCredentialsAreStored() async {
    final userEmail = await prefs.getString('user_email');
    final userPassword = await prefs.getString('user_password');

    return userEmail != null && userPassword != null;
  }

  Future<Map<String, String>> _fetchAuthUserData() async {
    final userEmail = await prefs.getString('user_email') ?? '';
    final userPassword = await prefs.getString('user_password') ?? '';

    return {
      'email': userEmail,
      'password': userPassword,
    };
  }

  Future<void> _checkForBiometricAuth() async {
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final bool isDeviceSupportedToCheckBiometrics =
        await auth.isDeviceSupported();

    _canAuthenticateWithBiometrics =
        canAuthenticateWithBiometrics || isDeviceSupportedToCheckBiometrics;
  }

  Future<void> _callBiometricAuth(Function (String, String) callback, String arg1, String arg2) async {
    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Utilize sua biometria para prosseguir.',
          options: const AuthenticationOptions(biometricOnly: true));

      if (didAuthenticate) {
        await callback(arg1, arg2);
      }
    } on PlatformException catch (e) {
      print('erro' + e.code);
    }
  }

  Future<void> _authenticateWithBiometric() async {
    final userData = await _fetchAuthUserData();
    final email = userData['email'] ?? '';

    final password = userData['password'] ?? '';

      if (userData['email'] == null || userData['email'] == '') {
        return;
      }

      _emailController.text = email;

      await _callBiometricAuth(signUserIn, email, password);
  }

  Future<void> asyncInitAuthState() async {
    await _checkForBiometricAuth();
    final areCredentialsStored = await _checkIfAuthCredentialsAreStored();
    if (_canAuthenticateWithBiometrics && areCredentialsStored) {
      await _authenticateWithBiometric();
    }
  }

  Future<void> _storeLoginCredentials(String email, String password) async {
      await prefs.setString('user_email', email);
      await prefs.setString('user_password', password);

      toastification.show(
        title: const Text('Biometria habilitada com sucesso.'),
        autoCloseDuration: const Duration(seconds: 5),
        type: ToastificationType.success,
        style: ToastificationStyle.flat,
      );

      _goToHomePage();
  }

  @override
  void initState() {
    super.initState();
    asyncInitAuthState();
  }

  void _goToHomePage() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => const AppHomePage(
                  title: 'CalCount',
                )),
        ModalRoute.withName('/home'));
  }

  void signUserIn(String email, String password) async {
    User user = await userFirebaseData.findUserByAttribute('email', email);

    if (user.id == null) {
      toastification.show(
        title: const Text('Não existe um usuário cadastrado com esse email.'),
        autoCloseDuration: const Duration(seconds: 5),
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
      );

      return;
    }

    if (user.password != password) {
      toastification.show(
        title: const Text('Senha inválida.'),
        autoCloseDuration: const Duration(seconds: 5),
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
      );

      return;
    }

    Provider.of<UserProvider>(context, listen: false).setCurrentUser(user);

    final areCredentialsStored = await _checkIfAuthCredentialsAreStored();

    if (!areCredentialsStored) {
      await openBiometricUseDialog();
    }

    _goToHomePage();
  }

  Future<String?> openBiometricUseDialog() {
    return showDialog<String>(
        context: context,
        builder: (BuildContext buildContext) => Dialog(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: SvgPicture.asset(
                            'lib/images/fingerprint_24dp_434343_FILL0_wght400_GRAD0_opsz24.svg',
                            height: 50,
                          ),
                        ),
                        const Text('Deseja habilitar a biometria?', textAlign: TextAlign.center,),
                        const SizedBox(),
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _goToHomePage();
                                },
                                child: const Text('Fechar'),
                              ),
                              TextButton(
                                onPressed: () {
                                  _callBiometricAuth(_storeLoginCredentials, _emailController.text, _passwordController.text);
                                },
                                child: const Text('Habilitar'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ));
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
                controller: _emailController,
                hintText: 'Email',
                obscureText: false,
              ),
              const SizedBox(height: 10),
              MyTextField(
                controller: _passwordController,
                hintText: 'Senha',
                obscureText: true,
              ),
              const SizedBox(height: 25),
              MyButton(
                contentText: "Entrar",
                onTap: () => signUserIn(_emailController.text, _passwordController.text),
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
