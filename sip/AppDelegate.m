//
//  AppDelegate.m
//  sip
//
//  Created by QF  on 15/4/13.
//  Copyright (c) 2015年 BZW. All rights reserved.
//

#import "AppDelegate.h"
#import "Pjsip.h"
#import <pjlib.h>
#import <pjsua.h>
#import <pj/log.h>
#import "ViewController.h"


@interface AppDelegate ()


@end

@implementation AppDelegate




//static pj_thread_desc   a_thread_desc;
//static pj_thread_t     *a_thread;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    /* Send keep alive manually at the beginning of background */
    //pjsip_endpt_send_raw*(...);
    /* iOS requires that the minimum keep alive interval is 600s */
    [self performSelectorOnMainThread:@selector(keepAlive) withObject:nil waitUntilDone:YES];
    [application setKeepAliveTimeout:600 handler: ^{
        [self performSelectorOnMainThread:@selector(keepAlive) withObject:nil waitUntilDone:YES];
    }];
    
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    //取消角标
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (void)keepAlive
{
//    int i;
//    //检查当前线程是否注册到pjlib
//    if (!pj_thread_is_registered())
//    {
//        pj_thread_register("ipjsua", a_thread_desc, &a_thread);
//    }
//    
//    /* Since iOS requires that the minimum keep alive interval is 600s,
//     * application needs to make sure that the account's registration
//     * timeout is long enough.
//     */
//    
//    for (i = 0; i < (int)pjsua_acc_get_count(); ++i)
//    {
//        if (pjsua_acc_is_valid(i))
//        {
//            pjsua_acc_set_registration(i, PJ_TRUE);
//        }
//    }
    /**
     */
    /* Register this thread if not yet */
    if (!pj_thread_is_registered()) {
        static pj_thread_desc   thread_desc;
        static pj_thread_t     *thread;
        pj_thread_register("mainthread", thread_desc, &thread);
    }
    
    /* Simply sleep for 5s, give the time for library to send transport
     * keepalive packet, and wait for server response if any. Don't sleep
     * too short, to avoid too many wakeups, because when there is any
     * response from server, app will be woken up again (see also #1482).
     */
    pj_thread_sleep(5000);
    
}


@end
