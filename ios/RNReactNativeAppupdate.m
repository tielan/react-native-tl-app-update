
#import "RNReactNativeAppupdate.h"
#import <React/RCTLog.h>
#import <React/RCTConvert.h>
@interface RNReactNativeAppupdate()

@end

@implementation RNReactNativeAppupdate

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(check:(NSDictionary *) info)
{
    NSString *urlStr = [RCTConvert NSString:info[@"url"]];
    RCTLogInfo(@"%@", urlStr);
    UIViewController *controller = RCTPresentedViewController();
    if (controller == nil) {
        RCTLogError(@"Tried to display action update but there is no application window. optio");
        return;
    }
    [self checkAndDownload:controller url:urlStr manual:false callback:nil];
}
RCT_EXPORT_METHOD(manual:(NSDictionary *) info callback:(RCTResponseSenderBlock) callback)
{
    NSString *urlStr = [RCTConvert NSString:info[@"url"]];
    RCTLogInfo(@"%@", urlStr);
    UIViewController *controller = RCTPresentedViewController();
    if (controller == nil) {
        RCTLogError(@"Tried to display action update but there is no application window. optio");
        return;
    }
    [self checkAndDownload:controller url:urlStr manual:YES callback:callback];
}

-(void)checkAndDownload:(UIViewController *)ctrl url:(NSString *)url manual:(Boolean) manual callback:(RCTResponseSenderBlock) callback{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data && (error == nil)) {
            NSError *err;
            NSDictionary *info = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
            if(!err)
            {
                NSLog(@"json解析：%@",info);
                NSInteger currentVersion = [[NSBundle mainBundle].infoDictionary[@"CFBundleVersion"] integerValue];
                NSInteger version_num = [info[@"version_num"] integerValue];
                NSString *new_version = info[@"new_version"];
                if (currentVersion < version_num)//线上版本大于本地版本
                {
                    if(!manual && [new_version isEqualToString:[self loadCheckVersion]]){//如果是自动检测 并且 忽略了的版本一直 则 取消当前提示g框
                        return;
                    }
                    dispatch_async(dispatch_get_main_queue(),^{
                        [self  showUpdateAlert:ctrl info:info];
                    });
                }else{
                    if(manual){
                        callback(@[@"0",@"当前已经是最新版本!"]);
                    }
                }
            }else{
                if(manual){
                    callback(@[@"0",@"连接服务器失败!"]);
                }
            }
        }
    }];
    [dataTask resume];
}

-(void)showUpdateAlert:(UIViewController *)ctrl info:(NSDictionary *)info
{
    NSString *new_version = info[@"new_version"];
    NSString *updateUrl = info[@"apk_file_url"];
    NSString *update_log = info[@"update_log"];
    Boolean constraint = [info[@"constraint"] boolValue];
    NSString *title = [NSString stringWithFormat:@"是否升级到%@版本?",new_version];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:update_log
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *conform = [UIAlertAction actionWithTitle:@"去升级"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        //跳转到App Store
                                                        //  NSString *urlStr = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/cn/app/id%@?mt=8",APP_ID];
                                                        if(updateUrl){
                                                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:updateUrl]];
                                                        }
                                                        if(constraint){
                                                            [self  showUpdateAlert:ctrl info:info];
                                                        }
                                                        
                                                    }];
    [alert addAction:conform];
    if(!constraint){
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消"
                                                         style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                        //   [self saveCheckVersion:new_version];
                                                       }];
        [alert addAction:cancel];
    }
    [ctrl presentViewController:alert animated:YES completion:nil];
}

-(void)showMsg:(UIViewController *)ctrl msg:(NSString *)msg
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了"
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    [ctrl presentViewController:alert animated:YES completion:nil];
}

-(void)saveCheckVersion:(NSString *)version
{
    NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
    [userData setObject:version forKey:@"CheckVersion"];
    [userData synchronize];
}
-(NSString *)loadCheckVersion
{
    NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
    return [userData objectForKey:@"CheckVersion"];
}
@end

