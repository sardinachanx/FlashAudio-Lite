//
//  User.swift
//  FlashAudio
//
//  Created by Serena Chan on 4/6/2016.
//  Copyright © 2016 Serena Chan. All rights reserved.
//

import Foundation
import Firebase

class User{
    
    static let firebaseRef = Firebase(url: "https://flashaudio.firebaseio.com")
    static func createNewUser(username: String, email: String, uid: String){
        var ref = firebaseRef.childByAppendingPath("users/" + uid)
        //let rsa = RSA_new()
        //let pub = BIO_new(BIO_s_mem())
        
        let publicInfo = ["full_name" : "", "username" : username, "status" : "Hello! I am using FlashAudio."]
        ref.childByAppendingPath("public").setValue(publicInfo)
        let privateInfo = ["email" : email]
        ref.childByAppendingPath("private").setValue(privateInfo)
        ref = firebaseRef.childByAppendingPath("usermap")
        ref.updateChildValues([username: uid])
        //Generate RSA key
        let rsa = EncryptAudio.RSAGenerateKey()
        ref = firebaseRef.childByAppendingPath("users/" + uid)
        let pub = EncryptAudio.RSAToPublicKeyString(rsa)
        ref.childByAppendingPath("publickey").setValue(["key" : pub])
        let priv = EncryptAudio.RSAToPrivateKeyString(rsa)
        ref.childByAppendingPath("privatekey").setValue(["key" : priv])
        
        //ref.updateChildValues([username:uid])
        //let defaultMessage = ["Hi! Double click here to send your first message." : String(TimeFormatter.currentTimeToLong())]
        //ref.childByAppendingPath("public/messages").updateChildValues(defaultMessage)
    }
}