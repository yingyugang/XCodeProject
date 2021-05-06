//
//  AppDelegate.h
//  TestXCode
//
//  Created by 应彧刚 on 2021/4/30.
//

#import <UIKit/UIKit.h>
#import "UserNotifications/UserNotifications.h"
#import "ViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,UNUserNotificationCenterDelegate>

@property NSString *info;

@property ViewController *viewController;

@end

