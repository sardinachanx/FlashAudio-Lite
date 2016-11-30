//
//  AudioEncryption.swift
//  FlashAudio
//
//  Created by Serena Chan on 16/5/2016.
//  Copyright © 2016 Serena Chan. All rights reserved.
//

import Foundation
import Security


enum AudioEncryption: ErrorType{
    case FileNotFoundError(errorMessage: String)
    case EncryptionError(errorMessage: String)
    case DecryptionError(errorMessage: String)
}

public class EncryptAudio{
    
    //max length: 86 bytes
    
    static let chunkSize = 86
    static let decryptChunkSize = 128
    
    static func EncryptAudio(url: NSURL, key: UnsafeMutablePointer<RSA>) throws -> String{
        let data = NSData(contentsOfURL: url)
        if let uData = data{
            
            
            
            /*//let dataString = String(data: uData, encoding: NSUTF8StringEncoding)
            let blockSize = 16;
            var encryptedData = [UInt8](count: Int(blockSize), repeatedValue: 0)
            var encryptedDataLength = blockSize
            let plainText = "A string to be encrypted"
            
            let textData = [UInt8](plainText.utf8)
            let textDataLength = UInt(plainText.characters.count)
            //let a = SecKeyEncr
            //let result = SecKeyEncrypt(publicKey, SecPadding(kSecPaddingPKCS1Key),
             //                      textData, textDataLength, &encryptedData, &encryptedDataLength)
            */
            return RSAEncryptToString(uData, key: key);
        }else{
            throw AudioEncryption.FileNotFoundError(errorMessage: "Error: File not found.")
        }
        //return ""
    }
    
    static func RSAEncryptStringToString(input: String, key: UnsafeMutablePointer<RSA>) -> String{
        return RSAEncryptToString(input.dataUsingEncoding(NSUTF8StringEncoding)!, key: key)
    }
    
    static func RSADecryptStringFromString(input: String, key: UnsafeMutablePointer<RSA>) -> String?{
        if let data = RSADecryptFromString(input, key: key){
            return String.init(data: data, encoding: NSUTF8StringEncoding)
        }
        return nil
    }
    
    //preserves length
    static func RSAEncryptToString(data: NSData, key: UnsafeMutablePointer<RSA>) -> String{
        let enc = RSAEncryptData(data, key: key)
        let b64 = enc.base64EncodedDataWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        return String(data.length) + "_" + String(data: b64, encoding: NSUTF8StringEncoding)!
    }
    
    //preserves length
    static func RSADecryptFromString(input: String, key: UnsafeMutablePointer<RSA>) -> NSData?{
        if let index = input.rangeOfString("_")?.startIndex{
            let subs = input.substringToIndex(index)
            let subs2 = input.substringFromIndex(index.advancedBy(1))
            if let num = Int(subs){
                if let data = NSData(base64EncodedString: subs2, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters){
                    let mutableData = NSMutableData(length: num)!
                    RSADecryptData(data, key: key).getBytes(mutableData.mutableBytes, length: num)
                    return mutableData
                }
            }
        }
        return nil
    }
    
    static func RSAGenerateKey() -> UnsafeMutablePointer<RSA>{
        let rsa = RSA_generate_key(Int32(1024), UInt(3), nil, nil)
        return rsa;
    }
    
    static func RSAToPublicKeyString(key: UnsafeMutablePointer<RSA>) -> String{
        let bio = BIO_new(BIO_s_mem());
        PEM_write_bio_RSAPublicKey(bio, key);
        let remaining = BIO_ctrl_pending(bio);
        let data = NSMutableData(length: remaining)!;
        BIO_read(bio, data.mutableBytes, Int32(remaining));
        return String(data: data, encoding: NSASCIIStringEncoding)!;
    }
    
    static func RSAToPrivateKeyString(key: UnsafeMutablePointer<RSA>) -> String{
        let bio = BIO_new(BIO_s_mem());
        PEM_write_bio_RSAPrivateKey(bio, key, nil, nil, 0, nil, nil);
        let remaining = BIO_ctrl_pending(bio);
        let data = NSMutableData(length: remaining)!;
        BIO_read(bio, data.mutableBytes, Int32(remaining));
        return String(data: data, encoding: NSASCIIStringEncoding)!;
    }
    
    static func RSAFromPublicKeyString(keyString: String) -> UnsafeMutablePointer<RSA>{
        let bio = BIO_new(BIO_s_mem());
        let data = keyString.dataUsingEncoding(NSASCIIStringEncoding)!;
        BIO_write(bio, data.bytes, Int32(data.length));
        let rsa = PEM_read_bio_RSAPublicKey(bio, nil, nil, nil);
        return rsa;
    }
    
    static func RSAFromPrivateKeyString(keyString: String) -> UnsafeMutablePointer<RSA>{
        let bio = BIO_new(BIO_s_mem());
        let data = keyString.dataUsingEncoding(NSASCIIStringEncoding)!;
        BIO_write(bio, data.bytes, Int32(data.length));
        let rsa = PEM_read_bio_RSAPrivateKey(bio, nil, nil, nil);
        return rsa;
    }
    
    
    static func RSAEncryptData(data: NSData, key: UnsafeMutablePointer<RSA>) -> NSData{
        
        
        if(data.length > chunkSize){
            let part = NSMutableData.init(length: chunkSize)!
            let rest = NSMutableData.init(length: data.length - chunkSize)!
            data.getBytes(part.mutableBytes, range: NSRange.init(location: 0, length: chunkSize))
            data.getBytes(rest.mutableBytes, range: NSRange.init(location: chunkSize, length: data.length - chunkSize))
            let partEncrypted = RSAEncryptData(part, key: key)
            let restEncrypted = RSAEncryptData(rest, key: key)
            let combined = NSMutableData.init(data: partEncrypted)
            combined.appendData(restEncrypted)
            return combined;
        }
        
        let encrypted = NSMutableData.init(length: decryptChunkSize)!
            
        _ = RSA_public_encrypt(Int32(data.length), UnsafePointer<UInt8>(data.bytes), UnsafeMutablePointer<UInt8>(encrypted.mutableBytes), key, RSA_PKCS1_OAEP_PADDING)
        //print(len)
        //RSA_free(key)
        return encrypted
    
    }
    
    static func RSADecryptData(data: NSData, key: UnsafeMutablePointer<RSA>) -> NSData{
        
        if(data.length > decryptChunkSize){
            let part = NSMutableData.init(length: decryptChunkSize)!
            let rest = NSMutableData.init(length: data.length - decryptChunkSize)!
            data.getBytes(part.mutableBytes, range: NSRange.init(location: 0, length: decryptChunkSize))
            data.getBytes(rest.mutableBytes, range: NSRange.init(location: decryptChunkSize, length: data.length - decryptChunkSize))
            let partEncrypted = RSADecryptData(part, key: key)
            let restEncrypted = RSADecryptData(rest, key: key)
            let combined = NSMutableData.init(data: partEncrypted)
            combined.appendData(restEncrypted)
            return combined;
        }
        
        let decrypted = NSMutableData.init(length: chunkSize)!
        
        _ = RSA_private_decrypt(Int32(data.length), UnsafePointer<UInt8>(data.bytes), UnsafeMutablePointer<UInt8>(decrypted.mutableBytes), key, RSA_PKCS1_OAEP_PADDING)
        //print(len)
        
        /*let errdata = NSMutableData.init(length: 256)!
        ERR_error_string(ERR_get_error(), UnsafeMutablePointer<Int8>(errdata.mutableBytes));
        print(String.init(data: errdata, encoding: NSUTF8StringEncoding));*/
        //RSA_free(key)
        return decrypted
        
    }
}