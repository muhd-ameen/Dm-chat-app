// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/message.dart';
import '../data/message_dao.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'message_widget.dart';
import '../data/user_dao.dart';

class MessageList extends StatefulWidget {
  const MessageList({Key? key}) : super(key: key);

  @override
  MessageListState createState() => MessageListState();
}

class MessageListState extends State<MessageList> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? email;
  int deletetime = 3;
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((_) => _scrollToBottom());
    final messageDao = Provider.of<MessageDao>(context, listen: false);
    final userDao = Provider.of<UserDao>(context, listen: false);
    email = userDao.email();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal[800],
        title: const Text('DM'),
        actions: [
          IconButton(
            onPressed: () {
              userDao.logout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Colors.green,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.verified_user_rounded, color: Colors.white),
                        const SizedBox(width: 10.0),
                        Text(
                          email.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      deletetime == 0
                          ? deletetime = 0
                          : deletetime = deletetime - 1;
                    });
                  },
                  color: Colors.green,
                  icon: Icon(Icons.remove_circle),
                ),
                Text(
                  '$deletetime',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      deletetime = deletetime + 1;
                    });
                  },
                  color: Colors.green,
                  icon: Icon(Icons.add_circle),
                )
              ],
            ),
            _getMessageList(messageDao),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: TextField(
                      keyboardType: TextInputType.text,
                      controller: _messageController,
                      onSubmitted: (input) {
                        _sendMessage(messageDao);
                      },
                      decoration:
                          const InputDecoration(hintText: 'Enter new message'),
                    ),
                  ),
                ),
                IconButton(
                    icon: Icon(_canSendMessage()
                        ? CupertinoIcons.arrow_right_circle_fill
                        : CupertinoIcons.arrow_right_circle),
                    onPressed: () {
                      Future.delayed(Duration(seconds: deletetime), () {
                        final messageDao =
                            Provider.of<MessageDao>(context, listen: false);
                        messageDao.deleteAllMessages();
                      });
                      _sendMessage(messageDao);
                    })
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(MessageDao messageDao) {
    if (_canSendMessage()) {
      final message = Message(
        text: _messageController.text,
        date: DateTime.now(),
        email: email,
      );
      messageDao.saveMessage(message);
      _messageController.clear();
      setState(() {});
    }
  }

  Widget _getMessageList(MessageDao messageDao) {
    return Expanded(
      // 1
      child: StreamBuilder<QuerySnapshot>(
        // 2
        stream: messageDao.getMessageStream(),
        // 3
        builder: (context, snapshot) {
          // 4
          if (!snapshot.hasData)
            return const Center(child: LinearProgressIndicator());

          // 5
          return _buildList(context, snapshot.data!.docs);
        },
      ),
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot>? snapshot) {
    // 1
    return ListView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 20.0),
      // 2
      children: snapshot!.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot snapshot) {
    final message = Message.fromSnapshot(snapshot);
    // 2
    return GestureDetector(
        child: MessageWidget(message.text, message.date, message.email));
  }

  bool _canSendMessage() => _messageController.text.length > 0;

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }
}
