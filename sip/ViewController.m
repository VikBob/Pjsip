//
//  ViewController.m
//  sip
//
//  Created by QF  on 15/4/13.
//  Copyright (c) 2015年 BZW. All rights reserved.
//

#import "ViewController.h"
#import "MZTimerLabel.h"
#import <AudioToolbox/AudioToolbox.h>
@interface ViewController ()<UIAlertViewDelegate,MZTimerLabelDelegate>
{
    int phoneId ;//来电话时  传过来的账号id
    UIAlertView *phoneAlertView;//来电的push页面
    MZTimerLabel *timelabel;//通话时长label
    int locationRed; //通知的数量
}
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *passwd;
@property (weak, nonatomic) IBOutlet UITextField *domain;
@property (weak, nonatomic) IBOutlet UITextField *callWho;
@property (weak, nonatomic) IBOutlet UILabel *loginText;//登陆状态
@property (weak, nonatomic) IBOutlet UILabel *phoneTimeLabel;//通话时长label

@end

@implementation ViewController
//点击屏幕缩键盘
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.userName resignFirstResponder];
    [self.passwd resignFirstResponder];
    [self.domain resignFirstResponder];
    [self.callWho resignFirstResponder];
}
//Pjsip *sip;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    sip = [[Pjsip alloc]init];
    locationRed = 0;
    //接收通知
    NSNotificationCenter *center =[NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(log:) name:@"reloadMessag" object:nil];
   
    //接听挂断的通知
   // NSNotificationCenter *centerHanguP =[NSNotificationCenter defaultCenter];
   // [centerHanguP addObserver:self selector:@selector(LookHangUp) name:@"whoHangUp" object:nil];
    
    timelabel  =[[MZTimerLabel alloc] initWithLabel:self.phoneTimeLabel andTimerType:MZTimerLabelTypeStopWatch];
    timelabel.timeFormat = @"HH:mm:ss";
    timelabel.timerType = MZTimerLabelTypeStopWatch;
    timelabel.timeLabel.text = @"通话时长";
    [self.view addSubview:timelabel];
    
    
    
 


}
-(void)LookHangUp
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //这里取消显示alertview
        [phoneAlertView dismissWithClickedButtonIndex:0 animated:YES];
        [timelabel pause];
        [timelabel reset];
        timelabel.timeLabel.text = @"通话时长";
    });
    
    
}
-(void)log:(NSNotification*)notice
{
   
    //来电铃声响起
    CFBundleRef mainBundle;
    SystemSoundID soundFileObject;
    mainBundle = CFBundleGetMainBundle ();
    // Get the URL to the sound file to play
    CFURLRef soundFileURLRef  = CFBundleCopyResourceURL (mainBundle,CFSTR ("phone"),CFSTR ("caf"),NULL);
    AudioServicesCreateSystemSoundID (soundFileURLRef,&soundFileObject);
    // Add sound completion callback
    //循环
    // AudioServicesAddSystemSoundCompletion (soundFileObject, NULL, NULL,   completionCallback,(__bridge void*) self);
    // Play the audio
    AudioServicesPlaySystemSound(soundFileObject);
    
    NSArray *object =[notice object];
    phoneId= [object[0] integerValue];
    
    phoneAlertView = [[UIAlertView alloc] initWithTitle:@"有来电" message:[NSString stringWithFormat:@"您有个新来电请接听%@",object[1]] delegate:self cancelButtonTitle:nil otherButtonTitles:@"接听",@"拒接", nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [phoneAlertView show];
    });

  
   //本地通知有了来电
    locationRed ++;
     UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.alertBody =  [NSString stringWithFormat:@"%@给您来电,点击查看详情",object[1]];
    notification.applicationIconBadgeNumber = locationRed;
    // 通知被触发时播放的声音
    notification.soundName = UILocalNotificationDefaultSoundName;
    // 通知参数
    NSDictionary *userDict = [NSDictionary dictionaryWithObject:@"推送通知前台" forKey:@"key"];
    notification.userInfo = userDict;
    // ios8后，需要添加这个注册，才能得到授权
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationType type =  UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        // 通知重复提示的单位，可以是天、周、月
        notification.repeatInterval = NSCalendarUnitDay;
    }
    
    // 执行通知注册
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
   
  
}
#pragma 铃声循环的方法
//static void completionCallback (SystemSoundID  mySSID) {
//    // Play again after sound play completion
//    AudioServicesPlaySystemSound(mySSID);
//}
#pragma 来电回调
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex ==0)
    {
         [sip answer:phoneId];
        
       //接通电话开始走计时
        [timelabel start];
    }
    else
    {
        [sip callHangup];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)connectToServer:(UISwitch *)sender
{
    //  登陆
     if (sender.on)
    {
        int reg = [sip registerToServer:self.domain.text username:self.userName.text passwd:self.passwd.text];
        if (reg == 0)
        {
            //接收通知
            NSNotificationCenter *center =[NSNotificationCenter defaultCenter];
            [center addObserver:self selector:@selector(loginOrNot:) name:@"loginOrNot" object:nil];
        }
        else
        {
            [sender setOn:false animated:true];
        }
    }
    else
    {
        //注销
        dispatch_async(dispatch_get_main_queue(), ^{
            self.loginText.text = @"注销成功";
        });
        [sip unregister];
    }
    
}
-(void)loginOrNot:(NSNotification*)notice
{
    int object =[[notice object] integerValue];
    if (object == 200)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.loginText.text = @"登陆成功";
            });
    }
    else if(object== 403)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.loginText.text = @"登陆失败,检查账号密码";
        });
    }
}
- (IBAction)btn:(UIButton *)sender
{
    /**
     * 呼叫
     */
    if ([sender.currentTitle isEqual:@"呼叫"])
    {
        [sip makeCall:self.callWho.text domain:self.domain.text];
          [timelabel start];
    }
    /**
     *  挂断
     */
    else
    {
        [sip callHangup];
        //挂掉电话  停掉通话时长
        [timelabel pause];
        [timelabel reset];
         timelabel.timeLabel.text = @"通话时长";
        
    }
}

// 取消某个本地推送通知
+ (void)cancelLocalNotificationWithKey:(NSString *)key {
    // 获取所有本地通知数组
    NSArray *localNotifications = [UIApplication sharedApplication].scheduledLocalNotifications;
    
    for (UILocalNotification *notification in localNotifications) {
        NSDictionary *userInfo = notification.userInfo;
        if (userInfo) {
            // 根据设置通知参数时指定的key来获取通知参数
            NSString *info = userInfo[key];
            
            // 如果找到需要取消的通知，则取消
            if (info != nil) {
                [[UIApplication sharedApplication] cancelLocalNotification:notification];
                break;
            }
        }
    }
}

@end
