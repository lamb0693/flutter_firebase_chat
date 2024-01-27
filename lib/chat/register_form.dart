
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:image_picker/image_picker.dart';

import 'package:uuid/uuid.dart';

import '../custom_dialog.dart';

class RegisterFormPage extends StatefulWidget {
  const RegisterFormPage({super.key});

  @override
  State<RegisterFormPage> createState() => _RegisterFormPageState();
}

class _RegisterFormPageState extends State<RegisterFormPage> {
  final _auth = FirebaseAuth.instance;

  TextEditingController idController = TextEditingController();
  TextEditingController pwdController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  bool showCircularIndicator = false;

  File? pickedImagefile;

  Completer<void> dialogCompleter = Completer<void>();  // Diaglog dismiss 되었는지 확인 용

  void pickImage() async {
    final imagePicker = ImagePicker();

    final pickedImageFile = await imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxHeight: 150,
    );

    if(pickedImageFile != null ){
      setState(() {
        pickedImagefile = File(pickedImageFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Register Page'),
          backgroundColor: Colors.amber,
        ),
        body: ModalProgressHUD(
          inAsyncCall: showCircularIndicator,
          child: Container(
            padding: const EdgeInsets.all(15.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      pickImage();
                    },
                    child: CircleAvatar(
                      radius: 50.0,
                      backgroundColor: Colors.grey,
                      backgroundImage: pickedImagefile == null? null : FileImage(pickedImagefile!),
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
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
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'put your name',
                    ),
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  IconButton(
                    onPressed: () async {
                      // user image가 없으면 return
                      if(pickedImagefile == null){
                        if(!mounted) return;
                        showDialog(
                            context: context,
                            builder: (context) { return const CustomConfirmDialog('먼저 이미지를 업로드 하세요'); }
                        );
                        return;
                      }
                      try {
                        if(idController.text == null || idController.text.trim() == ''
                            || pwdController.text==null || pwdController.text.trim() == ''
                            || nameController.text==null || nameController.text.trim() == ''){
                          if(!mounted) return;
                          showDialog(
                              context: context,
                              builder: (context) { return const CustomConfirmDialog('id 와 password, name을 입력하세요'); }
                          );
                          return;
                        }
                        setState(() {
                          showCircularIndicator = true;
                        });
                        UserCredential userCred = await _auth.createUserWithEmailAndPassword(
                            email: idController.text,
                            password: pwdController.text,
                        );
                        // 가입 성공
                        if(userCred != null){
                          // image 저장
                          final refImage = FirebaseStorage.instance.ref().child('user_image').child('${userCred.user!.uid}${const Uuid().v1()}.jpg');
                          await refImage.putFile(pickedImagefile!);
                          final imageUrl = await refImage.getDownloadURL();
                          // user 저장 user!.uid가 unique ==> id를 user!.uid로 설정 가능
                          await FirebaseFirestore.instance.collection('users').doc(userCred.user!.uid).set({
                            'email': userCred.user!.email,
                            'imageRef': imageUrl,
                            'name': nameController.text,
                            'uid' : userCred.user!.uid,
                          });
                          setState(() {
                            showCircularIndicator = false;
                          });
                          if(!mounted) return;
                          showDialog(
                              context: context,
                              builder: (context) { return CustomConfirmDialog('가입 완료 ${userCred.user!.email}'); }
                          ).then((_) {
                            dialogCompleter.complete(); // Signal that the dialog is dismissed
                          });
                          await dialogCompleter.future;
                          if(!mounted) return;
                          Navigator.of(context).pop();
                        } else {
                          // To be filled later
                        }
                      } catch(e) {
                        // 회원 가입 이루어 졌으면 삭제해야
                        // 회원 image 등록되었으면 삭제 되어야
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
                ],
              ),
            ),
          ),
        )
    );
  }
}
