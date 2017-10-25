//
//  Song.swift
//  JapaneseLyricsHelper
//
//  Created by  on Oct/23/2017.
//

import UIKit

class Song {
    
    //MARK: Properties
    
    var name: String
    var title: String
    var languages: [String]
    var lyrics: [String]?
    
    
    //MARK: Initialization
    
    init?(name: String, title: String, languages: [String], lyrics: [String]?) {
        self.name = name
        self.title = title
        self.languages = languages
        self.lyrics = lyrics
        
        if name.isEmpty || title.isEmpty || languages.isEmpty {
            return nil
        }
    }
    
}
