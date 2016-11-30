//
//  AudioProcessor.swift
//  FlashAudio
//
//  Created by Serena Chan on 12/5/2016.
//  Copyright © 2016 Serena Chan. All rights reserved.
//

import Foundation
import AVFoundation

enum AudioProcessing: ErrorType{
    case RecorderInitializationError(errorMessage: String)
    case PlaybackError(errorMessage: String)
    case FileNotFoundError(errorMessage: String)
    case FileInitializationError(errorMessage: String)
}

class AudioRecorder{
    
    private let folderPath = "\(NSHomeDirectory())/Library/Application Support/FlashAudio/"
    private let folderName = "recordings"
    
    private var audioRecorder: AVAudioRecorder?
    private var fileLocation: String
    private var initialized: Bool
    private let recordSettings :[String : AnyObject] = [
        AVFormatIDKey:Int(kAudioFormatAppleIMA4),
        AVSampleRateKey:44100.0,
        AVNumberOfChannelsKey:2,
        AVEncoderBitRateKey:12800,
        AVLinearPCMBitDepthKey:16,
        AVEncoderAudioQualityKey:AVAudioQuality.Max.rawValue
    ]
    
    init(){
        initialized = false
        fileLocation = ""
    }
    
    func initAudioRecorder() throws{
        var initializedRecorder: AVAudioRecorder?
        defer{
            audioRecorder = initializedRecorder
        }
        let currentDate = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yy HHmmss"
        let fileName = dateFormatter.stringFromDate(currentDate) + ".caf"
        let filePath = folderPath + folderName + "/" + fileName
        print(filePath)
        if(!folderName.createSubFolderAt(NSURL(fileURLWithPath: folderPath))){
            throw AudioProcessing.FileInitializationError(errorMessage: "Error: File cannot be created. Check folder permissions.")
        }
        fileLocation = filePath
        let url = NSURL(fileURLWithPath: fileLocation)
        do{
            initializedRecorder = try AVAudioRecorder(URL: url, settings: recordSettings)
            if(!initializedRecorder!.prepareToRecord()){
                throw AudioProcessing.RecorderInitializationError(errorMessage: "")
            }
            initialized = true
        }
        catch{
            initialized = false
            print("Cannot initialize recorder.")
            throw AudioProcessing.RecorderInitializationError(errorMessage: "Error: Cannot initialize recorder.")
        }
    }

    func record() throws{
        if(initialized){
            audioRecorder!.record()
        } else{
            throw AudioProcessing.RecorderInitializationError(errorMessage: "Error: Recorder not initialized.")
        }
    }
    
    func stop(){
        if(initialized){
            audioRecorder!.stop()
        }
    }
    
    func getFileLocation() -> String{
        return fileLocation
    }
    
    func clear(){
        initialized = false
        fileLocation = ""
    }
}

class AudioPlayer{
    
    private var audioPlayer: AVAudioPlayer?
    private var data: NSData!
    private var initialized: Bool
    
    init(){
        initialized = false
        data = nil
    }
    
    func initAudioPlayer(data: NSData?) throws{
        if let audioData = data{
            self.data = audioData
            var initializedPlayer: AVAudioPlayer?
            defer{
                audioPlayer = initializedPlayer
            }
            do{
                initializedPlayer = try AVAudioPlayer(data: audioData)
                initializedPlayer?.prepareToPlay()
                initialized = true
            }
            catch{
                initialized = false
                print("Cannot initialize player. Audio data not valid.")
                throw AudioProcessing.FileNotFoundError(errorMessage: "Error: Audio corrupted.")
            }
        } else{
            throw AudioProcessing.FileInitializationError(errorMessage: "Error: Audio data corrupted.")
        }
    }
    
    func playback() throws{
        if(initialized){
            audioPlayer!.play()
        }
        else{
            throw AudioProcessing.PlaybackError(errorMessage: "Error: Player is setup incorrectly.")
        }
    }

}

extension String {
    func createSubFolderAt(location: NSURL ) -> Bool {
        do{
            try NSFileManager().createDirectoryAtURL(location.URLByAppendingPathComponent(self), withIntermediateDirectories: true, attributes: nil)
            return true
        }
        catch let error as NSError {
            print(error.description)
            return false
        }
    }
}