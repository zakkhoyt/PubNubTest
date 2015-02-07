//
//  PubNubController.m
//  PubNubSDKTest
//
//  Created by Zakk Hoyt on 2/5/15.
//  Copyright (c) 2015 Zakk Hoyt. All rights reserved.
//
//  https://admin.pubnub.com/#/user/241884/app/247197
//  http://cocoadocs.org/docsets/PubNub/3.7.1/
//  http://www.pubnub.com/console/?channel=demo&origin=pubsub.pubnub.com&sub=demo&pub=demo&cipher=&ssl=false&secret=&auth=



//App Name        My First PubNub App
//Key Name        Sandbox
//Tier            Sandbox
//Publish Key     pub-c-c6c6f7a6-052c-4968-8263-843b9218e438
//Subscribe Key   sub-c-331c7b22-ad66-11e4-98a9-02ee2ddab7fe
//Secret Key      sec-c-YzAwNjFmOGItODY0NS00NjRiLThjMjAtOWExOWZmM2Q0ZjRj


#import "PubNubController.h"
#import "PNImports.h"

@interface PubNubController () <PNDelegate>
@property (nonatomic, strong) PNChannel *channel_1;
@end

@implementation PubNubController

+(instancetype)sharedInstance{
    static PubNubController *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[self alloc]init];
    });
    return instance;
}


- (instancetype)init{
    self = [super init];
    if (self) {
        [PubNub setDelegate:self];

        
//        PNConfiguration *config = [PNConfiguration configurationForOrigin:@"" publishKey:@"pub-c-c6c6f7a6-052c-4968-8263-843b9218e438" subscribeKey:@"sub-c-331c7b22-ad66-11e4-98a9-02ee2ddab7fe" secretKey:@"sec-c-YzAwNjFmOGItODY0NS00NjRiLThjMjAtOWExOWZmM2Q0ZjRj"];
        [PubNub setConfiguration:[PNConfiguration defaultConfiguration]];
        [PubNub connect];
        
        [PubNub requestServerTimeTokenWithCompletionBlock:^(NSNumber *timetoken, PNError *error){
            if(error) {
                NSLog(@"error: %@", error.description);
            } else {
                NSLog(@"%@", timetoken);
            }
        }];
        
        self.channel_1 = [PNChannel channelWithName:@"a" shouldObservePresence:YES];
        [PubNub subscribeOn:@[self.channel_1]];
        
        
        [PubNub sendMessage:@"Hello from iOS" toChannel:self.channel_1];

        
        [PubNub requestParticipantsListFor:@[self.channel_1] withCompletionBlock:^(PNHereNow *hereNow, NSArray *channels, PNError *error) {
            if(error){
                NSLog(@"error: %@", error.description);
            } else {
                NSLog(@"HereNow: %@", hereNow);
                NSLog(@"array: %@", channels);
            }
        }];
        
        
    }
    return self;
}

-(void)dealloc{
    [PubNub unsubscribeFrom:@[self.channel_1] withCompletionHandlingBlock:^(NSArray *channels, PNError *error) {
        if(error){
            NSLog(@"error: %@", error.description);
        } else {
            NSLog(@"unsubscribed from channels: %@", channels.description);
        }

    }];
}



- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message{
    NSLog(@"%@", [NSString stringWithFormat:@"received: %@", message.message]);
}
@end
