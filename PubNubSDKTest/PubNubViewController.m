//
//  ViewController.m
//  PubNubSDKTest
//
//  Created by Zakk Hoyt on 2/5/15.
//  Copyright (c) 2015 Zakk Hoyt. All rights reserved.
//
//  https://admin.pubnub.com/#/user/241884/app/247197
//  http://cocoadocs.org/docsets/PubNub/3.7.1/
//  http://www.pubnub.com/console/?channel=demo&origin=pubsub.pubnub.com&sub=demo&pub=demo&cipher=&ssl=false&secret=&auth=

#import "PubNubViewController.h"
#import "PNImports.h"

//#define VWW_CUSTOM_CONFIG 1;
//#define VWW_BLOCK_CALLBACKS 1
static NSString *PNServer =         @"pubsub.pubnub.com";
static NSString *PNKeyName =        @"Sandbox";
static NSString *PNTier =           @"Sandbox";
static NSString *PNPublishKey =     @"pub-c-c6c6f7a6-052c-4968-8263-843b9218e438";
static NSString *PNSubscribeKey =   @"sub-c-331c7b22-ad66-11e4-98a9-02ee2ddab7fe";
static NSString *PNSecretKey =      @"sec-c-YzAwNjFmOGItODY0NS00NjRiLThjMjAtOWExOWZmM2Q0ZjRj";

typedef enum {
    PubNubViewControllerSectionClients = 0,
    PubNubViewControllerSectionMessages = 1,
} PubNubViewControllerSection;

@interface PubNubViewController () <PNDelegate, UITextFieldDelegate>
@property (nonatomic, strong) PNChannel *channel_1;
@property (weak, nonatomic) IBOutlet UITextField *sendTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *keyboardAccessoryView;

@property (nonatomic, strong) NSMutableArray *clients;
@property (nonatomic, strong) NSMutableArray *messages;
@end

@implementation PubNubViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clients = [@[]mutableCopy];
    self.messages = [@[]mutableCopy];

    [self.tableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self subscribePubNub];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self unsubscribePubNub];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark Private methods
-(void)renderClients:(NSArray*)clients{
    
    // Add to data structure
    NSUInteger startIndex = self.clients.count;
    NSUInteger endIndex = self.clients.count + clients.count;
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc]init];
    NSMutableArray *indexPaths = [[NSMutableArray alloc]initWithCapacity:clients.count];
    for(NSUInteger index = startIndex; index < endIndex; index++){
        [indexSet addIndex:index];
        [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:PubNubViewControllerSectionClients]];
    }
    [self.clients insertObjects:clients atIndexes:indexSet];
    
    // Insert in tableView
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    

}







-(void)renderMessages:(NSArray*)messages{
    
    // Add to data structure
    NSUInteger startIndex = self.messages.count;
    NSUInteger endIndex = self.messages.count + messages.count;
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc]init];
    NSMutableArray *indexPaths = [[NSMutableArray alloc]initWithCapacity:messages.count];
    for(NSUInteger index = startIndex; index < endIndex; index++){
        [indexSet addIndex:index];
        [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:PubNubViewControllerSectionMessages]];
    }
    [self.messages insertObjects:messages atIndexes:indexSet];
    
    // Insert in tableView
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count-1 inSection:PubNubViewControllerSectionMessages] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark IBActions
- (IBAction)sendButtonTouchUpInside:(UIButton*)sender {
    sender.enabled = NO;
    [PubNub sendMessage:self.sendTextField.text toChannel:self.channel_1 storeInHistory:YES withCompletionBlock:^(PNMessageState state, PNMessage *message) {
        if(state == PNMessageSending){
            
        } else if(state == PNMessageSent){
            NSLog(@"Sent message: %@", message);
//            [self renderMessages:@[message]];
            self.sendTextField.text = @"";
            sender.enabled = YES;
        } else {
            NSLog(@"Error: Could not send message");
            sender.enabled = YES;
        }
    }];
}

#pragma UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}



#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == PubNubViewControllerSectionClients){
        return self.clients.count;
    } else if(section == PubNubViewControllerSectionMessages){
        return self.messages.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if(indexPath.section == PubNubViewControllerSectionClients){
        PNClient *client = self.clients[indexPath.row];
        cell.textLabel.text = client.identifier;
        cell.detailTextLabel.text = @"";
    } else if(indexPath.section == PubNubViewControllerSectionMessages){
        PNMessage *message = self.messages[indexPath.row];
        if([message.message isKindOfClass:[NSString class]]){
            cell.textLabel.text = message.message;
        } else if([message.message isKindOfClass:[NSDictionary class]]){
            NSDictionary *d = message.message;
            cell.textLabel.text = d.description;
        }
        
        cell.detailTextLabel.text = message.receiveDate.date.description;
    }

    return cell;
}


#pragma mark UITableViewDelegate
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == PubNubViewControllerSectionClients){
        return @"Clients";
    } else if(section == PubNubViewControllerSectionMessages){
        return @"Messages";
    }
    return nil;
    
}

#pragma mark PubNub

-(void)subscribePubNub{
    
#ifndef VWW_BLOCK_CALLBACKS
    // Delegate
    [PubNub setDelegate:self];
    
    // Configuration
#if defined(VWW_CUSTOM_CONFIG)
    PNConfiguration *config = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey:@"pub-c-c6c6f7a6-052c-4968-8263-843b9218e438" subscribeKey:@"sub-c-331c7b22-ad66-11e4-98a9-02ee2ddab7fe" secretKey:nil];
    [PubNub setConfiguration:config];
#else
    [PubNub setConfiguration:[PNConfiguration defaultConfiguration]];
#endif
    
    // Connect
    [PubNub connect];
    [PubNub setClientIdentifier:self.clientIdentifier shouldCatchup:YES];

    // Request server time (this is really a connection test)
    [PubNub requestServerTimeTokenWithCompletionBlock:^(NSNumber *timetoken, PNError *error){
        if(error) {
            NSLog(@"Error requesting server time token: %@", error.description);
        } else {
            NSLog(@"Requested server time token: %@", timetoken);
        }
    }];
    
    // Create channel and subscribe to i
    self.channel_1 = [PNChannel channelWithName:@"channel_1" shouldObservePresence:YES];
    [PubNub subscribeOn:@[self.channel_1]];
    
    // Get list of participants
    [PubNub requestParticipantsListFor:@[self.channel_1] withCompletionBlock:^(PNHereNow *clients, NSArray *channels, PNError *error) {
        if(error){
            NSLog(@"Error requesint participant list: %@", error.description);
        } else {
            NSLog(@"Participant List: %@", clients);// array of PNClient
            NSLog(@"Channels: %@", channels);
            
            [[clients participantsForChannel:self.channel_1] enumerateObjectsUsingBlock:^(PNClient *client, NSUInteger idx, BOOL *stop) {
                NSLog(@"Client: %@", client.description);
                [self renderClients:@[client]];
            }];
        }
    }];
    

    // Get channel message history
    NSDate *yesterday = [NSDate dateWithTimeInterval:60 * 60 * 24 sinceDate:[NSDate date]];
    [PubNub requestHistoryForChannel:self.channel_1 from:[PNDate dateWithDate:yesterday] limit:100 withCompletionBlock:^(NSArray *messages, PNChannel *channel, PNDate *startDate, PNDate *endDate, PNError *error){
        NSLog(@"History messages: %@", messages);
        [self renderMessages:messages];
    }];
    
#else
    
    // Delegate
    [PubNub setDelegate:self];
    
    // Configuration
#if defined(VWW_CUSTOM_CONFIG)
    PNConfiguration *config = [PNConfiguration configurationForOrigin:PNServer publishKey:PNPublishKey subscribeKey:PNSubscribeKey secretKey:nil];
    [PubNub setConfiguration:config];
#else
    [PubNub setConfiguration:[PNConfiguration defaultConfiguration]];
#endif
    
    // Connect
    [PubNub connect];
    
    // Client name
    [PubNub setClientIdentifier:self.clientIdentifier shouldCatchup:YES];
    
    // Channel
    self.channel_1 = [PNChannel channelWithName:@"a" shouldObservePresence:YES];


    
    [[PNObservationCenter defaultCenter] addClientConnectionStateObserver:self withCallbackBlock:^(NSString *origin, BOOL connected, PNError *error) {
        if(connected){
            NSLog(@"Observer connection successful");
            [PubNub subscribeOn:@[self.channel_1]];
        } else {
            NSLog(@"Error adding observer: %@", error);
        }
    }];
    
    
    [[PNObservationCenter defaultCenter] addClientChannelSubscriptionStateObserver:self withCallbackBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
        switch (state) {
            case PNSubscriptionProcessSubscribedState:
                NSLog(@"Subscribed to channel: %@", channels[0]);
                break;
            case PNSubscriptionProcessNotSubscribedState:
                NSLog(@"Not subscribed to channel: %@ error: %@", channels[0], error);
                break;
            case PNSubscriptionProcessWillRestoreState:
                NSLog(@"Will resubscribed to channel: %@", channels[0]);
                break;
            case PNSubscriptionProcessRestoredState:
                NSLog(@"Resubscribed to channel: %@", channels[0]);
                break;
                
            default:
                break;
        }
    }];
    
    [[PNObservationCenter defaultCenter] addMessageReceiveObserver:self withBlock:^(PNMessage *message) {
        NSLog(@"Observer: channel: %@, message: %@", message.channel.name, message.message);
        [self renderMessages:@[message]];
    }];
    
    
//    [[PNObservationCenter defaultCenter] addChannelParticipantsListProcessingObserver:self withBlock:^(PNHereNow *clients, NSArray *channels, PNError *error) {
//        if(error){
//            NSLog(@"Error requesint participant list: %@", error.description);
//        } else {
//            NSLog(@"Participant List: %@", clients);// array of PNClient
//            NSLog(@"Channels: %@", channels);
//            
//            [[clients participantsForChannel:self.channel_1] enumerateObjectsUsingBlock:^(PNClient *client, NSUInteger idx, BOOL *stop) {
//                NSLog(@"Client: %@", client.description);
//                [self renderClients:@[client]];
//            }];
//        }
//        
//    }];
    
    // Get list of participants
    [PubNub requestParticipantsListFor:@[self.channel_1] withCompletionBlock:^(PNHereNow *clients, NSArray *channels, PNError *error) {
        if(error){
            NSLog(@"Error requesint participant list: %@", error.description);
        } else {
            NSLog(@"Participant List: %@", clients);// array of PNClient
            NSLog(@"Channels: %@", channels);
            
            [[clients participantsForChannel:self.channel_1] enumerateObjectsUsingBlock:^(PNClient *client, NSUInteger idx, BOOL *stop) {
                NSLog(@"Client: %@", client.description);
                [self renderClients:@[client]];
            }];
        }
    }];
    

    // Get channel message history
    NSDate *yesterday = [NSDate dateWithTimeInterval:60 * 60 * 24 sinceDate:[NSDate date]];
    [PubNub requestHistoryForChannel:self.channel_1 from:[PNDate dateWithDate:yesterday] limit:100 withCompletionBlock:^(NSArray *messages, PNChannel *channel, PNDate *startDate, PNDate *endDate, PNError *error){
        NSLog(@"History messages: %@", messages);
        [self renderMessages:messages];
    }];

//    [PubNub updateClientState:<#(NSString *)#> state:<#(NSDictionary *)#> forObject:<#(id<PNChannelProtocol>)#>
//    [[PNObservationCenter defaultCenter] addClientStateUpdateObserver:self withBlock:^(PNClient *client, PNError *error) {
//
//    }];
#endif
}

-(void)unsubscribePubNub{
    
    [PubNub unsubscribeFrom:@[self.channel_1] withCompletionHandlingBlock:^(NSArray *channels, PNError *error) {
        if(error){
            NSLog(@"Error unsubscribing: %@", error.description);
        } else {
            NSLog(@"Ensubscribed from channels: %@", channels.description);
        }
    }];
}



#pragma mark PNDelegate
#ifndef VWW_BLOCK_CALLBACKS
- (void)pubnubClient:(PubNub *)client didReceiveParticipants:(PNHereNow *)clients forObjects:(NSArray *)channelObjects{
    [[clients participantsForChannel:self.channel_1] enumerateObjectsUsingBlock:^(PNClient *client, NSUInteger idx, BOOL *stop) {
        NSLog(@"Client: %@", client.description);
        [self renderClients:@[client]];
    }];

}
- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message{
    NSLog(@"Delegate: %@", [NSString stringWithFormat:@"received: %@", message.message]);
    [self renderMessages:@[message]];
}

#else

#endif
//-(void)pubnubClient:(PubNub *)client didSubscribeOn:(NSArray *)channelObjects{
//    NSLog(@"Delegate: subscribed on %@", channelObjects);
//}
@end
