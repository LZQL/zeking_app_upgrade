#import "ZekingappupgradePlugin.h"

@implementation ZekingAppUpgradePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"zekingappupgrade"
            binaryMessenger:[registrar messenger]];
  ZekingAppUpgradePlugin* instance = [[ZekingAppUpgradePlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([call.method isEqualToString:@"getPackageInfo"]) {
    result(@{
      @"appName" : [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]
          ?: [NSNull null],
      @"packageName" : [[NSBundle mainBundle] bundleIdentifier] ?: [NSNull null],
      @"version" : [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
          ?: [NSNull null],
      @"buildNumber" : [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]
          ?: [NSNull null],
    });
  } else if ([call.method isEqualToString:@"iosGetAppStorePackageInfo"]) { // 通过appid获取appStroe上app的版本
      
      NSString* appId = [call arguments][@"appId"];
      NSNumber *isChina = [call arguments][@"isChina"];
      
      
      // 获取appStore版本号
      NSString *strurl;
      if( [isChina boolValue] == YES){
          strurl = [@"https://itunes.apple.com/cn/lookup?id=" stringByAppendingString:appId];
      }else{
          strurl = [@"https://itunes.apple.com/lookup?id=" stringByAppendingString:appId];
      }
      
      NSURLSession *session=[NSURLSession sharedSession];
      NSURL *url = [NSURL URLWithString:strurl];

      //3.创建可变的请求对象
      NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
      NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
          //8.解析数据
          NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
          NSArray * results = dict[@"results"];
          NSDictionary * dic = results.firstObject;
          NSString * lineVersion = dic[@"version"];//版本号
          NSString * releaseNotes = dic[@"releaseNotes"];//更新说明
          NSString * trackViewUrl = dic[@"trackViewUrl"];//链接
//          NSLog(@"App store版本号:%@",lineVersion);
//          NSLog(@"更新说明:%@",releaseNotes);
//          NSLog(@"App下载链接:%@",trackViewUrl);
          
          result(@{
            @"lineVersion" :lineVersion,
            @"releaseNotes" : releaseNotes,
            @"trackViewUrl" : trackViewUrl
          });

      }];
      //7.执行任务
      [dataTask resume];
      
  } else if ([call.method isEqualToString:@"iosToAppStore"]) { // 通过appId跳转到appStore
      
      NSString* appId = [call arguments][@"appId"];

      NSString *str = [@"itms-apps://itunes.apple.com/app/" stringByAppendingString:appId];
      
      NSURL *url= [NSURL URLWithString:str];
      
      [[UIApplication sharedApplication] openURL:url];
      
  } else if ([call.method isEqualToString:@"iosDownloadEnterpriseIpa"]) {    // 下载 获取企业级app 的ipa
      
      NSString* path = [call arguments][@"path"];  // path：自己公司服务器上的plist地址
      
      NSString *url = [@"itms-services://?action=download-manifest&url=" stringByAppendingString:path];
      
      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];

  } else if ([call.method isEqualToString:@"iosGestNewVersion"]) {  // 通过plist文件获取企业级app的最新版本
      
      NSString* path = [call arguments][@"path"]; // path：自己公司服务器上的plist地址
      
      NSDictionary* dict = [NSDictionary dictionaryWithContentsOfURL:[NSURL URLWithString:path]];
      
      NSString* newVersion = [[[[dict objectForKey:@"items"] objectAtIndex:0] objectForKey:@"metadata"] objectForKey:@"bundle-version"];

      result(newVersion);
      
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
