import 'package:bot_toast/bot_toast.dart';
import 'package:face_net_authentication/locator.dart';
import 'package:face_net_authentication/pages/db/databse_helper.dart';
import 'package:face_net_authentication/pages/home_screen.dart';
import 'package:face_net_authentication/pages/models/user.model.dart';
import 'package:face_net_authentication/pages/profile.dart';
import 'package:face_net_authentication/pages/widgets/app_button.dart';
import 'package:face_net_authentication/services/camera.service.dart';
import 'package:face_net_authentication/services/ml_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../home.dart';
import 'app_text_field.dart';

class AuthActionButton extends StatefulWidget {
  AuthActionButton(
      {Key? key,
      required this.onPressed,
      required this.isLogin,
      required this.reload});
  final Function onPressed;
  final bool isLogin;
  final Function reload;
  @override
  _AuthActionButtonState createState() => _AuthActionButtonState();
}

class _AuthActionButtonState extends State<AuthActionButton> {
  SpeechToText speechToText = SpeechToText();

  bool isRecording = false;
  bool voiceValidated = false;

  String text = '';
  final MLService _mlService = locator<MLService>();
  final CameraService _cameraService = locator<CameraService>();

  final TextEditingController _userTextEditingController =
      TextEditingController(text: '');
  final TextEditingController _passwordTextEditingController =
      TextEditingController(text: '');

  User? predictedUser;
  int retry = 3;

  Future _signUp(context) async {
    DatabaseHelper _databaseHelper = DatabaseHelper.instance;
    List predictedData = _mlService.predictedData;
    String user = _userTextEditingController.text;
    String password = _passwordTextEditingController.text;
    User userToSave = User(
      user: user,
      password: password,
      modelData: predictedData,
    );
    await _databaseHelper.insert(userToSave);
    this._mlService.setPredictedData([]);
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => HomeScreen()));
  }

  Future _signIn(context) async {
    String password = _passwordTextEditingController.text;
    if (this.predictedUser!.password == password) {
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) => HomeScreen()));
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

  Future<User?> _predictUser() async {
    User? userAndPass = await _mlService.predict();
    return userAndPass;
  }

  Future onTap() async {
    try {
      bool faceDetected = await widget.onPressed();
      if (faceDetected) {
        if (widget.isLogin) {
          var user = await _predictUser();
          if (user != null) {
            setState(() {
              predictedUser = user;
            });
          }
        }
        PersistentBottomSheetController bottomSheetController =
            Scaffold.of(context).showBottomSheet((context) => signSheet(
                  context,
                ));
        bottomSheetController.closed.whenComplete(() => widget.reload());
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.blue[200],
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 1,
              offset: Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        width: MediaQuery.of(context).size.width * 0.8,
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'CAPTURE',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(
              width: 10,
            ),
            Icon(Icons.camera_alt, color: Colors.white)
          ],
        ),
      ),
    );
  }

  signSheet(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          widget.isLogin && predictedUser != null
              ? Container(
                  child: Text(
                    'Welcome back, ' + predictedUser!.user + '.',
                    style: TextStyle(fontSize: 20),
                  ),
                )
              : widget.isLogin
                  ? Container(
                      child: Text(
                      'User not found 😞',
                      style: TextStyle(fontSize: 20),
                    ))
                  : Container(),
          Container(
            child: voiceValidated
                ? Column(
                    children: [
                      !widget.isLogin
                          ? AppTextField(
                              controller: _userTextEditingController,
                              labelText: "Your Name",
                            )
                          : Container(),
                      SizedBox(height: 10),
                      widget.isLogin && predictedUser == null
                          ? Container()
                          : AppTextField(
                              controller: _passwordTextEditingController,
                              labelText: "Password",
                              isPassword: true,
                            ),
                      SizedBox(height: 10),
                      Divider(),
                      SizedBox(height: 10),
                      widget.isLogin && predictedUser != null
                          ? AppButton(
                              text: 'LOGIN',
                              onPressed: () async {
                                _signIn(context);
                              },
                              icon: Icon(
                                Icons.login,
                                color: Colors.white,
                              ),
                            )
                          : !widget.isLogin
                              ? AppButton(
                                  text: 'SIGN UP',
                                  onPressed: () async {
                                    await _signUp(context);
                                  },
                                  icon: Icon(
                                    Icons.person_add,
                                    color: Colors.white,
                                  ),
                                )
                              : Container(),
                    ],
                  )
                : InkWell(
                    onTapDown: (details) {
                      handleSetVoicePassword();
                    },
                    onTapUp: (details) {
                      handleStopRecord();
                    },
                    child: Column(
                      children: [
                        SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Text(
                              text,
                            )),
                        SizedBox(
                          height: 10,
                        ),
                        const CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.blue,
                          child: Icon(
                            Icons.mic,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
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

  handleStopRecord() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString('voice', text);
    print(text);
    BotToast.showSimpleNotification(
        title: 'Voice Password changed', backgroundColor: Colors.green);
    speechToText.stop();
    Get.to(SetPasswordScreen());
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
  void dispose() {
    super.dispose();
  }
}

class SetPasswordScreen extends StatefulWidget {
  const SetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  var _userTextEditingController = TextEditingController();
  var _passwordTextEditingController = TextEditingController();
  final MLService _mlService = locator<MLService>();

  Future _signUp(context) async {
    DatabaseHelper _databaseHelper = DatabaseHelper.instance;
    List predictedData = _mlService.predictedData;
    String user = _userTextEditingController.text;
    String password = _passwordTextEditingController.text;
    User userToSave = User(
      user: user,
      password: password,
      modelData: predictedData,
    );
    await _databaseHelper.insert(userToSave);
    this._mlService.setPredictedData([]);
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Create Password",
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "This is an alternative incase the authentications fails",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(
                  height: 30,
                ),
                AppTextField(
                  controller: _userTextEditingController,
                  labelText: "Your Name",
                ),
                SizedBox(height: 10),
                AppTextField(
                  controller: _passwordTextEditingController,
                  labelText: "Password",
                  isPassword: true,
                ),
                SizedBox(height: 10),
                Divider(),
                SizedBox(height: 10),
                AppButton(
                  text: 'SIGN UP',
                  onPressed: () async {
                    await _signUp(context);
                  },
                  icon: Icon(
                    Icons.person_add,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
