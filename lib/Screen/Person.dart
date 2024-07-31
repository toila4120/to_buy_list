import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_buy_list/Screen/LoginScreen.dart';
import 'package:to_buy_list/services/UserProvider.dart';

class Persion extends StatefulWidget {
  const Persion({super.key});

  @override
  State<Persion> createState() => _PersionState();
}

class _PersionState extends State<Persion> {
  void LogOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Tên: ${user?.nickname}'),
              SizedBox(height: 8),
              Text('Email: ${user?.email}'),
              SizedBox(height: 8),
              TextButton(
                child: Text('LogOut'),
                onPressed: () {
                  LogOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Loginscreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
