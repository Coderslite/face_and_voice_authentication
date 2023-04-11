import 'package:face_net_authentication/pages/each_app.dart';
import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/user.model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key,})
      : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Text("Welcome " + widget.model),
              Text("Installed Apps"),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: FutureBuilder<List<AppInfo>>(
                  future: InstalledApps.getInstalledApps(true, true),
                  builder: (BuildContext buildContext,
                      AsyncSnapshot<List<AppInfo>> snapshot) {
                    return snapshot.connectionState == ConnectionState.done
                        ? snapshot.hasData
                            ? ListView.builder(
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  AppInfo app = snapshot.data![index];
                                  return EachApp(app: app);
                                },
                              )
                            : Center(
                                child: Text(
                                    "Error occurred while getting installed apps ...."))
                        : Center(child: Text("Getting installed apps ...."));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
