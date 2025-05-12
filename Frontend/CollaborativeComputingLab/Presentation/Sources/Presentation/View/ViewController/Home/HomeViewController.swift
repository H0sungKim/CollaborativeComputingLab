//
//  HomeViewController.swift
//  Presentation
//
//  Created by 김호성 on 2025.04.28.
//

import UIKit

public class HomeViewController: UIViewController {
    
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var roleSegmentedControl: UISegmentedControl!
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onClickEnter(_ sender: Any) {
        guard let viewControllerFactory = (navigationController as? DINavigationController)?.viewControllerFactory else { return }
        let roomViewController = viewControllerFactory.createRoomViewController(id: idTextField.text ?? "", role: RoomRole(rawValue: roleSegmentedControl.selectedSegmentIndex) ?? .student, chatViewModel: nil, streamViewModel: nil)
        navigationController?.pushViewController(roomViewController, animated: true)
    }
    
}
