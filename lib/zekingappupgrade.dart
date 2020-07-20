import 'dart:async';

import 'package:flutter/services.dart';
import 'package:zekingappupgrade/zeking_app_store_package_info.dart';
import 'package:zekingappupgrade/zeking_package_info.dart';
export 'package:zekingappupgrade/zeking_package_info.dart';
export 'zeking_app_store_package_info.dart';

class Zekingappupgrade {
  static const MethodChannel _channel = const MethodChannel('zekingappupgrade');

  // 获取 应用名，包名，版本名称，版本号
  static Future<ZekingPackageInfo> get getPackageInfo async {
    final Map<String, dynamic> map =
        await _channel.invokeMapMethod<String, dynamic>('getPackageInfo');

    ZekingPackageInfo zekingPackageInfo = ZekingPackageInfo(
        map["appName"], map["packageName"], map['version'], map['buildNumber']);
    return zekingPackageInfo;
  }

  /// ======================== IOS ========================

  // IOS 通过appid获取appStroe上app的版本
  static Future<ZekingAppStorePackageInfo> iosGetAppStorePackageInfo(String appId,{bool isChina = true}) async {

    Map<String, dynamic> params = {
      "appId": appId,
      "isChina": isChina,
    };

    final Map<String, dynamic> map =
      await _channel.invokeMapMethod<String, dynamic>('iosGetAppStorePackageInfo',params);

    ZekingAppStorePackageInfo info = ZekingAppStorePackageInfo(
        map["lineVersion"], map["releaseNotes"], map['trackViewUrl']);
    return info;
  }

  // IOS 跳转到 AppStore
  static Future<void> iosToAppStore(String appId) async {
    Map<String, String> params = {
      "appId": appId,
    };

    await _channel.invokeMethod('iosToAppStore', params);
  }

  // IOS 下载企业级 ipa
  static Future<void> iosDownloadEnterpriseIpa(String path) async {
    Map<String, String> params = {
      "path": path,
    };

    await _channel.invokeMethod('iosDownloadEnterpriseIpa', params);
  }

  // IOS 获取 企业plist 文件的 版本信息
  static Future<String> iosGestNewVersion(String path) async {
    Map<String, String> params = {
      "path": path,
    };

    String newVersion = await _channel.invokeMethod('iosGestNewVersion', params);
    return newVersion;
  }

  /// ======================== Android ========================


}
