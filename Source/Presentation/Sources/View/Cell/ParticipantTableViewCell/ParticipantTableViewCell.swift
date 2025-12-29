//
//  ParticipantTableViewCell.swift
//  Presentation
//
//  Created by 김호성 on 2025.07.10.
//

import UIKit

import Domain

final class ParticipantTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func configure(name: String, description: String) {
        nameLabel.text = name
        descriptionLabel.text = description
    }
}
