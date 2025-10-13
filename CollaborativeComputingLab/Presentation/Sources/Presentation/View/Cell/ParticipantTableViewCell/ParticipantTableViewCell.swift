//
//  ParticipantTableViewCell.swift
//  Presentation
//
//  Created by 김호성 on 2025.07.10.
//

import Domain

import UIKit

final class ParticipantTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(name: String, description: String) {
        nameLabel.text = name
        descriptionLabel.text = description
    }
}
