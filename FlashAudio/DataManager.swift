//
//  DataSender.swift
//  FlashAudio
//
//  Created by Serena Chan on 24/5/2016.
//  Copyright © 2016 Serena Chan. All rights reserved.
//

import Foundation
import Firebase

class Manager{
    var url = "https://flashaudio.firebaseio.com/"
    var firebaseRef: Firebase
    
    init(path: String){
        firebaseRef = Firebase(url: url + path)
    }
    
    func setDataPath(path: String){
        firebaseRef = Firebase(url: url + path)
    }
}
class DataManager: Manager{
    
    var path = "media/"
    
    init(){
        super.init(path: path)
    }
    
    func writeData(data: AnyObject){
        firebaseRef.setValue(data, withCompletionBlock: {
            error, ref in
            print("complete")
        });
    }
    
    func addDataListener(receiver: DataReceiver){
        firebaseRef.observeEventType(.Value, withBlock: {
            snapshot in
            receiver.receiveData(snapshot)
        })
    }
}

protocol DataReceiver {
    func receiveData(data: FDataSnapshot);
}