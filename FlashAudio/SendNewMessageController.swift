//
//  SendNewMessageController.swift
//  FlashAudio
//
//  Created by Serena Chan on 3/6/2016.
//  Copyright © 2016 Serena Chan. All rights reserved.
//

import Firebase
import Cocoa

class SendNewMessageController: NSViewController {
    
    //need to implement record time and resetting time when cancel is pressed
    
    @IBOutlet weak var recipientLabel : NSTextField!
    //Record time not implemented yet
    @IBOutlet weak var recordTimeLabel : NSTextField!
    @IBOutlet weak var recordButton : NSButton!
    @IBOutlet weak var sendButton: NSButton!
    @IBOutlet weak var cancelButton: NSButton!
    
    var recipient : String?
    var recipientUID : String?
    var started = false
    let rec = AudioRecorder()

    override func viewDidLoad() {
        super.viewDidLoad()
        updateRecipientLabelMessage()
        // Do view setup here.
    }
    
    func updateRecipientLabelMessage(){
        let outText : String;
        if let out = recipient{
            outText = out;
        }
        else{
            outText = "..."
        }
        let labelText = "Sending message to " + outText
        recipientLabel.stringValue = labelText
    }
    
    @IBAction func recordAudio(sender: AnyObject){
        if(!started){
            started = true
            do{
                try rec.initAudioRecorder()
                try rec.record()
            }
            catch{
                recordTimeLabel.stringValue = "Recording Error!"
            }
            recordButton.title = "Stop"
        }
        else{
            started = false
            rec.stop()
            recordButton.title = "Record"
            //sendRecording();
        }
    }
    
    func sendRecording(){
        //get public key of recipient
        let firebaseRef = Firebase(url: "https://flashaudio.firebaseio.com")
        let ref = firebaseRef.childByAppendingPath("users/" + recipientUID!)
        ref.childByAppendingPath("publickey").queryOrderedByKey().observeSingleEventOfType(FEventType.Value, withBlock: {
            snapshot in
            if let pub = snapshot.value["key"] as? String{
                
                let rsa = EncryptAudio.RSAFromPublicKeyString(pub)
                
                let url = NSURL(fileURLWithPath: self.rec.getFileLocation())
                if let data = NSData(contentsOfURL: url){
                    let encrypted = EncryptAudio.RSAEncryptToString(data, key: rsa)
                    
                    let messageID = self.generateMessageID()
                    let timestamp = self.generateTimestamp()
                    
                    ref.childByAppendingPath("messages").updateChildValues([messageID: ["sender": CurrentSession.uid, "timestamp": timestamp, "message":encrypted]])
                    
                    ref.childByAppendingPath("messagemap").updateChildValues([messageID:["sender": CurrentSession.uid, "timestamp": timestamp]])
                }
                else{
                    self.recordTimeLabel.stringValue = "Sending Error!"
                }
                
                
                
            }
        })
        
        //EncryptAudio.EncryptAudio(url, key: <#T##UnsafeMutablePointer<RSA>#>)
    }

    func generateMessageID() -> String{
        return String(arc4random()) + String(arc4random())
    }

    @IBAction func triggerCancel(sender: AnyObject) {
        started = false
        rec.clear()
    }
    
    @IBAction func triggerSend(sender: AnyObject) {
        sendRecording()
    }
    
    func generateTimestamp() -> String{
        return String(TimeFormatter.currentTimeToLong())
    }
    
    
}
