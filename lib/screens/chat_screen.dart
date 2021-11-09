import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat_flutter/constants.dart';
import 'package:flutter/painting.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';




final _firestore = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;
User loggedInUser;

class ChatScreen extends StatefulWidget {
  // It is used for routes and initial routes.
  static const String id = "chat_screen";

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String messageText;

  final ButtonStyle style =
  ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));

  final messageController = TextEditingController();

  // Get current user.
  void getUser() async {
    try {
      if (_auth != null) {
        loggedInUser = _auth.currentUser;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () async {
                await _auth.signOut();
                Navigator.pop(context);
              }),

        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[

            MessageStream(),

            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[


                  Expanded(
                    child: TextField(
                      controller: messageController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),

                  IconButton(
                    onPressed: ()  {
                      showMaterialModalBottomSheet(
                        context: context,
                        builder: (context) => SingleChildScrollView(
                          controller: ModalScrollController.of(context),
                          child:  Column(
                            children: [
                              Container(
                                height: 200,
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          ElevatedButton.icon(
                                            label: Text('Doc.',style: TextStyle(
                                              fontSize: 30,
                                            ),),
                                            style: style,
                                            onPressed: () {},
                                            icon: const Icon(Icons.book_rounded,size: 30,color: Colors.white,),
                                          ),
                                          SizedBox(width: 15,),
                                          ElevatedButton.icon(
                                            label: Text('Location',style: TextStyle(
                                              fontSize: 30,
                                            ),),
                                            style: style,
                                            onPressed: () {},
                                            icon: const Icon(Icons.location_on_outlined,size: 30,color: Colors.white,),

                                          ),
                                        ],

                                      ),

                                      Row(
                                        children: [
                                          ElevatedButton.icon(
                                            label: Text('Camera',style: TextStyle(
                                              fontSize: 30,
                                            ),),
                                            style: style,
                                            onPressed: () {},
                                            icon: const Icon(Icons.camera_alt,size: 30,color: Colors.white,),

                                          ),
                                          SizedBox(width: 15,),
                                          ElevatedButton.icon(
                                            label: Text('Gallery',style: TextStyle(
                                              fontSize: 30,
                                            ),),
                                            style: style,
                                            onPressed: () {},
                                            icon: const Icon(Icons.image,size: 30,color: Colors.white,),

                                          ),
                                        ],

                                      ),

                                      Row(
                                        children: [
                                          ElevatedButton.icon(
                                            label: Text('Audio',style: TextStyle(
                                              fontSize: 30,
                                            ),),
                                            style: style,
                                            onPressed: () {},
                                            icon: const Icon(Icons.audiotrack_outlined,size: 30,color: Colors.white,),

                                          ),
                                          SizedBox(width: 15,),
                                          ElevatedButton.icon(
                                            label: Text('Contact',style: TextStyle(
                                              fontSize: 30,
                                            ),),
                                            style: style,
                                            onPressed: () {},
                                            icon: const Icon(Icons.contact_phone_sharp,size: 30,color: Colors.white,),

                                          ),
                                        ],

                                      ),
                                    ],
                                  ),
                                ),

                              ),
                            ],
                          ),
                        ),
                      );


                    },


                    icon: const Icon(Icons.attach_file_outlined,size: 30,),

                  ),
                  IconButton(

                    onPressed: () async  {
                      messageController.clear();
                      await _firestore.collection("messages").add({
                        "text": messageText,
                        "user": loggedInUser.email,
                        "time": FieldValue.serverTimestamp(),
                      }).whenComplete(() => print("comleted"));

                    },
                    icon: const Icon(Icons.send_sharp),
                    //  Text(
                    //   'Send',
                    //   style: kSendButtonTextStyle,
                    // ),
                  ),
                ],
              ),

            ),

          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _firestore.collection("messages").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final messages = snapshot.data.docs.reversed;
          List<MessageBubble> messageBubbles = [];
          List<Text> messageWidgets = [];
          for (var message in messages) {
            final  messageText = message.data()['text'];
            final String messageSender = message.data()["user"];
            final Timestamp messageTime = message.data()["time"] as Timestamp;
            // final messageWidget = Text('$messageText from $messageSender');
             //messageWidgets.add(messageWidget);

            final currentUser = loggedInUser.email;

            final messageBubble = MessageBubble(
              messageText: messageText,
              messageSender: messageSender,
              isMe: currentUser == messageSender,
              time: messageTime,
            );
            messageBubbles.add(messageBubble);
            messageBubbles
                .sort((a, b) => b.time.toString().compareTo(a.time.toString()));
          }

          return Expanded(
              child: ListView(

            reverse: true,
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
            children: messageBubbles,

          ));


        });
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble({this.messageText, this.messageSender, this.isMe, this.time});

  final String messageText;
  final String messageSender;
  final bool isMe;
  final Timestamp time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(messageSender ?? 'hy'),

          // Text(
          //   messageSender,
          //   style: TextStyle(fontSize: 10.0),
          // ),
          Material(
            shadowColor: Colors.black,
            elevation: 15.0,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isMe ? 30.0 : 0.0),
              bottomLeft: Radius.circular(30.0),
              topRight: Radius.circular(isMe ? 0.0 : 30.0),
              bottomRight: Radius.circular(30.0),
            ),
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                messageText,
                style: TextStyle(
                    color: isMe ? Colors.white : Colors.black, fontSize: 20.0),
              ),
            ),
          ),


        ],
      ),
    );
  }
}