//
//  CurrentTableViewCell.swift
//  TV Guide
//
//  Created by Luca Klingenberg on 18.11.17.
//  Copyright © 2017 Technische Universität München. All rights reserved.
//

import UIKit

class CurrentTableViewCell: UITableViewCell {
    @IBOutlet weak var tvShowImageView: UIImageView!
    @IBOutlet weak var tvShowTitleLabel: UILabel!
    @IBOutlet weak var tvShowTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
