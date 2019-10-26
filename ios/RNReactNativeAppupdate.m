
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
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data && (error == nil)) {
            //NSData -> NSString
            NSError *err;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
            if(!err)
            {
                NSLog(@"json解析：%@",dict);
                dispatch_async(dispatch_get_main_queue(),^{
                    [self  showAlert:controller info:dict];
                });
            }
        }
    }];
    [dataTask resume];
}

-(void)showAlert:(UIViewController *)ctrl info:(NSDictionary *)info
{
    NSInteger currentVersion = [[NSBundle mainBundle].infoDictionary[@"CFBundleVersion"] integerValue];
    NSInteger version_num = [info[@"version_num"] integerValue];
    if (currentVersion < version_num)//线上版本大于本地版本
    {
        NSString *new_version = info[@"new_version"];
        NSString *updateUrl = info[@"apk_file_url"];
        NSString *update_log = info[@"update_log"];
        Boolean constraint = [info[@"constraint"] boolValue];
        //1.创建UIAlertControler
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"是否升级到%@版本?",new_version] message:update_log preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *conform = [UIAlertAction actionWithTitle:@"去升级"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            //跳转到App Store
                                                          //  NSString *urlStr = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/cn/app/id%@?mt=8",APP_ID];
                                                            if(updateUrl){
                                                                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:updateUrl]];
                                                            }
        }];
        [alert addAction:conform];
        if(!constraint){
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消"
                                                             style:UIAlertActionStyleCancel
                                                           handler:^(UIAlertAction * _Nonnull action) {
                                                           }];
            [alert addAction:cancel];
        }
        [ctrl presentViewController:alert animated:YES completion:nil];
    }
}

@end
  
