//
//  ViewController.m
//  sip
//
//  Created by QF  on 15/4/13.
//  Copyright (c) 2015年 BZW. All rights reserved.
//

#import "ViewController.h"
@interface ViewController ()


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

    if ([sender.currentTitle isEqual:@"呼叫"])
    {
        [sip makeCall:self.callWho.text domain:self.domain.text];

    }
    else
    {
        [sip callHangup];
    }
}


@end
