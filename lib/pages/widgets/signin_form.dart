import 'package:bot_toast/bot_toast.dart';
import 'package:face_net_authentication/locator.dart';
import 'package:face_net_authentication/pages/home_screen.dart';
import 'package:face_net_authentication/pages/models/user.model.dart';
import 'package:face_net_authentication/pages/profile.dart';
import 'package:face_net_authentication/pages/widgets/app_button.dart';
import 'package:face_net_authentication/pages/widgets/app_text_field.dart';
import 'package:face_net_authentication/services/camera.service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SignInSheet extends StatefulWidget {
  SignInSheet({Key? key, required this.user}) : super(key: key);
  final User user;

  @override
  State<SignInSheet> createState() => _SignInSheetState();
}

class _SignInSheetState extends State<SignInSheet> {
  SpeechToText speechToText = SpeechToText();

  bool isRecording = false;

  String text = '';

  final _passwordController = TextEditingController();

  final _cameraService = locator<CameraService>();

  int retry = 3;

  Future _signIn(context, User user) async {
    if (user.password == _passwordController.text) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  HomeScreen()));
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('Wrong password!'),
          );
        },
      );
    }
  }

  handleSetVoicePassword() async {
    speechToText.listen(
      onResult: (result) {
        setState(() {
          text = result.recognizedWords;
        });
      },
    );
  }

  handleStopRecord(String name, User model) async {
    var prefs = await SharedPreferences.getInstance();
    var voicePass = prefs.getString('voice').toString();
    if (voicePass == text) {
      Get.to(HomeScreen());
    } else {
      setState(() {
        retry--;
        BotToast.showSimpleNotification(
            title: 'Voice Password does not match',
            backgroundColor: Colors.red);
      });
    }

    // BotToast.showSimpleNotification(
    //     title: 'Voice Password changed', backgroundColor: Colors.green);

    speechToText.stop();
  }

  initVoice() async {
    await speechToText.initialize();
  }

  @override
  void initState() {
    initVoice();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Text(
              'Welcome back, ' + widget.user.user + '.',
              style: TextStyle(fontSize: 20),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          retry > 0
              ? Column(
                  children: [
                    SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                          text,
                        )),
                    SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTapDown: (details) {
                        handleSetVoicePassword();
                      },
                      onTapUp: (details) {
                        handleStopRecord(widget.user.user, widget.user);
                      },
                      child: const CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.blue,
                        child: Icon(
                          Icons.mic,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                )
              : Container(
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      AppTextField(
                        controller: _passwordController,
                        labelText: "Password",
                        isPassword: true,
                      ),
                      SizedBox(height: 10),
                      Divider(),
                      SizedBox(height: 10),
                      AppButton(
                        text: 'LOGIN',
                        onPressed: () async {
                          _signIn(context, widget.user);
                        },
                        icon: Icon(
                          Icons.login,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
