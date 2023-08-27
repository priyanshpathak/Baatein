import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:message/cons/all_cons.dart';
import 'package:message/Providers/AuthProvider.dart';
import 'package:message/Screen/home.dart';
import 'package:message/Screen/login.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      checkSignedIn();
    });
  }

  void checkSignedIn() async {
    AuthProvider authProvider = context.read<AuthProvider>();
    bool isLoggedIn = await authProvider.isLoggedIn();
    if (isLoggedIn) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomePage()));
      return;
    }
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Welcome to Baaatein.....",
              style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold, fontSize: Sizes.dimen_18),
            ),
            Image.asset(
              'assets/images/ICON.jpg',
              width: 300,
              height: 300,
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Kyu na Kuch Baatein Hojaye .....",
              style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold, fontSize: Sizes.dimen_18),
            ),
            const SizedBox(
              height: 20,
            ),
            const CircularProgressIndicator(
              color: AppColors.white,
            ),
          ],
        ),
      ),
    );
  }
}