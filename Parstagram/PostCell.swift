//
//  PostCell.swift
//  Parstagram
//
//  Created by ALBERT TADROS on 3/26/22.
//

import UIKit

class PostCell: UITableViewCell {
    
    @IBOutlet weak var postPhotoView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
