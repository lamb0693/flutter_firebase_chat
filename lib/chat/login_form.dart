import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase/chat/register_form.dart';
import 'package:flutter_firebase/custom_dialog.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class LoginFormPage extends StatefulWidget {
  const LoginFormPage({super.key});

  @override
  State<LoginFormPage> createState() => _LoginFormPageState();
}

class _LoginFormPageState extends State<LoginFormPage> {
  final _auth = FirebaseAuth.instance;

  TextEditingController idController = TextEditingController();
  TextEditingController pwdController = TextEditingController();

  bool showCircularIndicator = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
        backgroundColor: Colors.amber,
      ),
      body: ModalProgressHUD(
        inAsyncCall: showCircularIndicator,
        child: Container(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              TextField(
                controller: idController,
                decoration: const InputDecoration(
                  labelText: 'put your email',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(
                height: 15.0,
              ),
              TextField(
                controller: pwdController,
                decoration: const InputDecoration(
                  labelText: 'put your password',
                ),
                obscureText: true,
              ),
              const SizedBox(
                height: 15.0,
              ),
              IconButton(
                onPressed: () async {
                  try {
                    setState(() {
                      showCircularIndicator = true;
                    });
                    UserCredential userCred = await _auth.signInWithEmailAndPassword(
                      email: idController.text,
                      password: pwdController.text
                    );
                    setState(() {
                      showCircularIndicator = false;
                    });
                    if(!mounted) return;
                    showDialog(
                      context: context,
                      builder: (context) { return CustomConfirmDialog('${userCred.user!.email} 님 login 되었어요'); }
                    );
                  } catch(e) {
                    setState(() {
                      showCircularIndicator = false;
                    });
                    if(!mounted) return;
                    showDialog(
                        context: context,
                        builder: (context) { return CustomConfirmDialog(e.toString()); }
                    );
                  }
                },
                icon: const Icon(Icons.send),
                iconSize: 30,
              ),
              const SizedBox(
                height: 40.0,
              ),
              ElevatedButton(
                onPressed: (){
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return const RegisterFormPage();
                      }
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(5.0),
                  width: 200.0,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Icon(Icons.app_registration_outlined,
                        size: 25,
                      ),
                      Text('회원 가입',
                        style: TextStyle(
                          fontSize: 25,
                        ),
                      ),
                    ],
                  ),
                )
              )
            ],
          ),
        ),
      )
    );
  }
}

