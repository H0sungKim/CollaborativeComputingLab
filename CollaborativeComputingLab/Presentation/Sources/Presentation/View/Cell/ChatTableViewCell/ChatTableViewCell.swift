//
//  ChatTableViewCell.swift
//  Presentation
//
//  Created by 김호성 on 2025.04.27.
//

import Domain

import UIKit

final class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak var senderLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        Task { @MainActor in
            selectionStyle = .none
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func configure(sender: String, description: String, message: String) {
        senderLabel.text = sender
        descriptionLabel.text = description
        messageLabel.text = message
    }
}
