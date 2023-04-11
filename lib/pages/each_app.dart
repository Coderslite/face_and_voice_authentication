import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EachApp extends StatefulWidget {
  final AppInfo app;
  const EachApp({Key? key, required this.app}) : super(key: key);

  @override
  State<EachApp> createState() => _EachAppState();
}

class _EachAppState extends State<EachApp> {
  bool isLocked = false;

  handleGetLockState() async {
    var prefs = await SharedPreferences.getInstance();
    var isLockedPrefs =
        prefs.getStringList('appsLocked')!.contains(widget.app.packageName)
            ? true
            : false;
    setState(() {
      isLocked = isLockedPrefs;
    });
  }

  @override
  void initState() {
    handleGetLockState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.transparent,
          child: Image.memory(widget.app.icon!),
        ),
        title: Text(widget.app.name!),
        subtitle: Text(widget.app.getVersionInfo()),
        onTap: () => InstalledApps.startApp(widget.app.packageName!),
        onLongPress: () => InstalledApps.openSettings(widget.app.packageName!),
        trailing: Switch(
            value: isLocked,
            onChanged: (val) async {
              var prefs = await SharedPreferences.getInstance();
              setState(() {
                isLocked = !isLocked;
                List<String>? lockedApps = prefs.getStringList('appsLocked');
                List<String> myApps = [];
                if (lockedApps == null) {
                  myApps.add(widget.app.packageName.toString());
                  prefs.setStringList(
                    'appsLocked',
                    myApps,
                  );
                } else {
                  if (lockedApps.contains(widget.app.packageName)) {
                    myApps = lockedApps;
                    myApps.remove(widget.app.packageName.toString());
                    prefs.setStringList(
                      'appsLocked',
                      myApps,
                    );
                  } else {
                    myApps = lockedApps;
                    myApps.add(widget.app.packageName.toString());
                    prefs.setStringList(
                      'appsLocked',
                      myApps,
                    );
                  }
                }
              });
            }),
      ),
    );
  }
}
