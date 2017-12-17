//
//  LyricRow.swift
//  JapaneseLyricsHelper
//
//  Created by  on Oct/26/2017.
//

import UIKit

class LyricRow {
    
    //MARK: Properties
    
    var lastAffectedIndex: Int
    var lastDelta: Int
    var lyricInfo: [[String:AnyObject]]
    
    
    
    //MARK: Initialization
    
    init?(lastAffectedIndex: Int = -1, lastDelta: Int = 0, lyricInfo: [[String:AnyObject]]) {
        self.lastAffectedIndex = lastAffectedIndex
        self.lastDelta = lastDelta
        self.lyricInfo = lyricInfo
        
        if lyricInfo.isEmpty {
            return nil
        }
    }
    
}


