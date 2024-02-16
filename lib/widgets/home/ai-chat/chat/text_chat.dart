import 'package:flutter/material.dart';
import 'package:google_gemini/google_gemini.dart';
import 'package:pregathi/const/constants.dart';

class TextChat extends StatefulWidget {
  const TextChat({
    super.key,
  });

  @override
  State<TextChat> createState() => _TextChatState();
}

class _TextChatState extends State<TextChat> {
  bool loading = false;
  List textChat = [];
  List textWithImageChat = [];

  final TextEditingController _textController = TextEditingController();
  final ScrollController _controller = ScrollController();

  final gemini = GoogleGemini(
    apiKey: apiKey,
  );

  void fromText({required String query, required String prompt}) {
    setState(() {
      loading = true;
      textChat.add({
        "role": "Me",
        "text": query,
        "avatar": "Me",
      });
      _textController.clear();
    });
    scrollToTheEnd();

    gemini.generateFromText(prompt + " " + query).then((value) {
      setState(() {
        loading = false;
        textChat.add({
          "role": "AI Doc",
          "text": value.text,
          "avatar": 'AI',
        });
      });
      scrollToTheEnd();
    }).onError((error, stackTrace) {
      setState(() {
        loading = false;
        textChat.add({
          "role": "AI Doc",
          "text": error.toString(),
          "avatar": 'AI',
        });
      });
      scrollToTheEnd();
    });
  }

  void scrollToTheEnd() {
    _controller.jumpTo(_controller.position.maxScrollExtent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _controller,
            itemCount: textChat.length,
            padding: const EdgeInsets.only(bottom: 20),
            itemBuilder: (context, index) {
              return ListTile(
                isThreeLine: true,
                leading: CircleAvatar(
                  child: Text(textChat[index]["avatar"].substring(0,2)),
                ),
                title: Text(textChat[index]["role"]),
                subtitle: Text(textChat[index]["text"]),
              );
            },
          ),
        ),
        Container(
          alignment: Alignment.bottomRight,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: Colors.grey),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: "Type a message ....",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none),
                    fillColor: Colors.transparent,
                  ),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                ),
              ),
              IconButton(
                icon: loading
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.send),
                onPressed: () {
                  fromText(prompt: "Consider yourself an AI doctor. I am a pregnant lady, only answer question related to pregnancy. if the question by me is not related to pregnacy, politely say you don't know the answers for questions which are not related to pregnancy, and request them to ask something related to pregnancy. Make sure you are always polite, patient, gentle and understanding of me. Always speak with care, similar to how you are actually supposed to speak to a pregnant lady. Ask me follow up questions if you need more info about me. Talk to me in a friendly manner. Please don't repeat my question while answering it. Answer my questions in under 45 words. Don't highlight your answers in bold or asterisk. My question is as follows:", query: _textController.text);
                },
              ),
            ],
          ),
        )
      ],
    ));
  }
}