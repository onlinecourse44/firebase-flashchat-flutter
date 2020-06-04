import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


FirebaseUser loggedUser;
final _fireStore = Firestore.instance;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //here we have to get current users email address.
  final _auth = FirebaseAuth.instance;

  String messageText;

  //to clear the text field when the message has been sent.
  final messageTextController = TextEditingController();

  void getCurrentUser()async{
    try{
      final user = await _auth.currentUser();
      if(user!=null){
        loggedUser = user;
        print(loggedUser.email);
      }
    }
    catch(e){
      print(e);
    }
  }

//  this is just for testing purpose not suitable for chatting.
  void getMessages()async{
    final messages = await _fireStore.collection('messages').getDocuments();
    for(var message in messages.documents){
      print (message.data);
    }
  }

//  for seeing and delivering message in real time.
void messageStream() async{
    await for(var snapshot in _fireStore.collection('messages').snapshots()){
      for (var message in snapshot.documents){
        print(message.data);
      }
    }
}

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
//    messageStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                //Implement logout functionality
                print('Log-out');
                _auth.signOut();
                Navigator.pushReplacementNamed(context, WelcomeScreen.id);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,

//          here the chat works.
          children: <Widget>[
            MessageStream(fireStore: _fireStore),

            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        //Do something with the user input.
                        messageText = value;
                      },
                      controller: messageTextController,
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      //Implement send functionality.
//                      print(messageText);
//                      print(loggedUser.email);
                    _fireStore.collection('messages').add({
                      'sender':loggedUser.email,
                      'text':messageText,
                    });
                    messageTextController.clear();
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      //Implement send functionality.
//                      print(messageText);
//                      print(loggedUser.email);
                    messageStream();
                    },
                    child: Text(
                      'refresh',
                      style: kSendButtonTextStyle,
                    ),
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

//getting messages
class MessageStream extends StatelessWidget {
  const MessageStream({
    Key key,
    @required Firestore fireStore,
  }) : _fireStore = fireStore, super(key: key);

  final Firestore _fireStore;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _fireStore.collection('messages').snapshots(),
      builder:(context,snapshot){
        if(snapshot.hasData){
          final messages = snapshot.data.documents.reversed;
          List<MessageBubble> messageBubbles = [];
          for(var message in messages){
            final messageText = message.data['text'];
            final messageSender = message.data['sender'];
            final currentUser = loggedUser.email;

            final messageBubble = MessageBubble(
                messageText: messageText,
                messageSender: messageSender,
              isMe: currentUser == messageSender,
            );
            messageBubbles.add(messageBubble);
          }
          return Expanded(
            child: ListView(
              reverse: true,
              padding: EdgeInsets.symmetric(vertical: 20,horizontal: 10),
              children: messageBubbles,
            ),
          );
        }else{
          return Container(
            child: Text('No Data Found'),
          );
        }
      },
    );
  }
}

//for every messages
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    Key key,
    @required this.messageText,
    @required this.messageSender,
    @required this.isMe,
  }) : super(key: key);

  final bool isMe;
  final String messageText;
  final String messageSender;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(messageSender,style: TextStyle(
            fontSize: 12,
            color: Colors.black54
          ),),
          Material(
            borderRadius: isMe ? BorderRadius.only(
              topLeft: Radius.circular(25),
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ) : BorderRadius.only(
              topRight: Radius.circular(25),
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
            color: isMe ? Colors.lightBlueAccent : Colors.red,
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
              child: Text('$messageText',
                style: TextStyle(
                  fontSize: 15,
                ),),
            ),
          ),
        ],
      ),
    );
  }
}