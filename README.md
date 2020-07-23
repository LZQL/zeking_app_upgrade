# zekingappupgrade



## Getting Started

功能：版本更新

具体功能：

    IOS:   1. app名，包名，版本名称，版本号
           2. 通过 appid 获取 appStroe 上已发布 app 的 版本信息（版本名称，更新说明，下载链接）
           3. 通过 appId 跳转到 appStore
           4. 通过 服务器上的 plist 文件获取企业级 app 的最新版本
           5. 下载 获取公司服务器上企业级app 的ipa

    Android：
            1. app名，包名，版本名称，版本号
            2. 获取保存下载的apk所在的路径
            3. 安装Apk


使用：如果你需要支持Android平台，在`./android/app/src/main/AndroidManifest.xml`文件中配置`provider`，代码如下：

```
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    package="com.zeking.zekingappupgrade_example">
    <application
        android:name="io.flutter.app.FlutterApplication"
        android:icon="@mipmap/ic_launcher"
        android:label="flutter_upgrade_example">
				...
        <provider
            android:name="androidx.core.content.FileProvider"
            android:authorities="com.zeking.zekingappupgrade_example.fileprovider"
            android:exported="false"
            android:grantUriPermissions="true">
            <meta-data
                android:name="android.support.FILE_PROVIDER_PATHS"
                tools:replace="android:resource"
                android:resource="@xml/file_paths" />
        </provider>
    </application>
</manifest>
```

provider中authorities的值为当前App的包名，和顶部的package值保持一致。