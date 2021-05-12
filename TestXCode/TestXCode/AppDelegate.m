//
//  AppDelegate.m
//  TestXCode
//
//  Created by 应彧刚 on 2021/4/30.
//

#import "AppDelegate.h"
#import "UserNotifications/UserNotifications.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"%s","didFinishLaunchingWithOptions");
    
    /*
    NSDictionary *remoteNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if (remoteNotif) {
        NSData *infoData = [NSJSONSerialization dataWithJSONObject:remoteNotif options:0 error:nil];
        appDel.info = [[NSString alloc] initWithData:infoData encoding:NSUTF8StringEncoding];
        [UIApplication sharedApplication].applicationIconBadgeNumber -= 1;
        NSLog(@"%@",appDel.info);
    }else{
        appDel.info = @"xxxxxx";
    }
    [self registerRemoteNotifications];
     */
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted,NSError * _Nullable error){
        if(!error){
            NSLog(@"OK");
            dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                });
        }
    }];
    
    return YES;
}
/*
 *　DeviceTokenを取得
 */
- (void)application:(UIApplication *)application
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSString* token = [self fetchDeviceToken:deviceToken];
    NSLog(@"%@",token);
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",@"http://192.168.10.100:8080/getDeviceToken?deviceToken=",token]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"ret=%@", ret);
    
}

- (void)application:(UIApplication *)application
        didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo
        fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler {
    NSData *infoData = [NSJSONSerialization dataWithJSONObject:userInfo options:0 error:nil];
    NSString *info = [[NSString alloc] initWithData:infoData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",info);
    // 这里将角标数量减一，注意系统不会帮助我们处理角标数量
    application.applicationIconBadgeNumber = application.applicationIconBadgeNumber - 1;
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    NSLog( @"willPresentNotification" );
    NSLog(@"%@", notification.request.content.userInfo);

    
    NSData *infoData = [NSJSONSerialization dataWithJSONObject:notification.request.content.userInfo options:0 error:nil];
    AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDel.info = [[NSString alloc] initWithData:infoData encoding:NSUTF8StringEncoding];
    //appDel.info = notification.request.content.userInfo.;
    [self.viewController alert];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler
{
    NSLog( @"didReceiveNotificationResponse" );
    // if you set a member variable in didReceiveRemoteNotification, you  will know if this is from closed or background
    NSLog(@"%@", response.notification.request.content.userInfo);
    
    
    NSData *infoData = [NSJSONSerialization dataWithJSONObject:response.notification.request.content.userInfo options:0 error:nil];
    AppDelegate *appDel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDel.info = [[NSString alloc] initWithData:infoData encoding:NSUTF8StringEncoding];
    [self.viewController alert];
}

- (NSString *)fetchDeviceToken:(NSData *)deviceToken {
    NSUInteger len = deviceToken.length;
    if (len == 0) {
        return nil;
    }
    const unsigned char *buffer = deviceToken.bytes;
    NSMutableString *hexString  = [NSMutableString stringWithCapacity:(len * 2)];
    for (int i = 0; i < len; ++i) {
        [hexString appendFormat:@"%02x", buffer[i]];
    }
    return [hexString copy];
}

#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
