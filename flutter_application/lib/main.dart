import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:speech_to_text/speech_to_text.dart';


void main() {
  runApp(
    MaterialApp(
      home: HomePage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
      ),
    ),
  );
}


class HomePage extends StatefulWidget {
  const HomePage({super.key});


  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  bool listening = false;
  String text = '';
  SpeechToText _speechToText = SpeechToText();
  TextEditingController message = TextEditingController();


  List historic = [];


  getPermissionMIC() async {
    await _speechToText.initialize();
  }


  sendMessage(text) async {
    var model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: 'AIzaSyAynkpwhoPUU6e2G8xCn2vQcOQS-cRxxR8');
    var content = [Content.text(text)];
    var response = await model.generateContent(content);
    setState(() {
      historic.add(response.text);
    });
  }


  @override
  void initState() {
    super.initState();
    getPermissionMIC();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat APP'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            Expanded(
              flex: 20,
              child: ListView.builder(
                itemCount: historic.length,
                itemBuilder: (context, index) {
                  return Align(
                    alignment: (index % 2) == 0
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      decoration: BoxDecoration(
                          color: (index % 2) == 0
                              ? Colors.orange[400]
                              : Colors.blueAccent,
                          borderRadius: BorderRadius.circular(12)),
                      child: Text(historic[index]),
                    ),
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: message,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: () {
                            if (!listening) {
                              setState(() {
                                listening = true;
                              });


                              _speechToText.listen(
                                listenFor: Duration(seconds: 15),
                                onResult: (result) {
                                  setState(() {
                                    text = result.recognizedWords;
                                    if (result.finalResult) {
                                      listening = false;
                                      historic.add(text);
                                      sendMessage(text);
                                    }
                                  });
                                },
                              );
                            } else {
                              setState(() {
                                listening = false;
                                _speechToText.stop();
                              });
                            }
                          },
                          icon: listening
                              ? Icon(Icons.record_voice_over)
                              : Icon(Icons.mic),
                          splashRadius: 1,
                          color: listening ? Colors.red : Colors.green,
                        )),
                  ),
                ),
                IconButton(
                  splashRadius: 1,
                    onPressed: () {
                      setState(() {
                        historic.add(message.text);
                      });


                      sendMessage(message.text);
                      message.clear();


                    },
                    icon: Icon(Icons.send))
              ],
            )
          ],
        ),
      ),
    );
  }
}