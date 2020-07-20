import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:zekingappupgrade/zekingappupgrade.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  String appName;
  String packageName;
  String version;
  String buildNumber;

  String newVersionName;

  String appStoreInfo;

  @override
  void initState() {
    super.initState();
    getPackageInfo();
  }




  Future<void> getPackageInfo() async {
    ZekingPackageInfo zekingPackageInfo;
    try {
       zekingPackageInfo = await Zekingappupgrade.getPackageInfo;
    } on PlatformException {

    }

    if (!mounted) return;

    setState(() {
      appName = zekingPackageInfo.appName;
      packageName = zekingPackageInfo.packageName;
      version = zekingPackageInfo.version;
      buildNumber = zekingPackageInfo.buildNumber;
    });
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: <Widget>[
            Text('appName: $appName\n'),
            Text('packageName: $packageName\n'),
            Text('version: $version\n'),
            Text('buildNumber: $buildNumber\n'),
            RaisedButton(
              onPressed: (){
//                Zekingappupgrade.toAppStore('id1197227551');
//                Zekingappupgrade.toAppStore('id629774477');
                Zekingappupgrade.iosToAppStore('id393765873');
              },
              child: Text('跳转到AppStroe'),
            ),
            RaisedButton(
              onPressed: (){
                Zekingappupgrade.iosDownloadEnterpriseIpa('https://it-home.vip/test/manifest.plist');
//                Zekingappupgrade.downloadIpa('itms-services://?action=download-manifest&url=https://it-home.vip/test/manifest.plist');
              },
              child: Text('下载企业级app'),
            ),
            RaisedButton(
              onPressed: getNewVersionName,
              child: Text('获取最新的版本名称'),
            ),
            Text('新版本名称: $newVersionName\n'),
            RaisedButton(
              onPressed: getAppStorePackageInfo,
              child: Text('通过appid获取appStroe上app的版本'),
            ),
            Text('AppStore上的应用信息: \n$appStoreInfo'),
          ],
        ),
      ),
    );
  }

  void getNewVersionName() async{
    newVersionName = await Zekingappupgrade.iosGestNewVersion('https://it-home.vip/test/manifest.plist');
    setState(() {
    });
  }

  void getAppStorePackageInfo() async{
    ZekingAppStorePackageInfo info = await Zekingappupgrade.iosGetAppStorePackageInfo('393765873',isChina: true);
    setState(() {
      appStoreInfo = info.lineVersion + '\n' + info.releaseNotes + '\n' + info.trackViewUrl;
    });

  }
}
