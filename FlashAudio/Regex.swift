//
//  Regex.swift
//  FlashAudio
//
//  Created by Serena Chan on 2/6/2016.
//  Copyright © 2016 Serena Chan. All rights reserved.
//

import Foundation

class Regex {
    let internalExpression: NSRegularExpression
    let pattern: String
    
    init(_ pattern: String){
        self.pattern = pattern
        do{
            try self.internalExpression = NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
        }
        catch{
            internalExpression = NSRegularExpression()
        }
    }
    
    func test(input: String) -> Bool {
        let matches = self.internalExpression.matchesInString(input, options: NSMatchingOptions.init(rawValue: 0), range:NSMakeRange(0, input.characters.count))
        return matches.count > 0
    }
}