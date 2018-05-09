//
//  LelfMenuViewCell.swift
//  VocalRecording
//
//  Created by dev on 4/6/17.
//  Copyright © 2017 dev. All rights reserved.
//

import UIKit

class LelfMenuViewCell: UITableViewCell {
    
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var cellImage: UIImageView!
    
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
