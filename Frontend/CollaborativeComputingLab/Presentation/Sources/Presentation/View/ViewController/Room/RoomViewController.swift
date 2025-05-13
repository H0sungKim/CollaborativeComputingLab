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
import HaishinKit
import AVFoundation
//import ReplayKit

public class RoomViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var pdfOpenButton: UIButton!
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var pdfDrawButton: UIButton!
    private let canvasProvider: CanvasProvider = CanvasProvider()
    
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var chatTextField: UITextField!
    @IBOutlet weak var chatButton: UIButton!
    
    @IBOutlet weak var streamView: MTHKView!
    @IBOutlet weak var cameraView: MTHKView!
    @IBOutlet weak var cameraRatio: NSLayoutConstraint!
    
    private var chatTableViewDelegate: TableViewDelegate?
    private var chatTableViewDataSource: TableViewDataSource?
    
    private var id: String!
    private var role: RoomRole!
    private var chatViewModel: ChatViewModel!
    private var streamViewModel: StreamViewModel!
    
    @ScreenActor private var videoScreenObject = VideoTrackScreenObject()
    private let audioPlayer = AudioPlayer(audioEngine: AVAudioEngine())
    private lazy var audioCapture: AudioCapture = {
        let audioCapture = AudioCapture()
        audioCapture.delegate = self
        return audioCapture
    }()
    
    private var cancellable: Set<AnyCancellable> = Set<AnyCancellable>()
    
    public func inject(id: String!, role: RoomRole, chatViewModel: ChatViewModel, streamViewModel: StreamViewModel) {
        self.id = id
        self.role = role
        self.chatViewModel = chatViewModel
        self.streamViewModel = streamViewModel
    }
    
    private func bind(chatViewModel: ChatViewModel) {
        chatViewModel.chats.sink(receiveValue: { [weak self] chats in
            Task { @MainActor in
                self?.chatTableView.reloadData()
            }
        })
        .store(in: &cancellable)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        bind(chatViewModel: chatViewModel)
        configureChatTableView()
        titleLabel.text = "\(id ?? "") 님의 회의실"
        pdfView.displayMode = .singlePageContinuous
        pdfView.pageOverlayViewProvider = canvasProvider
        pdfView.isInMarkupMode = true
        pdfView.isScrollEnabled = true
        
        pdfView.isHidden = role.isPDFHidden
        pdfDrawButton.isHidden = role.isPDFHidden
        pdfOpenButton.isHidden = role.isPDFHidden
        
        switch role {
        case .instructor:
            Task {
                // If you want to use the multi-camera feature, please make create a MediaMixer with a multiCamSession mode.
                // let mixer = MediaMixer(multiCamSessionEnabled: true)
                if let orientation = DeviceUtil.videoOrientation(by: UIApplication.shared.statusBarOrientation) {
                    await streamViewModel.mixer.setVideoOrientation(orientation)
                }
                await streamViewModel.mixer.setMonitoringEnabled(DeviceUtil.isHeadphoneConnected())
                var videoMixerSettings = await streamViewModel.mixer.videoMixerSettings
                videoMixerSettings.mode = .offscreen
                await streamViewModel.mixer.setVideoMixerSettings(videoMixerSettings)
                await streamViewModel.addOutputStreamToMixer()
                await streamViewModel.addOutputView(cameraView)
            }

            Task { @ScreenActor in
                videoScreenObject.cornerRadius = 16.0
                videoScreenObject.track = 1
                videoScreenObject.horizontalAlignment = .right
                videoScreenObject.layoutMargin = .init(top: 16, left: 0, bottom: 0, right: 16)
                videoScreenObject.size = .init(width: 160 * 2, height: 90 * 2)
                if await UIDevice.current.orientation.isLandscape {
                    await streamViewModel.mixer.screen.size = .init(width: 1280, height: 720)
                } else {
                    await streamViewModel.mixer.screen.size = .init(width: 720, height: 1280)
                }
                await streamViewModel.mixer.screen.backgroundColor = UIColor.clear.cgColor
                try? await streamViewModel.mixer.screen.addChild(videoScreenObject)
            }
        case .student:
            Task {
                await streamViewModel.addOutputView(streamView)
                await streamViewModel.attachAudioPlayer(audioPlayer: audioPlayer)
            }
        case .none:
            break
        }
        
        
        
//        let recorder = RPScreenRecorder.shared()
//        recorder.isMicrophoneEnabled = true
//        recorder.isCameraEnabled = true
//        recorder.startCapture(handler: { buffer, bufferType, error in
//            print(bufferType)
//            print(error?.localizedDescription)
//            Task { await self.streamViewModel.mixer.append(buffer, track: 0) }
//        }, completionHandler: { error in
//            print(error?.localizedDescription)
//        })
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        chatViewModel.connectWebSocket()
        
        switch role {
        case .instructor:
            Task {
                try? await streamViewModel.mixer.attachAudio(AVCaptureDevice.default(for: .audio))
                let front = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
                try? await streamViewModel.mixer.attachVideo(front, track: 0) { videoUnit in
                    videoUnit.isVideoMirrored = true
                }
                await streamViewModel.mixer.startRunning()
                await streamViewModel.open(method: role.streamRole)
            }
            NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(didRouteChangeNotification(_:)), name: AVAudioSession.routeChangeNotification, object: nil)
        case .student:
            Task {
                await streamViewModel.open(method: role.streamRole)
            }
        case .none:
            break
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        chatViewModel.disconnectWebSocket()
        switch role {
        case .instructor:
            Task {
                await streamViewModel.close()
                await streamViewModel.mixer.stopRunning()
                try? await streamViewModel.mixer.attachAudio(nil)
                try? await streamViewModel.mixer.attachVideo(nil, track: 0)
                try? await streamViewModel.mixer.attachVideo(nil, track: 1)
                await streamViewModel.close()
            }
            NotificationCenter.default.removeObserver(self)
        case .student:
            Task {
                await streamViewModel.close()
            }
        case .none:
            break
        }
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        Task { @ScreenActor in
            if await UIDevice.current.orientation.isLandscape {
                await streamViewModel.mixer.screen.size = .init(width: 1280, height: 720)
            } else {
                await streamViewModel.mixer.screen.size = .init(width: 720, height: 1280)
            }
        }
    }
    
    private func configureChatTableView() {
        chatTableViewDelegate = TableViewDelegate()
        chatTableViewDataSource = TableViewDataSource(numberOfRowsInSection: chatTableViewNumberOfRowsInSection(_:numberOfRowsInSection:), cellForRowAt: chatTableView(_:cellForRowAt:))
        
        chatTableView.delegate = chatTableViewDelegate
        chatTableView.dataSource = chatTableViewDataSource
        
        chatTableView.register(UINib(nibName: String(describing: ChatTableViewCell.self), bundle: Bundle.presentation), forCellReuseIdentifier: String(describing: ChatTableViewCell.self))
    }
    
    private func chatTableViewNumberOfRowsInSection(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatViewModel.chats.value.count
    }
    
    private func chatTableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ChatTableViewCell = ChatTableViewCell.create(tableView: tableView, indexPath: indexPath)
        cell.senderLabel.text = chatViewModel.chats.value[indexPath.row].sender
        cell.messageLabel.text = chatViewModel.chats.value[indexPath.row].message
        return cell
    }
    @IBAction func onClickFile(_ sender: Any) {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf], asCopy: true)
        documentPicker.delegate = self
        present(documentPicker, animated: true)
    }
    @IBAction func onClickChatSend(_ sender: Any) {
        chatViewModel.sendChat(sender: id, message: chatTextField.text ?? "")
        chatTextField.text = ""
    }
    
    @IBAction func onClickCanvas(_ sender: UIButton) {
        pdfView.isScrollEnabled?.toggle()
        sender.setImage(UIImage(systemName: pdfView.isScrollEnabled ?? true ? "pencil.tip.crop.circle" : "pencil.tip.crop.circle.fill"), for: .normal)
    }
    
    
    @IBAction func onClickBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didRouteChangeNotification(_ notification: Notification) {
        if AVAudioSession.sharedInstance().inputDataSources?.isEmpty == true {
            setEnabledPreferredInputBuiltInMic(false)
        } else {
            setEnabledPreferredInputBuiltInMic(true)
        }
        Task {
            if DeviceUtil.isHeadphoneDisconnected(notification) {
                await streamViewModel.mixer.setMonitoringEnabled(false)
            } else {
                await streamViewModel.mixer.setMonitoringEnabled(DeviceUtil.isHeadphoneConnected())
            }
        }
    }
    
    @objc private func orientationDidChange(_ notification: Notification) {
        guard let orientation = DeviceUtil.videoOrientation(by: UIApplication.shared.statusBarOrientation) else {
            return
        }
        Task {
            await streamViewModel.mixer.setVideoOrientation(orientation)
        }
    }
    
    private func setEnabledPreferredInputBuiltInMic(_ isEnabled: Bool) {
        let session = AVAudioSession.sharedInstance()
        do {
            if isEnabled {
                guard
                    let availableInputs = session.availableInputs,
                    let builtInMicInput = availableInputs.first(where: { $0.portType == .builtInMic }) else {
                    return
                }
                try session.setPreferredInput(builtInMicInput)
            } else {
                try session.setPreferredInput(nil)
            }
        } catch {
        }
    }
}

extension RoomViewController: UIDocumentPickerDelegate {
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        pdfView.document = PDFDocument(url: urls.first!)
    }
}

extension RoomViewController: AudioCaptureDelegate {
    // MARK: AudioCaptureDelegate
    nonisolated func audioCapture(_ audioCapture: AudioCapture, buffer: AVAudioBuffer, time: AVAudioTime) {
        Task { await streamViewModel.mixer.append(buffer, when: time) }
    }
}
