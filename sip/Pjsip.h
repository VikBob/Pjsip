//
//  Pjsip.h
//  sip
//
//  Created by QF  on 15/4/13.
//  Copyright (c) 2015年 BZW. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <pjsua-lib/pjsua.h>
#define THIS_FILE "APP"
#define current_acc	pjsua_acc_get_default()



@interface Pjsip : NSObject

@property (nonatomic,strong)NSArray *callid;
+ (Pjsip *)sharedXCPjsua;
- (int) registerToServer:(NSString *)domian username:(NSString *)username passwd:(NSString *)passwd;
- (void) callHangup;
- (void) unregister;
-(void)answer:(int)callId;
- (void) makeCall:(NSString *)callname domain:(NSString *)domian;


@end
