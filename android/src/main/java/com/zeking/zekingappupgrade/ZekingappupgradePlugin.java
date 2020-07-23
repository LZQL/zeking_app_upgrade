package com.zeking.zekingappupgrade;

import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;

import androidx.annotation.NonNull;
import androidx.core.content.FileProvider;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * ZekingappupgradePlugin
 */
public class ZekingappupgradePlugin implements FlutterPlugin, MethodCallHandler {

    private Context applicationContext;
    private MethodChannel channel;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        onAttachedToEngine(flutterPluginBinding.getApplicationContext(), flutterPluginBinding.getBinaryMessenger());
    }

    public static void registerWith(Registrar registrar) {

        final ZekingappupgradePlugin instance = new ZekingappupgradePlugin();
        instance.onAttachedToEngine(registrar.context(), registrar.messenger());
    }

    private void onAttachedToEngine(Context applicationContext, BinaryMessenger messenger) {
        this.applicationContext = applicationContext;
        channel = new MethodChannel(messenger, "zekingappupgrade");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {

        if (call.method.equals("getPackageInfo")) { // 获取 应用信息
            try {
                PackageManager pm = applicationContext.getPackageManager();
                PackageInfo info = pm.getPackageInfo(applicationContext.getPackageName(), 0);

                Map<String, String> map = new HashMap<>();
                map.put("appName", info.applicationInfo.loadLabel(pm).toString());
                map.put("packageName", applicationContext.getPackageName());
                map.put("version", info.versionName);
                map.put("buildNumber", String.valueOf(getLongVersionCode(info)));

                result.success(map);

            } catch (PackageManager.NameNotFoundException ex) {
                result.error("Name not found", ex.getMessage(), null);
            }
        } else if (call.method.equals("getApkDownloadPath")) {
            result.success(applicationContext.getExternalFilesDir("").getAbsolutePath());
        } else if (call.method.equals("install")){      //  安装apk

            String path = call.argument("path");
            startInstall(applicationContext,path);

        } else {
            result.notImplemented();
        }

    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        applicationContext = null;
        channel.setMethodCallHandler(null);
        channel = null;
    }


    @SuppressWarnings("deprecation")
    private static long getLongVersionCode(PackageInfo info) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            return info.getLongVersionCode();
        }
        return info.versionCode;
    }

    // 安装apk
    private void startInstall( Context context,  String path) {
        File file = new  File(path);
        if (!file.exists()) {
            return;
        }

        Intent intent = new Intent(Intent.ACTION_VIEW);
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            //7.0及以上
            Uri contentUri = FileProvider.getUriForFile(context, context.getPackageName()+".fileprovider", file);
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK) ;
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            intent.setDataAndType(contentUri, "application/vnd.android.package-archive");
        } else {
            //7.0以下
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            Uri uri = Uri.fromFile(file);
            intent.setDataAndType(uri, "application/vnd.android.package-archive");
        }
        context.startActivity(intent);
    }

}
