//
//  Song.swift
//  JapaneseLyricsHelper
//
//  Created by  on Oct/23/2017.
//

import UIKit

class Song {
    
    //MARK: Properties
    
    var title: String
    var languages: [String]
    var lyrics: [String]?
    
    
    //MARK: Initialization
    
    init?(title: String, languages: [String], lyrics: [String]?) {
        self.title = title
        self.languages = languages
        self.lyrics = lyrics
        
        if title.isEmpty || languages.isEmpty {
            return nil
        }
    }
    
}
