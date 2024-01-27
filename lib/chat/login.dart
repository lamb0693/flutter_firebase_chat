import 'package:flutter/material.dart';
import 'package:flutter_firebase/chat/login_form.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'chat_screen.dart';

class LoginChatPage extends StatefulWidget {
  const LoginChatPage({super.key});

  @override
  State<LoginChatPage> createState() => _LoginChatPageState();
}

class _LoginChatPageState extends State<LoginChatPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot){
        if(snapshot.hasData){
          return const ChatScreenPage();
        }else {
          return const LoginFormPage();
        }
      }
    );
  }
}
