import 'package:bot_toast/bot_toast.dart';
import 'package:face_net_authentication/pages/widgets/app_button.dart';
import 'package:face_net_authentication/pages/widgets/app_text_field.dart';
import 'package:flutter/material.dart';

import '../../locator.dart';
import '../../services/ml_service.dart';
import '../db/databse_helper.dart';
import '../home_screen.dart';
import '../models/user.model.dart';

class SignInAlt extends StatefulWidget {
  const SignInAlt({Key? key}) : super(key: key);

  @override
  State<SignInAlt> createState() => _SignInAltState();
}

class _SignInAltState extends State<SignInAlt> {
  var _userTextEditingController = TextEditingController();
  var _passwordTextEditingController = TextEditingController();
  final MLService _mlService = locator<MLService>();

  Future _signIn(context) async {
    List predictedData = _mlService.predictedData;
    String user = _userTextEditingController.text;
    String password = _passwordTextEditingController.text;
    User userToSave = User(
      user: user,
      password: password,
      modelData: predictedData,
    );
    List<User> users = await DatabaseHelper.queryAllUsers();
    var loginUser = users
        .where((element) =>
            element.user == _userTextEditingController.text &&
            element.password == _passwordTextEditingController.text)
        .toList();
    if (loginUser.isEmpty) {
      BotToast.showSimpleNotification(
          title: 'Voice Password does not match', backgroundColor: Colors.red);
    } else {
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) => HomeScreen()));
    }
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
                  "Face Attempt failed",
                  style: TextStyle(fontSize: 17, color: Colors.red),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "Sign In with Username and Password",
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
                    await _signIn(context);
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
