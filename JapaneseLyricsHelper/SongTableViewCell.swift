//
//  SongTableViewCell.swift
//  JapaneseLyricsHelper
//
//  Created by  on Oct/23/2017.
//

import UIKit

class SongTableViewCell: UITableViewCell {
    
    //MARK: Properties

    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var languagesLabel: UILabel!
    @IBOutlet weak var playButtonImage: UIImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
