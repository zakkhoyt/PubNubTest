//
//  SPubNubViewController.swift
//  PubNubSDKTest
//
//  Created by Zakk Hoyt on 2/6/15.
//  Copyright (c) 2015 Zakk Hoyt. All rights reserved.
//

import UIKit

class SPubNubViewController: UIViewController, PNDelegate, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendTextField: UITextField!
    
    var clientIdentifier: NSString
    var clients, messages: NSMutableArray
    var channel: PNChannel?
    
    required init(coder aDecoder: NSCoder) {

        channel = nil
        clientIdentifier = ""
        clients = []
        messages = []
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPubNub()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

// MARK: Custom methods
    
    func setupPubNub(){
        PubNub.setDelegate(self)
        PubNub.setConfiguration(PNConfiguration.defaultConfiguration())
        PubNub.connect()
        PubNub.setClientIdentifier(self.clientIdentifier, shouldCatchup:true)
        
        PubNub.requestServerTimeTokenWithCompletionBlock { (timeToken, error) -> Void in
            if error != nil{
                println("Error requesting server time token: \(timeToken)")
            } else {
                println("requested server time token: \(timeToken)")
            }
        }
        
        self.channel = PNChannel.channelWithName("a", shouldObservePresence: true) as PNChannel?;
//        if let unwrappedChannel = self.channel{
//            var channels: Array = [unwrappedChannel]
        var channels: Array = [self.channel!]
            PubNub.subscribeOn(channels)
            PubNub.requestParticipantsListFor(channels, withCompletionBlock: { (clients : PNHereNow!, channels: Array!, error: PNError!) -> Void in
                if error != nil{
                    println("Error requesting participant list: " + error.description)
                } else {
                    println("Clients list: " + clients.description)
                    println("Channel list: " + channels.description)
                    
                    var participants:NSArray = clients.participantsForChannel(self.channel)
                    participants.enumerateObjectsUsingBlock({ (obj : AnyObject!, index : Int, stop) -> Void in
                        var client: PNClient = obj as PNClient
                        println("Participant present" + client.description)
                    })
                }
            })
            
            var yesterday = NSDate().dateByAddingTimeInterval(24 * 60 * 60)
            var pnYesterday = PNDate(date: yesterday)
            
            PubNub.requestHistoryForChannel(channel, from: pnYesterday , limit: 100, reverseHistory: true) { (history:[AnyObject]!, channel:PNChannel!, startDate:PNDate!, endDate:PNDate!, error:PNError!) -> Void in
                println("History messages: " + history.description)
            }
            
    }
    
    
    func renderMessages(messages : NSArray){
        let startIndex = self.messages.count
        let endIndex = self.messages.count + messages.count
        var indexSet = NSMutableIndexSet()
        var indexPaths: NSMutableArray = []
        for index in startIndex...endIndex{
            indexSet.addIndex(index)
            indexPaths.addObject(NSIndexPath(forRow: index, inSection: 0))
        }
        self.messages.insertObjects(messages, atIndexes: indexSet)
        self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    

    
    
    
// Mark: UITableViewDataSource

    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 2
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if section == 0{
            return self.clients.count
        } else if section == 1{
            return self.messages.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        var cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        if indexPath.section == 0{
            var client = self.clients[indexPath.row] as PNClient
            cell.textLabel?.text = client.identifier
            cell.detailTextLabel?.text = ""
        } else if indexPath.section == 1{
            var message = self.messages[indexPath.row] as PNMessage
            if message.message is String{
                println("message.class is String")
                cell.textLabel?.text = message.message as String?
            }
//            else if message.message is Dictionary {
//                println("message.class is String")
//            }
            else if message.message is NSString{
                println("message.class is NSString")
                cell.textLabel?.text = message.message as NSString
            } else if message.message is NSDictionary{
                println("message.class is NSString")
                cell.textLabel?.text = message.message.description
            }
//            cell.textLabel?.text = message.message
            
        }
        return cell
    }
    

    // MARK: IBActions
    
    @IBAction func sendButtonTouchUpInside(sender: AnyObject) {
        
//        PubNub.sendMessage(self.sendTextField?.text, toChannel: !channel, storeInHistory: YES) { (state: PNMessageState, message: AnyObject!) -> Void in
//            
//        }
    }
    
}






























