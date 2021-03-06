#import "PushNotificationController.h"
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@implementation UnityAppController (PushNotificationController)

typedef void(*CallBack)(const char* p);
CallBack notificationCallBack;
CallBack deviceTokenCallBack;
id thisClass;
char* launchNotification;

void Enroll(CallBack deviceTokenCB,CallBack notificationCB)
{
    deviceTokenCallBack = deviceTokenCB;
    notificationCallBack = notificationCB;
    if(launchNotification != NULL){
        notificationCB(launchNotification);
        launchNotification = NULL;
    }
    [thisClass registerRemoteNotifications];
}

/*
 Called when the category is loaded.  This is where the methods are swizzled
 out.
 */
+ (void)load {
  Method original;
  Method swizzled;

  original = class_getInstanceMethod(
      self, @selector(application:didFinishLaunchingWithOptions:));
  swizzled = class_getInstanceMethod(
      self,
      @selector(WechatSignInAppController:didFinishLaunchingWithOptions:));
  method_exchangeImplementations(original, swizzled);

  original = class_getInstanceMethod(
      self, @selector(application:openURL:sourceApplication:annotation:));
  swizzled = class_getInstanceMethod(
      self, @selector
      (WechatSignInAppController:openURL:sourceApplication:annotation:));
  method_exchangeImplementations(original, swizzled);

  original =
      class_getInstanceMethod(self, @selector(application:openURL:options:));
  swizzled = class_getInstanceMethod(
      self, @selector(WechatSignInAppController:openURL:options:));
  method_exchangeImplementations(original, swizzled);
    
    original =
        class_getInstanceMethod(self, @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:));
    swizzled = class_getInstanceMethod(
        self, @selector(WechatSignInAppController:didRegisterForRemoteNotificationsWithDeviceToken:));
    method_exchangeImplementations(original, swizzled);
   
    
    original =
        class_getInstanceMethod(self, @selector(application:didFailToRegisterForRemoteNotificationsWithError:));
    swizzled = class_getInstanceMethod(
        self, @selector(WechatSignInAppController:didRegisterForRemoteNotificationsWithDeviceToken:));
    method_exchangeImplementations(original, swizzled);
}

- (BOOL)WechatSignInAppController:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"????????????????????????");
    thisClass = self;
    NSDictionary *remoteNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
	if (remoteNotif) {
    	NSData *infoData = [NSJSONSerialization dataWithJSONObject:remoteNotif options:0 error:nil];
    	NSString *info = [[NSString alloc] initWithData:infoData encoding:NSUTF8StringEncoding];
    	[UIApplication sharedApplication].applicationIconBadgeNumber -= 1;
        launchNotification = [info UTF8String];
        //notificationCallBack([info UTF8String]);
	}
    return  [self WechatSignInAppController:application
            didFinishLaunchingWithOptions:launchOptions];
}

/**
 * Handle the auth URL
 */
- (BOOL)WechatSignInAppController:(UIApplication *)application
                          openURL:(NSURL *)url
                sourceApplication:(NSString *)sourceApplication
                       annotation:(id)annotation {
    BOOL handled = [self WechatSignInAppController:application
                                           openURL:url
                                 sourceApplication:sourceApplication
                                        annotation:annotation];
  return handled;
}

/**
 * Handle the auth URL.
 */
- (BOOL)WechatSignInAppController:(UIApplication *)app
                          openURL:(NSURL *)url
                          options:(NSDictionary *)options {
    BOOL handled =
        [self WechatSignInAppController:app openURL:url options:options];
    return handled;
}

- (void)application:(UIApplication *)application
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSString* str = [self fetchDeviceToken:deviceToken];
    NSLog(@"%@",str);
       deviceTokenCallBack([str UTF8String]);
       [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)application:(UIApplication *)app
        didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    // The token is not currently available.
    NSLog(@"Remote notification support is unavailable due to error: %@", err);  
}

- (void)application:(UIApplication *)application 
        didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo 
        fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler {
   
    NSData *infoData = [NSJSONSerialization dataWithJSONObject:userInfo options:0 error:nil];
    NSString *info = [[NSString alloc] initWithData:infoData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",info);
    if(notificationCallBack==NULL){
        //launchNotification = [info UTF8String];
    }else{
        notificationCallBack([info UTF8String]);
    }
    // ??????????????????????????????????????????????????????????????????????????????
    application.applicationIconBadgeNumber = application.applicationIconBadgeNumber - 1;
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

- (void)registerRemoteNotifications {
    // ??????????????? iOS8 or later
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerForRemoteNotifications)]) {
        // ?????? types ???????????????????????? types ??? 0???????????????????????????????????????????????????????????????????????????????????????(?????????App ?????????????????????????????????)
        UIUserNotificationType types = (UIUserNotificationType) (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert);
        // ?????? categories ????????????????????????????????????????????????
        UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        // ???????????????????????????????????????????????????????????????????????????????????????????????????
        [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    } else {
        UIRemoteNotificationType types = UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
    }
}
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(nonnull UIUserNotificationSettings *)notificationSettings {
    // Register for remote notifications.
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}
@end
