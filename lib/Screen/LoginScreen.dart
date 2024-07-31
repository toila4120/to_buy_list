import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:to_buy_list/Screen/HomeScreen.dart';
import 'package:to_buy_list/Screen/SignUpScreen.dart';
import 'package:to_buy_list/services/Authentication.dart';
import 'package:to_buy_list/widget/SnakBar.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool checked = true;

  void loginUser() async {
    // signup user using our authmethod
    String res = await AuthServices().loginUser(
        email: _emailController.text,
        password: _passwordController.text,
        context: context);
    if (res == "success") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );
    } else {
      showSnackBar(context, res);
    }
  }

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
                Text(
                  "To \n  Buy \n   List",
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 245, 84, 3)),
                ),
                SizedBox(height: 40),
                Text(
                  'Sign In',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 16),
                FTextField(
                  label: Row(
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
                SizedBox(height: 30),
                FTextField.password(
                  label: Row(
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
                  controller: _passwordController,
                  suffix: IconButton(
                      onPressed: () {
                        setState(() {
                          checked = !checked;
                        });
                      },
                      icon: checked
                          ? Icon(Icons.visibility)
                          : Icon(Icons.visibility_off)),
                  obscureText: checked,
                ),
                SizedBox(height: 40),
                FButton(
                  onPress: () {
                    loginUser();
                  },
                  label: Text('Login'),
                ),
                SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignUpScreen(),
                        ),
                      );
                    },
                    child: Text("Nếu bạn chưa có tài khoản đăng ký tại đây!"),
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