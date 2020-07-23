import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:zekingappupgrade/zekingappupgrade.dart';

/// 弹出 版本更新 dialog
void showVersionUpdateDialog(
  BuildContext context,
  bool forced,
  String androidDownUrl,
  String iosDownUrl,
    String versionName,
    String updateContent
) {
  showGeneralDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.5),
    barrierLabel: "",
    barrierDismissible: false,
    transitionDuration: const Duration(milliseconds: 100),
    pageBuilder: (
      BuildContext context,
      Animation animation,
      Animation secondaryAnimation,
    ) {
      return VersionUpdateWidget(
        forced,
        androidDownUrl,
        iosDownUrl,
        versionName,
        updateContent,
      );
    },
    transitionBuilder: (ctx, animation, _, child) {
      return FractionalTranslation(
        translation: Offset(0.0, 0.0),
        child: child,
      );
    },
  );
}

class VersionUpdateWidget extends StatefulWidget {
  final bool forced; // 是否强制升级
  final String androidDownUrl; // Android 下载路径
  final String iosDownUrl; // IOS plist文件路径
  final String versionName;
  final String updateContent;

  const VersionUpdateWidget(this.forced, this.androidDownUrl, this.iosDownUrl,
      this.versionName, this.updateContent);

  @override
  _VersionUpdateWidgetState createState() => _VersionUpdateWidgetState();
}

class _VersionUpdateWidgetState extends State<VersionUpdateWidget> {
  double downloadProgress = 0;

  bool showProgressWidget = false;

  static final String _downloadApkName = 'temp.apk';

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Material(
              type: MaterialType.transparency,
              child: Container(
                width: size.width - 65,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                constraints: BoxConstraints(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 20),
                            child: Center(
                                child: Text(
                              '发现新版本',
                              style: TextStyle(fontSize: 30),
                            ))),
                        Positioned(
                          right: 0,
                          child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: EdgeInsets.all(15),
                                child: Text('x'),
                              )),
                        )
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          top: 7, bottom: 30, left: 30, right: 30),

                      /// 更新的内容说明
                      child: Text(
//                      '',
                        '${widget.versionName}\n${widget.updateContent}',
                        style:
                            TextStyle(fontSize: 14, color: Color(0xff333333)),
                        strutStyle: StrutStyle(
                          forceStrutHeight: true,
                          height: 1.5,
                        ),
                      ),
                    ),
                    showProgressWidget
                        ? Container(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  width: double.infinity,
                                  padding:
                                      EdgeInsets.only(right: 26, bottom: 3),
                                  child: Text(
                                    '${(downloadProgress*100).toInt()}%',
                                    style: TextStyle(
                                        color: Color(0xff3494F7), fontSize: 11),
                                    textAlign: TextAlign.right,
                                  ),
                                ),

                                /// 进度条
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 27, right: 27, bottom: 26),
                                  child: LinearPercentIndicator(
                                    lineHeight: 10,
                                    percent: downloadProgress,
                                    backgroundColor: Color(0xffE6E6E6),
                                    progressColor: Color(0xff3494F7),
                                  ),
                                ),

                                /// 新版本正在更新中，请稍等
                                Padding(
                                    padding: EdgeInsets.only(bottom: 50),
                                    child: Center(
                                      child: Text(
                                        '新版本正在更新中，请稍等',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Color(0xff999999)),
                                        textAlign: TextAlign.center,
                                      ),
                                    ))
                              ],
                            ),
                          )
                        :

                        /// 立即更新
                        Padding(
                            padding: EdgeInsets.only(
                                left: 85, right: 85, bottom: 25),
                            child: RaisedButton(
                                onPressed: clickUpdate,
                                child: Container(
                                    alignment: Alignment.center,
                                    width: double.infinity,
                                    child: Text('立即更新'))
//                        text: IntlUtil.getString(context, Ids.login),
                                ),
                          ),
                  ],
                ),
              ),
            )
          ],
        ));
  }

  // 点击了 立即更新 按钮
  void clickUpdate() async {
    setState(() {
      showProgressWidget = true;
    });

    if (Platform.isIOS) {
      return;
    }

    String path = await ZekingAppUpgrade.androidDownloadPath;
    print(path);
    _downloadApk(widget.androidDownUrl, '$path/$_downloadApkName');
  }

  ///
  /// 下载apk包
  ///
  _downloadApk(String url, String path) async {
//    if (_downloadStatus == DownloadStatus.start ||
//        _downloadStatus == DownloadStatus.downloading ||
//        _downloadStatus == DownloadStatus.done) {
//      print('当前下载状态：$_downloadStatus,不能重复下载。');
//      return;
//    }
//
//    _updateDownloadStatus(DownloadStatus.start);
    try {
      var dio = Dio();
      await dio.download(url, path, onReceiveProgress: (int count, int total) {
//        if (total == -1) {
//          downloadProgress = 0.01;
//        } else {
        downloadProgress = count / total.toDouble();
//        }
        setState(() {});
        if (downloadProgress == 1) {
          //下载完成，跳转到程序安装界面
//          _updateDownloadStatus(DownloadStatus.done);
//          Navigator.pop(context);
//          FlutterUpgrade.installAppForAndroid(path);
//          print('下载完成');
          Navigator.pop(context);
          ZekingAppUpgrade.installAppForAndroid(path);
        }
      });
    } catch (e) {
      print('$e');
      downloadProgress = 0;
//      _updateDownloadStatus(DownloadStatus.error,error: e);
    }
  }
}
