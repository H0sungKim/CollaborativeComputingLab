//
//  RoomViewController.swift
//  Presentation
//
//  Created by 김호성 on 2025.04.26.
//

import Domain

import UIKit
import Combine
import PDFKit
import AVFoundation

import HaishinKit

public class RoomViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var pdfOpenButton: UIButton!
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var pdfDrawButton: UIButton!
    
    @IBOutlet weak var participantTableView: UITableView!
    
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var chatTextField: UITextField!
    @IBOutlet weak var chatButton: UIButton!
    
    @IBOutlet weak var streamView: MTHKView!
    @IBOutlet weak var cameraView: MTHKView!
    
    // MARK: - ChatTableView
    private var chatTableViewDelegate: TableViewDelegate?
    private var chatTableViewDataSource: UITableViewDiffableDataSource<ChatTableViewSection, ChatTableViewItem>?
    
    private var participantTableViewDelegate: TableViewDelegate?
    private var participantTableViewDataSource: UITableViewDiffableDataSource<ParticipateTableViewSection, ParticipateTableViewItem>?
    
    // MARK: - PDF
    private let canvasProvider: CanvasProvider = CanvasProvider()
    
    // MARK: - Dependency
    private var id: String!
    private var role: RoomRole!
    private var roomViewModel: RoomViewModel!
    private var chatViewModel: ChatViewModel!
    private var streamViewModel: StreamViewModel!
    
    // MARK: - Combine
    private var cancellable: Set<AnyCancellable> = Set<AnyCancellable>()
    
    // MARK: - Inject
    public func inject(
        id: String,
        role: RoomRole,
        roomViewModel: RoomViewModel,
        chatViewModel: ChatViewModel,
        streamViewModel: StreamViewModel
    ) {
        self.id = id
        self.role = role
        self.roomViewModel = roomViewModel
        self.chatViewModel = chatViewModel
        self.streamViewModel = streamViewModel
    }
    
    // MARK: - Bind
    private func bind() {
        chatViewModel.chats.sink(receiveValue: { [weak self] chats in
            var snapshot = NSDiffableDataSourceSnapshot<ChatTableViewSection, ChatTableViewItem>()
            snapshot.appendSections([.chat])
            snapshot.appendItems(chats.map({ ChatTableViewItem.chat($0) }), toSection: .chat)
            self?.chatTableViewDataSource?.apply(snapshot, animatingDifferences: true)
        })
        .store(in: &cancellable)
        
        roomViewModel.participants.sink(receiveValue: { [weak self] participants in
            self?.titleLabel.text = "\(self?.roomViewModel.participants.value.first?.name ?? "") 님의 강의실"
            
            var snapshot = NSDiffableDataSourceSnapshot<ParticipateTableViewSection, ParticipateTableViewItem>()
            snapshot.appendSections([.participant])
            snapshot.appendItems(participants.map({ ParticipateTableViewItem.participant($0) }), toSection: .participant)
            self?.participantTableViewDataSource?.apply(snapshot, animatingDifferences: true)
        })
        .store(in: &cancellable)
        
        roomViewModel.roomClosed.sink(receiveValue: { [weak self] in
            self?.presentCloseRoomAlert()
        })
        .store(in: &cancellable)
    }
    
    // MARK: - Basic
    public override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        configureChatTableView()
        configureParticipantTableView()
        configurePDFView()
        titleLabel.text = "\(roomViewModel.participants.value.first?.name ?? "") 님의 강의실"
        
        let outputView: UIView = {
            switch role {
            case .instructor:
                return cameraView
            case .student:
                return streamView
            case .none:
                return UIView()
            }
        }()
        Task {
            await streamViewModel.configure(roomRole: role, outputView: outputView)
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        chatViewModel.connectWebSocket()
        roomViewModel.connectWebSocket()
        
        switch role {
        case .instructor:
            Task {
                await streamViewModel.publish(streamName: id, view: streamView, video: AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front), audio: AVCaptureDevice.default(for: .audio))
            }
        case .student:
            Task {
                await streamViewModel.play(streamName: id)
            }
        case .none:
            break
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        roomViewModel.exitRoom(id: id)
        
        switch role {
        case .instructor:
            Task {
                await streamViewModel.stopPublish()
            }
        case .student:
            Task {
                await streamViewModel.stopPlay()
            }
        case .none:
            break
        }
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        Task {
            await streamViewModel.setScreenSize()
        }
    }
    
    // MARK: - PDFView
    private func configurePDFView() {
        pdfView.displayMode = .singlePageContinuous
        pdfView.pageOverlayViewProvider = canvasProvider
        pdfView.isInMarkupMode = true
        pdfView.isScrollEnabled = true
        
        pdfView.isHidden = role.isPDFHidden
        pdfDrawButton.isHidden = role.isPDFHidden
        pdfOpenButton.isHidden = role.isPDFHidden
    }
    
    // MARK: - IBAction
    @IBAction func onClickFile(_ sender: Any) {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf], asCopy: true)
        documentPicker.delegate = self
        present(documentPicker, animated: true)
    }
    
    @IBAction func onClickChatSend(_ sender: Any) {
        chatViewModel.sendChat(message: chatTextField.text ?? "")
        chatTextField.text = ""
    }
    
    @IBAction func onClickCanvas(_ sender: UIButton) {
        pdfView.isScrollEnabled?.toggle()
        sender.setImage(UIImage(systemName: pdfView.isScrollEnabled ?? true ? "pencil.tip.crop.circle" : "pencil.tip.crop.circle.fill"), for: .normal)
    }
    
    @IBAction func onClickBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    private func presentCloseRoomAlert() {
        let alert: UIAlertController = UIAlertController(title: "강의실이 종료되었습니다.", message: "", preferredStyle: .alert)
        let actionClose: UIAlertAction = UIAlertAction(title: "확인", style: .default, handler: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
            self?.dismiss(animated: true, completion: nil)
        })
        alert.addAction(actionClose)
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - ChatTableView
extension RoomViewController {
    
    private enum ChatTableViewSection: Int {
        case chat
    }
    
    private enum ChatTableViewItem: Hashable, Sendable {
        case chat(ChatEntity)
    }
    
    private func configureChatTableView() {
        chatTableView.register(UINib(nibName: String(describing: ChatTableViewCell.self), bundle: Bundle.presentation), forCellReuseIdentifier: String(describing: ChatTableViewCell.self))
        
        chatTableViewDelegate = TableViewDelegate()
        chatTableViewDataSource = UITableViewDiffableDataSource<ChatTableViewSection, ChatTableViewItem>(tableView: chatTableView, cellProvider: { tableView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .chat(let chatEntity):
                let cell: ChatTableViewCell = ChatTableViewCell.create(tableView: tableView, indexPath: indexPath)
                cell.configure(chatEntity: chatEntity)
                return cell
            }
        })
        
        chatTableView.delegate = chatTableViewDelegate
        chatTableView.dataSource = chatTableViewDataSource
        
        var snapshot = NSDiffableDataSourceSnapshot<ChatTableViewSection, ChatTableViewItem>()
        snapshot.appendSections([.chat])
        snapshot.appendItems(chatViewModel.chats.value.map({ ChatTableViewItem.chat($0) }), toSection: .chat)
        chatTableViewDataSource?.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - ParticipateTableView
extension RoomViewController {
    
    private enum ParticipateTableViewSection: Int {
        case participant
    }
    
    private enum ParticipateTableViewItem: Hashable, Sendable {
        case participant(ParticipantEntity)
    }
    
    private func configureParticipantTableView() {
        participantTableView.register(UINib(nibName: String(describing: ParticipantTableViewCell.self), bundle: Bundle.presentation), forCellReuseIdentifier: String(describing: ParticipantTableViewCell.self))
        
        participantTableViewDelegate = TableViewDelegate()
        participantTableViewDataSource = UITableViewDiffableDataSource<ParticipateTableViewSection, ParticipateTableViewItem>(tableView: participantTableView, cellProvider: { tableView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .participant(let participantEntity):
                let cell: ParticipantTableViewCell = ParticipantTableViewCell.create(tableView: tableView, indexPath: indexPath)
                cell.configure(participantEntity: participantEntity)
                return cell
            }
        })
        
        participantTableView.delegate = participantTableViewDelegate
        participantTableView.dataSource = participantTableViewDataSource
        
        var snapshot = NSDiffableDataSourceSnapshot<ParticipateTableViewSection, ParticipateTableViewItem>()
        snapshot.appendSections([.participant])
        snapshot.appendItems(roomViewModel.participants.value.map({ ParticipateTableViewItem.participant($0) }), toSection: .participant)
        participantTableViewDataSource?.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - UIDocumentPickerDelegate
extension RoomViewController: UIDocumentPickerDelegate {
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        pdfView.document = PDFDocument(url: urls.first!)
    }
}
