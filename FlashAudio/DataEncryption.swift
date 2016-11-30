//
//  DataEncryption.swift
//  FlashAudio
//
//  Created by Serena Chan on 4/6/2016.
//  Copyright © 2016 Serena Chan. All rights reserved.
//

import Foundation

enum SecurityError: ErrorType{
    
    case DataNotFoundError(errorMessage: String)
    case EncryptionError(errorMessage: String)
    case DecryptionError(errorMessage: String)
}

class RSASecurity{
    
    static let chunkSize = 86
    static let decryptChunkSize = 128

    static func RSAEncryptStringToString(input: String, key: UnsafeMutablePointer<RSA>) -> String?{
        return RSAEncryptToString(input.dataUsingEncoding(NSUTF8StringEncoding)!, key: key)
    }
    
    static func RSADecryptStringFromString(input: String, key: UnsafeMutablePointer<RSA>) -> String?{
        if let data = RSADecryptFromString(input, key: key){
            return String.init(data: data, encoding: NSUTF8StringEncoding)
        }
        return nil
    }

    static func RSAEncryptToString(data: NSData, key: UnsafeMutablePointer<RSA>) -> String{
        let enc = RSAEncryptData(data, key: key)
        let b64 = enc.base64EncodedDataWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        return String.init(data: b64, encoding: NSUTF8StringEncoding)!
    }
    
    static func RSADecryptFromString(input: String, key: UnsafeMutablePointer<RSA>) -> NSData?{
        if let data = NSData.init(base64EncodedString: input, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters){
            return RSADecryptData(data, key: key)
        }
        return nil
    }
    
    static func RSAGenerateKey() -> UnsafeMutablePointer<RSA>{
        let rsa = RSA_generate_key(Int32(1024), UInt(3), nil, nil)
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
        
        let encrypted = NSMutableData.init(length: 128)!
        
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
        
        let decrypted = NSMutableData.init(length: 128)!
        
        _ = RSA_private_decrypt(Int32(data.length), UnsafePointer<UInt8>(data.bytes), UnsafeMutablePointer<UInt8>(decrypted.mutableBytes), key, RSA_PKCS1_OAEP_PADDING)
        //print(len)
        
        /*let errdata = NSMutableData.init(length: 256)!
         ERR_error_string(ERR_get_error(), UnsafeMutablePointer<Int8>(errdata.mutableBytes));
         print(String.init(data: errdata, encoding: NSUTF8StringEncoding));*/
        //RSA_free(key)
        return decrypted
    }
}

class DataSecurity{
    
    static func EncryptAudio(url: NSURL, key: UnsafeMutablePointer<RSA>) throws -> String{
        let data = NSData(contentsOfURL: url)
        if let uData = data{
            return RSASecurity.RSAEncryptToString(uData, key: key);
        }else{
            throw SecurityError.DataNotFoundError(errorMessage: "Error: File not found.")
        }
        //return ""
    }
}