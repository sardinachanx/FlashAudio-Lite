//
//  main.swift
//  FlashAudio
//
//  Created by Serena Chan on 17/5/2016.
//  Copyright © 2016 Serena Chan. All rights reserved.
//

import Foundation
import Firebase

class Main{

    static func testRecord() throws{
        let rec = AudioRecorder()

        print("start");
        do{
            try rec.initAudioRecorder()
            print("blhe")

            try rec.record();
            print("recording")
        }
        catch{
            print("No.")
            throw AudioProcessing.RecorderInitializationError(errorMessage: "no.")
        }

        sleep(5);

        print("stop");

        rec.stop();

    }

    static func testEncryptDecrypt(){
        let key = EncryptAudio.RSAGenerateKey()

        let message = "123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890";

        print(message.characters.count)

        let encrypted = EncryptAudio.RSAEncryptStringToString(message, key: key)

        print(encrypted)

        let decrypted = EncryptAudio.RSADecryptStringFromString(encrypted, key: key)!

        print("done")

        print(decrypted.characters.count)

        print(decrypted)
    }

    static func testFirebase(){
        
        class DataReceiverTest : DataReceiver{
            func receiveData(data: FDataSnapshot) {
                print("Receive data")
                print(data)
            }
        }
        
        let ds = DataManager()
        print("Start")
        //DataSender.addDataListener(DataReceiverTest())
        print("Added listener")
        ds.writeData(["hello": "helloworld"])
        print("Done sending")
    }

}

//Main.testFirebase();
//sleep(100000);
