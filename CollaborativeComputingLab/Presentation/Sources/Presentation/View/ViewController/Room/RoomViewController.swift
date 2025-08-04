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
    
    @IBOutlet weak var publishView: UIView!
    
    @IBOutlet weak var cameraButton: UIButton!
    
    @IBOutlet weak var pdfOpenButton: UIButton!
    @IBOutlet weak var pdfView: PDFView!
    
    @IBOutlet weak var participantButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    
    @IBOutlet weak var drawButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var undoButton: UIButton!
    
    @IBOutlet weak var participantTableView: UITableView!
    
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var chatTextField: UITextField!
    @IBOutlet weak var chatSendButton: UIButton!
    
    @IBOutlet weak var streamView: MTHKView!
    @IBOutlet weak var whiteboardView: CanvasView!
    @IBOutlet weak var cameraPreviewView: CameraPreviewView!
    
    @IBOutlet weak var grabberSlider: UISlider!
    
    @IBOutlet weak var participantView: UIView!
    @IBOutlet weak var chatView: UIView!
    
    private var instructor: String = ""
    
    @IBOutlet weak var pdfWhiteboardRatio: NSLayoutConstraint!
    
    // MARK: - ChatTableView
    private var chatTableViewDelegate: TableViewDelegate?
    private var chatTableViewDataSource: UITableViewDiffableDataSource<ChatTableViewSection, ChatTableViewItem>?
    
    // MARK: - ParticipantTableView
    private var participantTableViewDelegate: TableViewDelegate?
    private var participantTableViewDataSource: UITableViewDiffableDataSource<ParticipateTableViewSection, ParticipateTableViewItem>?
    
    // MARK: - PDF
    private let canvasProvider: CanvasProvider = CanvasProvider()
    
    // MARK: - Dependency
    private var id: String!
    private var userName: String!
    private var role: RoomRole!
    private var roomViewModel: RoomViewModel!
    private var chatViewModel: ChatViewModel!
    private var streamViewModel: StreamViewModel!
    
    // MARK: - Combine
    private var cancellable: Set<AnyCancellable> = Set<AnyCancellable>()
    
    // MARK: - Inject
    public func inject(
        id: String,
        userName: String,
        role: RoomRole,
        roomViewModel: RoomViewModel,
        chatViewModel: ChatViewModel,
        streamViewModel: StreamViewModel
    ) {
        self.id = id
        self.userName = userName
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
            guard let self else { return }
            instructor = roomViewModel.participants.value.first?.name ?? ""
            titleLabel.text = "\(instructor) 님의 강의실"
            
            var snapshot = NSDiffableDataSourceSnapshot<ParticipateTableViewSection, ParticipateTableViewItem>()
            snapshot.appendSections([.participant])
            snapshot.appendItems(participants.map({ ParticipateTableViewItem.participant($0) }), toSection: .participant)
            participantTableViewDataSource?.apply(snapshot, animatingDifferences: true)
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
        
        cameraPreviewView.previewLayer.cornerRadius = 8
        
        grabberSlider.setThumbImage(UIImage(systemName: "poweron", withConfiguration: UIImage.SymbolConfiguration(pointSize: 64))?.withTintColor(.clear, renderingMode: .alwaysOriginal), for: .normal)
        grabberSlider.setThumbImage(UIImage(systemName: "poweron", withConfiguration: UIImage.SymbolConfiguration(pointSize: 64))?.withTintColor(.clear, renderingMode: .alwaysOriginal), for: .highlighted)
        
        pdfView.layer.cornerRadius = 8
        whiteboardView.layer.cornerRadius = 8
        
        titleLabel.text = "\(roomViewModel.participants.value.first?.name ?? "") 님의 강의실"
        
        participantButton.setImage(UIImage(systemName: "person.2.fill"), for: .selected)
        participantButton.setImage(UIImage(systemName: "person.2"), for: .normal)
        
        chatButton.setImage(UIImage(systemName: "ellipses.bubble.fill"), for: .selected)
        chatButton.setImage(UIImage(systemName: "ellipses.bubble"), for: .normal)
        
        drawButton.setImage(UIImage(systemName: "pencil.tip.crop.circle.fill"), for: .selected)
        drawButton.setImage(UIImage(systemName: "pencil.tip.crop.circle"), for: .normal)
        
        cameraButton.setImage(UIImage(systemName: "camera.fill"), for: .selected)
        cameraButton.setImage(UIImage(systemName: "camera"), for: .normal)
        
        switch role {
        case .instructor:
            configurePDFView()
            cameraPreviewView.configure()
            if #available(iOS 17, *) {
                cameraPreviewView.rotate(orientation: UIDevice.current.orientation)
            }
            cameraButton.isSelected = true
            Task {
                await streamViewModel.configure(roomRole: role, outputView: nil)
            }
        case .student:
            publishView.isHidden = true
            Task {
                await streamViewModel.configure(roomRole: role, outputView: streamView)
            }
        case .none:
            break
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        chatViewModel.connectWebSocket()
        roomViewModel.connectWebSocket()
        
        switch role {
        case .instructor:
            cameraPreviewView.start()
            Task {
                await streamViewModel.publish(streamName: id, view: streamView, video: nil, audio: AVCaptureDevice.default(for: .audio))
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
        cameraPreviewView.stop()
        
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
        
        if #available(iOS 17, *) {
            cameraPreviewView.rotate(orientation: UIDevice.current.orientation)
        }
    }
    
    // MARK: - PDFView
    private func configurePDFView() {
        pdfView.displayMode = .singlePageContinuous
        pdfView.pageOverlayViewProvider = canvasProvider
        pdfView.isInMarkupMode = true
        pdfView.isScrollEnabled = true
        canvasProvider.setUserInteractionEnabled(false)
    }
    
    // MARK: - IBAction
    @IBAction func onClickParticipant(_ sender: UIButton) {
        sender.isSelected.toggle()
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.participantView.isHidden = !sender.isSelected
        })
    }
    
    @IBAction func onClickChat(_ sender: UIButton) {
        sender.isSelected.toggle()
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.chatView.isHidden = !sender.isSelected
        })
    }
    
    @IBAction func onClickCamera(_ sender: UIButton) {
        sender.isSelected.toggle()
        cameraPreviewView.isHidden.toggle()
    }
    
    @IBAction func onClickFile(_ sender: Any) {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf], asCopy: true)
        documentPicker.delegate = self
        present(documentPicker, animated: true)
    }
    
    @IBAction func onClickSendChat(_ sender: Any) {
        chatViewModel.sendChat(message: chatTextField.text ?? "")
        chatTextField.text = ""
    }
    
    @IBAction func onClickDraw(_ sender: UIButton) {
        sender.isSelected.toggle()
        pdfView.isScrollEnabled = !sender.isSelected
        canvasProvider.setUserInteractionEnabled(sender.isSelected)
    }
    
    @IBAction func onClickBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickClear(_ sender: Any) {
        whiteboardView.clear()
    }
    
    @IBAction func onClickUndo(_ sender: Any) {
        whiteboardView.undo()
    }
    
    @IBAction func grabberMoved(_ sender: UISlider) {
        Log.i(sender.value)
        
        let value = min(0.9, max(0.1, sender.value))
        sender.value = value
        
        pdfWhiteboardRatio = pdfWhiteboardRatio.setMultiplier(multiplier: CGFloat(value / (1 - value)))
        
        whiteboardView.setNeedsDisplay()
    }
    
    // MARK: - RoomClosed
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
        chatTableViewDataSource = UITableViewDiffableDataSource<ChatTableViewSection, ChatTableViewItem>(tableView: chatTableView, cellProvider: { [weak self] tableView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .chat(let chatEntity):
                let cell: ChatTableViewCell = ChatTableViewCell.create(tableView: tableView, indexPath: indexPath)
                var description = ""
                if chatEntity.name == self?.instructor {
                    description = "강사"
                }
                if chatEntity.name == self?.userName {
                    description = "나"
                }
                cell.configure(sender: chatEntity.name, description: description, message: chatEntity.message)
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
        participantTableViewDataSource = UITableViewDiffableDataSource<ParticipateTableViewSection, ParticipateTableViewItem>(tableView: participantTableView, cellProvider: { [weak self] tableView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .participant(let participantEntity):
                let cell: ParticipantTableViewCell = ParticipantTableViewCell.create(tableView: tableView, indexPath: indexPath)
                var description = ""
                if participantEntity.name == self?.instructor {
                    description = "강사"
                }
                if participantEntity.name == self?.userName {
                    description = "나"
                }
                cell.configure(name: participantEntity.name, description: description)
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
