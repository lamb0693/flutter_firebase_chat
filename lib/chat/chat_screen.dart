import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_chat_bubble/chat_bubble.dart';

class ChatScreenPage extends StatefulWidget {
  const ChatScreenPage({super.key});

  @override
  State<ChatScreenPage> createState() => _ChatScreenPageState();
}

class _ChatScreenPageState extends State<ChatScreenPage> {
  TextEditingController messageController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  bool isMe(uid){
    if(_auth.currentUser!.uid == uid) {
      return true;
    } else {
      return false;
    }
  }

  void sendMessge() async {
    final userData = await FirebaseFirestore.instance.collection('users')
        .doc(_auth.currentUser!.uid).get();

    if(mounted) FocusScope.of(context).unfocus();
    FirebaseFirestore.instance.collection('chat').add({
      'text' : messageController.text,
      'uid' : _auth.currentUser!.uid,
      'created_at' : Timestamp.now(),
      'username' : userData.data()?['name'],
    });
    messageController.text='';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Page'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            onPressed: () {FirebaseAuth.instance.signOut();},
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('chat').orderBy('created_at').snapshots(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final chatDocs = snapshot.data.docs;
                return Expanded(
                  child: ListView.builder(
                    itemCount: chatDocs.length,
                    itemBuilder: (BuildContext context, int index) {
                      return FutureBuilder(
                        future: FirebaseFirestore.instance.collection('users').doc(chatDocs[index]['uid']).get(),
                        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> userSnapshot){
                          if (userSnapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }

                          if( isMe(chatDocs[index]['uid']) ){
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ChatBubble(
                                  clipper: ChatBubbleClipper1(type: BubbleType.sendBubble),
                                  alignment: Alignment.topRight,
                                  margin: const EdgeInsets.only(top: 20),
                                  backGroundColor: Colors.blue,
                                  child: Container(
                                    constraints: BoxConstraints(
                                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          chatDocs[index]['username'],
                                          style : const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          )
                                        ),
                                        Text(
                                          chatDocs[index]['text'],
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                CircleAvatar(
                                  radius: 25.0,
                                  backgroundColor: Colors.grey,
                                  backgroundImage: NetworkImage(userSnapshot.data!['imageRef']),
                                )
                              ],
                            );
                          } else {
                            return Row(
                              children: [
                                CircleAvatar(
                                  radius: 25.0,
                                  backgroundColor: Colors.grey,
                                  backgroundImage: NetworkImage(userSnapshot.data!['imageRef']),
                                ),
                                ChatBubble(
                                  clipper: ChatBubbleClipper1(type: BubbleType.receiverBubble),
                                  backGroundColor: Colors.red,
                                  margin: const EdgeInsets.only(top: 20),
                                  child: Container(
                                    constraints: BoxConstraints(
                                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                            chatDocs[index]['username'],
                                            style : const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            )
                                        ),
                                        Text(
                                          chatDocs[index]['text'],
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      );
                    },
                  ),
                );
              }
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      labelText: 'put message to send',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: sendMessge,
                  icon: const Icon(Icons.send_outlined),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
