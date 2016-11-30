//
//  MainMenuController.swift
//  FlashAudio
//
//  Created by Serena Chan on 29/5/2016.
//  Copyright © 2016 Serena Chan. All rights reserved.
//

import Cocoa
import Firebase

class MainMenuController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    var peopleWithTimestamps : Dictionary<String, Dictionary<String, String>> = [:]
    let firebaseRef = Firebase(url: "https://flashaudio.firebaseio.com")
    
    @IBOutlet weak var contactButton: NSButton!
    @IBOutlet weak var menuButton: NSButton!
    @IBOutlet weak var tableView: NSTableView!
    
    var tempSelectedRow : Int?;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contactButton.image = NSImage(contentsOfURL: NSURL(fileURLWithPath: "/Users/serenachan/Documents/FlashAudio/FlashAudio/Personal.png"))
        menuButton.image = NSImage(contentsOfURL: NSURL(fileURLWithPath: "/Users/serenachan/Documents/FlashAudio/FlashAudio/star-xxl.png"))
        loadUsersAndMessages()
    }
    
    //Loads ALL users for now, will limit to friends later
    func loadUsersAndMessages(){
        let firebaseRef = Firebase(url: "https://flashaudio.firebaseio.com")
        let ref = firebaseRef.childByAppendingPath("usermap")
        ref.queryOrderedByKey().observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            if let val = snapshot.value as? Dictionary<String,String>{
                for i in val{
                    self.peopleWithTimestamps[i.1] = ["username":i.0,"last_time":"100","unread":""]
                }
            }
            else{
                print(snapshot.value)
                print("Loading users error!")
            }
            print("Users loaded");
            self.tableView.reloadData()
            self.loadMessages()
        })
    }
    
    func loadMessages(){
        print(CurrentSession.uid)
        let userref = firebaseRef.childByAppendingPath("users/" + CurrentSession.uid)
        let ref = userref.childByAppendingPath("messagemap")
        ref.queryOrderedByKey().observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            if let val = snapshot.value as? Dictionary<String,Dictionary<String,String>>{
                for i in val{
                    if let sender = i.1["sender"]{
                        self.peopleWithTimestamps[sender]!["unread"] = i.0
                        let timeStampDate = TimeFormatter.currentTimeLongToDate(Int64(i.1["timestamp"]!)!)
                        let date = NSDateFormatter.localizedStringFromDate(timeStampDate, dateStyle: .MediumStyle, timeStyle: .MediumStyle)
                        self.peopleWithTimestamps[sender]!["last_time"] = date
                    }
                    else{
                        print("no sender")
                    }
                    
                }
            }
            else{
                print(snapshot.value)
                print("Loading messages error!")
            }
            print("Messages loaded")
            self.tableView.reloadData()
        })
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return peopleWithTimestamps.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return nil
    }
    
    func tableView(tableView: NSTableView, setObjectValue object: AnyObject?, forTableColumn tableColumn: NSTableColumn?, row: Int) {
        //do nothing
    }
    
    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        tempSelectedRow = row;
        performSegueWithIdentifier("sendNewMessage", sender: self)
        return true
    }
    
    func peopleSortedByTimestamp() -> [(String, Dictionary<String, String>)]{
        let sortedByTimestamps = peopleWithTimestamps.sort({
            if(Int($0.0.1["last_time"]!) > Int($0.1.1["last_time"]!)){
                return false;
            }
            else{
                return true;
            }
        })
        return sortedByTimestamps;
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var view = tableView.makeViewWithIdentifier("MyView", owner: self)
        let bigFontSize = 36
        let littleFontSize = 18
        if (view == nil) {
            class PassThroughTextView : NSTextView{
                override func hitTest(aPoint: NSPoint) -> NSView? {
                    return nil
                }
            }
            view = NSView(frame: NSMakeRect(0, 0, 100, CGFloat(bigFontSize + littleFontSize)));
            let result = PassThroughTextView(frame: NSMakeRect(0, CGFloat(littleFontSize), 800, CGFloat(bigFontSize)));
            let result2 = PassThroughTextView(frame: NSMakeRect(0, 0, 800, CGFloat(littleFontSize)));
            result.font = NSFont(descriptor: (result.font?.fontDescriptor)!, size: 24)
            result.string = peopleSortedByTimestamp()[row].1["username"]!
            let unread = peopleSortedByTimestamp()[row].1["unread"]!
            let lastTime = peopleSortedByTimestamp()[row].1["last_time"]!
            if unread != ""{
                result2.string = "Unread message at " + lastTime
            }
            else{
                result2.string = lastTime
            }
            result.selectable = false
            result2.selectable = false
            result.drawsBackground = false;
            result2.drawsBackground = false;
            view?.addSubview(result)
            view?.addSubview(result2)
        }
        
        return view;
        
    }
    
    func audioPlayback(messageID: String!){
        
        firebaseRef.childByAppendingPath(CurrentSession.uid + "/messages/" + messageID).queryOrderedByKey().observeSingleEventOfType(FEventType.Value, withBlock: {
            snapshot in
            let message = snapshot.value["message"] as! String
            self.firebaseRef.childByAppendingPath(CurrentSession.uid + "/privatekey/key").queryOrderedByKey().observeSingleEventOfType(FEventType.Value, withBlock: {
                snapshot in
                if let privateKey = snapshot.value as? String{
                    let privateRKey = EncryptAudio.RSAFromPrivateKeyString(privateKey)
                    let audio = EncryptAudio.RSADecryptFromString(message, key: privateRKey)
                    let audioPlayer = AudioPlayer()
                    do{
                        try audioPlayer.initAudioPlayer(audio)
                        try audioPlayer.playback()
                    }
                    throws{
                        
                    }
                
                }
            })
        })
    }
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        let destination = segue.destinationController as! SendNewMessageController
        
        destination.recipient = peopleSortedByTimestamp()[tempSelectedRow!].1["username"]!
        destination.recipientUID = peopleSortedByTimestamp()[tempSelectedRow!].0
    }
}
