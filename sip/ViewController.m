//
//  ViewController.m
//  sip
//
//  Created by QF  on 15/4/13.
//  Copyright (c) 2015年 BZW. All rights reserved.
//

#import "ViewController.h"
@interface ViewController ()<UIAlertViewDelegate>
{
    int phoneId ;//来电话时  传过来的账号id
    UIAlertView *phoneAlertView;//来电的push页面

    int locationRed; //通知的数量
}
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *passwd;
@property (weak, nonatomic) IBOutlet UITextField *domain;
@property (weak, nonatomic) IBOutlet UITextField *callWho;



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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    sip = [[Pjsip alloc]init];
    locationRed = 0;
    //接收通知
    NSNotificationCenter *center =[NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(log:) name:@"reloadMessag" object:nil];
}
-(void)log:(NSNotification*)notice
{
   
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

#pragma 来电回调
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex ==0)
    {
         [sip answer:phoneId];
        
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
            NSLog(@"login");
        }
        else
        {
            [sender setOn:false animated:true];
        }
    }
    else
    {
        [sip unregister];
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

    }
    /**
     *  挂断
     */
    else
    {
        [sip callHangup];
    }
}


@end
