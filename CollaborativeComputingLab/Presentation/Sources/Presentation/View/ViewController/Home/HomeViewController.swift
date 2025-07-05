//
//  HomeViewController.swift
//  Presentation
//
//  Created by 김호성 on 2025.04.28.
//

import Domain

import Combine
import UIKit

public class HomeViewController: UIViewController {
    
    @IBOutlet weak var roomTableView: UITableView!
    
    private var roomTableViewDataSource: UITableViewDiffableDataSource<Section, Item>!
    
    private var roomViewModel: RoomViewModel!
    
    private var cancellable: Set<AnyCancellable> = Set<AnyCancellable>()
    
    public func inject(roomViewModel: RoomViewModel) {
        self.roomViewModel = roomViewModel
    }
    
    private func bind() {
        roomViewModel.availableRooms.sink(receiveValue: { [weak self] roomEnities in
            guard let self else { return }
            Logger.log("Available Rooms: \(roomEnities)")
            var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
            snapshot.appendSections([.availableRooms])
            snapshot.appendItems(roomEnities.map({ Item.room($0) }), toSection: .availableRooms)
            roomTableViewDataSource.apply(snapshot)
        })
        .store(in: &cancellable)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureRoomTableView()
        bind()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        roomViewModel.connectWebSocket()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        
    }
    private func configureRoomTableView() {
        roomTableView.register(UINib(nibName: String(describing: RoomTableViewCell.self), bundle: Bundle.presentation), forCellReuseIdentifier: String(describing: RoomTableViewCell.self))
        
        roomTableView.delegate = self
        roomTableViewDataSource = UITableViewDiffableDataSource<Section, Item>(tableView: roomTableView, cellProvider: { tableView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .room(let roomEntity):
                let cell: RoomTableViewCell = RoomTableViewCell.create(tableView: tableView, indexPath: indexPath)
                cell.configure(roomEntity: roomEntity)
                return cell
            }
        })
        roomTableView.dataSource = roomTableViewDataSource
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.availableRooms])
        roomTableViewDataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    @IBAction func onClickCreateRoom(_ sender: Any) {
        presentCreateRoomAlert()
    }
    
    private func presentCreateRoomAlert() {
        let alert: UIAlertController = UIAlertController(title: "강의실을 생성합니다.", message: "이름을 입력하시오.", preferredStyle: .alert)
        let actionCancel: UIAlertAction = UIAlertAction(title: "취소", style: .default, handler: { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        })
        let actionCreate: UIAlertAction = UIAlertAction(title: "생성", style: .default, handler: { [weak self] _ in
            let id: String = UUID().uuidString
            self?.roomViewModel.enterRoom(id: id, userName: alert.textFields?.first?.text ?? "")
            guard let viewControllerFactory = (self?.navigationController as? DINavigationController)?.viewControllerFactory else { return }
            let roomViewController = viewControllerFactory.createRoomViewController(id: id, role: .instructor, roomViewModel: self?.roomViewModel, chatViewModel: nil, streamViewModel: nil)
            Logger.log(self?.roomViewModel.participants.value)
            self?.navigationController?.pushViewController(roomViewController, animated: true)
            self?.dismiss(animated: true, completion: nil)
        })
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "홍길동"
        })
        alert.addAction(actionCancel)
        alert.addAction(actionCreate)
        present(alert, animated: true, completion: nil)
    }
}

extension HomeViewController: UITableViewDelegate {
    
    private enum Section: Int {
        case availableRooms
    }
    
    private enum Item: Hashable, Sendable {
        case room(RoomEntity)
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presentEnterRoomAlert(roomEntity: roomViewModel.availableRooms.value[indexPath.row])
    }
    
    private func presentEnterRoomAlert(roomEntity: RoomEntity) {
        let alert: UIAlertController = UIAlertController(title: "\(roomEntity.participants.first ?? "알수없음")님의 강의실에 입장합니다.", message: "이름을 입력하시오.", preferredStyle: .alert)
        let actionCancel: UIAlertAction = UIAlertAction(title: "취소", style: .default, handler: { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        })
        let actionEnter: UIAlertAction = UIAlertAction(title: "입장", style: .default, handler: { [weak self] _ in
            self?.roomViewModel.enterRoom(id: roomEntity.id, userName: alert.textFields?.first?.text ?? "")
            guard let viewControllerFactory = (self?.navigationController as? DINavigationController)?.viewControllerFactory else { return }
            let roomViewController = viewControllerFactory.createRoomViewController(id: roomEntity.id, role: .student, roomViewModel: self?.roomViewModel, chatViewModel: nil, streamViewModel: nil)
            Logger.log(self?.roomViewModel.participants.value)
            self?.navigationController?.pushViewController(roomViewController, animated: true)
            self?.dismiss(animated: true, completion: nil)
        })
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "홍길동"
        })
        alert.addAction(actionCancel)
        alert.addAction(actionEnter)
        present(alert, animated: true, completion: nil)
    }
}
