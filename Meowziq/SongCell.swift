//
//  SongCell.swift
//  Meowziq
//
//  Created by Seiji Kohyama on 2015/05/12.
//  Copyright (c) 2015年 FaithCreates Inc. All rights reserved.
//

import MediaPlayer
import UIKit

class SongCell : UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setCell(item: MPMediaItem) {
        self.titleLabel.text = item.title
        self.artistLabel.text = item.artist
    }
}