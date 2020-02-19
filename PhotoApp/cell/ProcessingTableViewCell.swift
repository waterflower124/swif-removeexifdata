//
//  ProcessingTableViewCell.swift
//  PhotoApp
//
//  Created by wflower on 08/02/2020.
//  Copyright © 2020 waterflower. All rights reserved.
//

import UIKit

class ProcessingTableViewCell: UITableViewCell {

    @IBOutlet weak var processImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
