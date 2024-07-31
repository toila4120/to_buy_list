import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:to_buy_list/Screen/HomeScreen.dart';
import 'package:to_buy_list/Screen/LoginScreen.dart';
import 'package:to_buy_list/services/Authentication.dart';
import 'package:to_buy_list/widget/SnakBar.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passworldController = TextEditingController();
  final _nameController = TextEditingController();

  void signupUser() async {
    String res = await AuthServices().signupUser(
        email: _emailController.text,
        password: _passworldController.text,
        nickname: _nameController.text,
        context: context);
    if (res == "success") {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } else {
      showSnackBar(context, res);
    }
  }

  bool checked = true;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "To \n  Buy \n   List",
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 245, 84, 3)),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                FTextField(
                  label: const Row(
                    children: [
                      Icon(Icons.person_outline_rounded),
                      SizedBox(width: 8),
                      Text('Nickname')
                    ],
                  ),
                  hint: 'Your nickname',
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.none,
                  validator: (value) => 8 <= (value?.length ?? 0)
                      ? null
                      : 'Phiền nhập lại mật khẩu',
                  controller: _nameController,
                ),
                const SizedBox(height: 30),
                FTextField(
                  label: const Row(
                    children: [
                      Icon(Icons.alternate_email_outlined),
                      SizedBox(width: 8),
                      Text('Email')
                    ],
                  ),
                  hint: 'Your email',
                  keyboardType: TextInputType.emailAddress,
                  textCapitalization: TextCapitalization.none,
                  validator: (value) => 8 <= (value?.length ?? 0)
                      ? null
                      : 'Phiền nhập lại mật khẩu',
                  controller: _emailController,
                ),
                const SizedBox(height: 30),
                FTextField.password(
                  label: const Row(
                    children: [
                      Icon(Icons.lock_outline),
                      SizedBox(width: 8),
                      Text('Password')
                    ],
                  ),
                  hint: 'Your password',
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.none,
                  validator: (value) => 8 <= (value?.length ?? 0)
                      ? null
                      : 'Mật khẩu phải có độ dài lớn hơn hoặc bằng 8 ký tự.',
                  controller: _passworldController,
                  suffix: IconButton(
                      onPressed: () {
                        setState(() {
                          checked = !checked;
                        });
                      },
                      icon: checked
                          ? const Icon(Icons.visibility)
                          : const Icon(Icons.visibility_off)),
                  obscureText: checked,
                ),
                const SizedBox(height: 40),
                FButton(
                  onPress: signupUser,
                  label: const Text('Sign Up'),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Loginscreen(),
                        ),
                      );
                    },
                    child: const Text(
                        "Nếu bạn đã có tài khoản đăng nhập tại đây!"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
