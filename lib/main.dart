import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ChatPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

const backgroundColor = Color(0xff343541);
const botBackgroundColor = Color(0xff444654);

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

Future<String> generateResponse(String prompt) async {
  const apiKey = "TOKEN";

  final response = await http.post(
      Uri.parse('https://api.openai.com/v1/images/generations'),
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $apiKey"
      },
      body: jsonEncode({
        'model': 'image-alpha-001',
        'prompt': prompt.toString().trim().replaceAll(RegExp(r' \s+'), ' '),
        'num_images': 1,
        'size': '256x256'
      }));
  // final response = await http.post(
  //   url,
  //   headers: {
  //     'Content-Type': 'application/json',
  //     "Authorization": "Bearer $apiKey"
  //   },
  //   body: json.encode({
  //     "model": "text-davinci-003",
  //     "prompt": prompt,
  //     'temperature': 0,
  //     'max_tokens': 2000,
  //     'top_p': 1,
  //     'frequency_penalty': 0.0,
  //     'presence_penalty': 0.0,
  //   }),
  // );

  // Do something with the response
  Map<String, dynamic> newresponse =
      jsonDecode(utf8.decode(response.bodyBytes));

  return newresponse['data'][0]['url'];
}

class _ChatPageState extends State<ChatPage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  late bool isLoading;

  @override
  void initState() {
    super.initState();
    isLoading = false;
  }

  sendPrompt() {
    setState(
      () {
        _messages.add(
          ChatMessage(
            text: _textController.text
                .toString()
                .trim()
                .replaceAll(RegExp(r' \s+'), ' '),
            chatMessageType: ChatMessageType.user,
          ),
        );
        isLoading = true;
      },
    );
    var input = _textController.text;
    _textController.clear();
    Future.delayed(const Duration(milliseconds: 50)).then((_) => _scrollDown());
    generateResponse(input).then((value) {
      setState(() {
        isLoading = false;
        _messages.add(
          ChatMessage(
            text: value.toString().trim().replaceAll(RegExp(r' \s+'), ' '),
            chatMessageType: ChatMessageType.bot,
          ),
        );
      });
    });
    _textController.clear();
    Future.delayed(const Duration(milliseconds: 50)).then((_) => _scrollDown());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "OpenAI's ChatGPT Flutter Example @CanArslanDev",
            maxLines: 2,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),
        ),
        backgroundColor: botBackgroundColor,
      ),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildList(),
            ),
            Visibility(
              visible: isLoading,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  _buildInput(),
                  _buildSubmit(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmit() {
    return Visibility(
      visible: !isLoading,
      child: Container(
        color: botBackgroundColor,
        child: IconButton(
          icon: const Icon(
            Icons.send_rounded,
            color: Color.fromRGBO(142, 142, 160, 1),
          ),
          onPressed: () => sendPrompt(),
        ),
      ),
    );
  }

  Expanded _buildInput() {
    return Expanded(
      child: TextField(
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(color: Colors.white),
        controller: _textController,
        decoration: const InputDecoration(
          fillColor: botBackgroundColor,
          filled: true,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
      ),
    );
  }

  ListView _buildList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        var message = _messages[index];
        return ChatMessageWidget(
          text: message.text,
          chatMessageType: message.chatMessageType,
        );
      },
    );
  }

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}

class ChatMessageWidget extends StatelessWidget {
  const ChatMessageWidget(
      {super.key, required this.text, required this.chatMessageType});

  final String text;
  final ChatMessageType chatMessageType;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      padding: const EdgeInsets.all(16),
      color: chatMessageType == ChatMessageType.bot
          ? botBackgroundColor
          : backgroundColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          chatMessageType == ChatMessageType.bot
              ? Container(
                  margin: const EdgeInsets.only(right: 16.0),
                  child: CircleAvatar(
                      backgroundColor: const Color.fromRGBO(16, 163, 127, 1),
                      child: Image.network(
                          "https://p16-sign-va.tiktokcdn.com/tos-maliva-avt-0068/f5f9c186305e769c7ae49bd7ed601aa4~c5_720x720.jpeg?x-expires=1675245600&x-signature=yeUPpBvNSVk3MURpqEG5PYrT9yA%3D")),
                )
              : Container(
                  margin: const EdgeInsets.only(right: 16.0),
                  child: const CircleAvatar(
                    child: Icon(
                      Icons.person,
                    ),
                  ),
                ),
          chatMessageType == ChatMessageType.bot
              ? SizedBox(height: 100, child: Image.network(text))
              : Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                        child: Text(
                          text,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}



// FieldValue timestampChatGPT = FieldValue.serverTimestamp();
//         String apiKey = await AetheFunctions().serverGetChatGPTApiKey();
//         final response = await http.post(
//             Uri.parse('https://api.openai.com/v1/images/generations'),
//             headers: {
//               'Content-Type': 'application/json',
//               "Authorization": "Bearer $apiKey"
//             },
//             body: jsonEncode({
//               'model': 'image-alpha-001',
//               'prompt': messageContext
//                   .toString()
//                   .trim()
//                   .replaceAll(RegExp(r' \s+'), ' '),
//               'num_images': 1,
//               'size': '256x256'
//             }));
//         var responseJson = jsonDecode(response.body);
//         await servers
//             .doc(serverId)
//             .collection("channels/$sidebarMenuChannelId/messages")
//             .add(
//           {
//             'messageType': 2,
//             'messageContext': 'Prompt: $messageContext',
//             'imageUrl': responseJson['data'][0]['url']
//                 .toString()
//                 .trim()
//                 .replaceAll(RegExp(r' \s+'), ' '),
//             'timestamp': timestampChatGPT,
//             'messageUserProfilePhotoUrl':
//                 await AetheFunctions().getChatGPTProfilePhoto(),
//             'messageUserId': "",
//             'messageUserUsername': await AetheFunctions().getChatGPTUsername(),
//             'messageReplyText': "",
//             'messageReplyUser': "",
//             'messageReplyId': "",
//           },
//         );