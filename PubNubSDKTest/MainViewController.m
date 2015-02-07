//
//  MainViewController.m
//  PubNubSDKTest
//
//  Created by Zakk Hoyt on 2/5/15.
//  Copyright (c) 2015 Zakk Hoyt. All rights reserved.
//

#import "MainViewController.h"
#import "PubNubViewController.h"

static NSString *SegueMainToChat = @"SegueMainToChat";
static NSString *SegueMainToSChat = @"SegueMainToSChat";
static NSString *MainViewControllerUsernameKey = @"username";

@interface MainViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        self.joinButton.enabled = self.usernameTextField.text.length;
    }];
    
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:MainViewControllerUsernameKey];
    if(username){
        self.usernameTextField.text = username;
        self.joinButton.enabled = YES;
    } else {
        self.usernameTextField.text = @"";
        self.joinButton.enabled = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:SegueMainToChat]){
        PubNubViewController *vc = segue.destinationViewController;
        vc.clientIdentifier = self.usernameTextField.text;
    }
    
}

- (IBAction)joinButtonTouchUpInside:(id)sender {
    
    [[NSUserDefaults standardUserDefaults] setValue:self.usernameTextField.text forKey:MainViewControllerUsernameKey];
    
//    [self performSegueWithIdentifier:@"SegueMainToChat" sender:self];
    [self performSegueWithIdentifier:@"SegueMainToSChat" sender:self];
}



@end
