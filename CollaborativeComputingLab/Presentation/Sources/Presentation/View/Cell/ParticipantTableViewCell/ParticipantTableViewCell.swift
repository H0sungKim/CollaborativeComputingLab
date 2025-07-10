//
//  ParticipantTableViewCell.swift
//  Presentation
//
//  Created by 김호성 on 2025.07.10.
//

import Domain

import UIKit

class ParticipantTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(participantEntity: ParticipantEntity) {
        nameLabel.text = participantEntity.name
    }
}
