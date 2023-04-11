import 'package:bot_toast/bot_toast.dart';
import 'package:face_net_authentication/locator.dart';
import 'package:face_net_authentication/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupServices();
  bool isAppLocked = false;
  List<String> myAppLocked = [];
  var prefs = await SharedPreferences.getInstance();
  print(prefs.getStringList('appsLocked').toString());
  if (prefs.getStringList('appsLocked').toString() != 'null') {
    myAppLocked = prefs.getStringList('appsLocked')!.toList();
    bool appLocked = myAppLocked.contains("com.example.FaceNet");
    isAppLocked = appLocked;
  } else {
    print("empty");
  }
  runApp(MyApp(
    appsLocked: myAppLocked.toString(),
    isAppLocked: isAppLocked,
  ));
}

class MyApp extends StatefulWidget {
  final String appsLocked;
  final bool isAppLocked;
  const MyApp({
    Key? key,
    required this.appsLocked,
    required this.isAppLocked,
  }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      builder: BotToastInit(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: widget.appsLocked == 'null'
          ? MyHomePage(
              registered: false,
              isAppLocked: widget.isAppLocked,
            )
          : widget.appsLocked == '[]'
              ? MyHomePage(
                  registered: false,
                  isAppLocked: widget.isAppLocked,
                )
              : MyHomePage(
                  registered: true,
                  isAppLocked: widget.isAppLocked,
                ),
    );
  }
}
