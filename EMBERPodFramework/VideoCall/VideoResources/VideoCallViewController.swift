//
//  VideoCallViewController.swift
//  OsirisBio Provider
//
//  Created by Pramod More on 8/29/18.
//  Copyright © 2018 Biz4Solutions. All rights reserved.
//

import UIKit
import OpenTok
import RxSwift
import NotificationBannerSwift
import RxCocoa

// *** Fill the following variables using your own Project info  ***
// ***            https://tokbox.com/account/#/                  ***
// Replace with your OpenTok API key

let kWidgetHeight = 240
let kWidgetWidth = 320

class VideoCallViewController: UIViewController {
    
    var kApiKey = "46306432"//EnvironmentConfiguration.sharedInstance.OpenTokAPIKey
    
    // Replace with your generated session ID
    var kSessionId = ""
    // Replace with your generated token
    var kToken = ""
    
    var videoTitle = "" {
        didSet {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                AnimationUtility.setLabelTextWithAnimation(label: self.titleLabel, text: self.videoTitle)
            }
        }
    }
    var videoSubTitle = "" {
        didSet {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                AnimationUtility.setLabelTextWithAnimation(label: self.subtitleLabel, text: self.videoSubTitle)
            }
        }
    }
    
    var seconds = 0
    var callTimer: Timer! = Timer()
    
    lazy var session: OTSession = {
        return OTSession(apiKey: kApiKey, sessionId: kSessionId, delegate: self)!
    }()
    
    lazy var publisher: OTPublisher = {
        let settings = OTPublisherSettings()
        settings.name = UIDevice.current.name
        return OTPublisher(delegate: self, settings: settings)!
    }()
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var audioToggleButton: UIButton!
    @IBOutlet weak var cameraSwitchToggleButton: UIButton!
    @IBOutlet weak var videoToggleButton: UIButton!
    @IBOutlet weak var receiverView: UIView!
    @IBOutlet weak var senderView: UIView!
    @IBOutlet weak var endVideoCallButton: UIButton!
    @IBOutlet weak var subsCriberLoader: UIActivityIndicatorView!
    
    @IBOutlet weak var publisherLoader: UIActivityIndicatorView!
    
    @IBOutlet weak var timerButton: UIButton!
    @IBOutlet weak var videoAudioPausedLabel: UILabel!
    
    var subscriber: OTSubscriber?
    var otSessionError: OTError?
    var otPublisherError: OTError?
    var otSubscriberError: OTError?
    var streamStartTime: Int64?
    var connectionStartTime: Int64?
    var extensionCount: Int = 0
    var selectedServiceType: RequestType?
    var viewIsKilled: Bool = false
    var currentCameraPosition: AVCaptureDevice.Position = .front
    let disposeBag = DisposeBag()
    
    // MARK: View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
        doConnect()
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //        if self.callTimer != nil{
        //            self.callTimer.invalidate()
        //             self.callTimer = nil
        //        }
        //        UIApplication.shared.isIdleTimerDisabled = true
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //        if self.isBeingDismissed || self.isMovingFromParent {
        //            if timerActionSheetViewController?.isModal ?? false {
        //                   self.dismiss(animated: true, completion: nil)
        //               }
        //        }
    }
    
    // MARK: Initial Setup
    func initialSetup() {
        timerLabel.text = ""
        timerLabel.isUserInteractionEnabled = true
        
        titleLabel.text = self.videoTitle
        subtitleLabel.text = self.videoSubTitle
        
        subsCriberLoader.startAnimating()
        publisherLoader.startAnimating()
        
        self.publisher.publishVideo = false
        videoAudioPausedLabel.isHidden = false
        videoAudioPausedLabel.text = "video.paused".localized
        initializeButtonClicks()
        
//        if let serviceType = RequestType.init(string: UserDefaultsConstant.serviceType.getValue() as? String ?? "") {
//        }
    }
    
    // MARK: Timer
        
    func runTimer() {
        
        self.timerButton.isHidden = false
        
        if callTimer != nil {
            callTimer.invalidate()
            callTimer = nil
        }
        timerLabel.textColor = .white
        callTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (_) in
            if self.callTimer != nil {
                self.updateTimer()
            }
        })   // Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(self.updateTimer)), userInfo: nil, repeats: true)
    }
    
    func timeString(time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        
        var timeString = ""
        
        if hours == 0 {
            timeString = String(format: "%02d:%02d", minutes, seconds)
        } else {
            timeString = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
        return timeString
    }
    
    @objc func updateTimer() {
        seconds -= 1     // This will decrement(count down)the seconds.
        if seconds == 120 {
            
            DispatchQueue.main.async {
                
//                UIApplication.topViewController()?.dismiss(animated: false, completion: nil)
                
                let alert = UIAlertController(title: nil, message: NSLocalizedString("your.call.is.about.to.end", comment: ""), preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: { (_: UIAlertAction!) in
                }))
                
//                UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
            }
        }
        
        if seconds < 120 {
            timerLabel.textColor = timerLabel.textColor == .red ? .white : .red
        }
        
        if seconds < 10 {
                        
            timerLabel.isUserInteractionEnabled = false
            timerButton.isEnabled = false
        }
        
        if seconds <= 0 {
            DispatchQueue.main.async {
                let banner = GrowingNotificationBanner(title: NSLocalizedString("your.time.is.up", comment: ""), subtitle: NSLocalizedString("session.will.be.closed", comment: ""), style: .warning )
                banner.show()
            }
            callTimer.invalidate()
            callTimer = nil
        }
        timerLabel.text = timeString(time: TimeInterval(seconds)).localizingTheNumbers()
    }
        
    // MARK: OpenTok Methods
    /**
     * Asynchronously begins the session connect process. Some time later, we will
     * expect a delegate method to call us back with the results of this action.
     */
    
    fileprivate func doConnect() {
        var error: OTError?
        defer {
            processError(error)
        }
        
        session.connect(withToken: kToken, error: &error)
    }
    
    /**
     * Sets up an instance of OTPublisher to use with this session. OTPubilsher
     * binds to the device camera and microphone, and will provide A/V streams
     * to the OpenTok session.
     */
    fileprivate func doPublish() {
        var error: OTError?
        defer {
            processError(error)
        }
        
        session.publish(publisher, error: &error)
        
        if let pubView = publisher.view {
            pubView.frame = CGRect(x: 0, y: 0, width: kWidgetWidth, height: kWidgetHeight)
            
            UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.senderView.addSubview(pubView)
                pubView.frame = self.senderView.bounds
            }, completion: { (_) in
                
            })
            DispatchQueue.main.async {
                self.publisherLoader.stopAnimating()
            }
            publisherLoader.isHidden = true
        }
    }
    
    /**
     * Instantiates a subscriber for the given stream and asynchronously begins the
     * process to begin receiving A/V content for this stream. Unlike doPublish,
     * this method does not add the subscriber to the view hierarchy. Instead, we
     * add the subscriber only after it has connected and begins receiving data.
     */
    fileprivate func doSubscribe(_ stream: OTStream) {
        var error: OTError?
        defer {
            processError(error)
        }
        subscriber = OTSubscriber(stream: stream, delegate: self)
        
        if let sub = subscriber {
            session.subscribe(sub, error: &error)
        }
    }
    
    fileprivate func cleanupSubscriber() {
        subscriber?.view?.removeFromSuperview()
        subscriber = nil
    }
    
    fileprivate func cleanupPublisher() {
        publisher.view?.removeFromSuperview()
    }
    
    fileprivate func processError(_ error: OTError?) {
        if let err = error {
            DispatchQueue.main.async {
                let controller = UIAlertController(title: "error", message: err.localizedDescription, preferredStyle: .alert)
                controller.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
}

// MARK: - OTSession delegate callbacks
extension VideoCallViewController: OTSessionDelegate {
    
    func sessionDidConnect(_ session: OTSession) {
        print("Session connected")
        self.connectionStartTime = session.connection?.creationTime.millisecondsSince1970
                
        if !viewIsKilled {
            doPublish()
        }
    }
    
    func sessionDidDisconnect(_ session: OTSession) {
        print("Session disconnected")
        if !viewIsKilled {
            doConnect()
        }
    }
    
    func session(_ session: OTSession, streamCreated stream: OTStream) {
        print("Session streamCreated: \(stream.streamId)")
        
        if subscriber == nil && !viewIsKilled {
            publisherLoader.startAnimating()
            publisherLoader.isHidden = false
            doSubscribe(stream)
        }
    }
    
    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        print("Session streamDestroyed: \(stream.streamId)")
        
        //        if let _ = callTimer {
        //            self.callTimer.invalidate()
        //        }
        
        if let subStream = subscriber?.stream, subStream.streamId == stream.streamId {
            cleanupSubscriber()
        }
    }
    
    func session(_ session: OTSession, didFailWithError error: OTError) {
        print("session Failed to connect: \(error.localizedDescription)")
        self.otSessionError = error
    }
    
    func updateSubscriber() {
        for streamId in session.streams {
            let stream = session.streams["\(streamId)"]
            if stream?.connection.connectionId != session.connection?.connectionId {
                if let streamObject = stream {
                    subscriber = OTSubscriber(stream: streamObject, delegate: self)
                    break
                }
            }
        }
    }
    
}

// MARK: - OTPublisher delegate callbacks
extension VideoCallViewController: OTPublisherDelegate {
    func publisher(_ publisher: OTPublisherKit, streamCreated stream: OTStream) {
        
        DispatchQueue.main.async {
            self.publisherLoader.stopAnimating()
            self.publisherLoader.isHidden = true
        }
        
        print("Publishing")
    }
    
    func publisher(_ publisher: OTPublisherKit, streamDestroyed stream: OTStream) {
        cleanupPublisher()
        if let subStream = subscriber?.stream, subStream.streamId == stream.streamId {
            cleanupSubscriber()
        }
    }
    
    func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
        print("Publisher failed: \(error.localizedDescription)")
        self.otPublisherError = error
        
    }
    
    func publisher(_ publisher: OTPublisher, didChangeCameraPosition position: AVCaptureDevice.Position) {
        if position == .front {
            print("front camera")
            // currentCameraPosition = .front
        } else {
            print("back camera")
            // currentCameraPosition = .back
        }
    }
}

// MARK: - OTSubscriber delegate callbacks
extension VideoCallViewController: OTSubscriberDelegate {
    func subscriberDidConnect(toStream subscriberKit: OTSubscriberKit) {
        print("subscriberDidConnect")
        
        if let subsView = subscriber?.view {
            subsView.frame = CGRect(x: 0, y: kWidgetHeight, width: kWidgetWidth, height: kWidgetHeight)
            
            UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.receiverView.addSubview(subsView)
                subsView.frame = self.receiverView.bounds
            }, completion: { (_) in
            })
            
//            if UserDefaultsConstant.requestStartTime.getValue() == nil && (subscriberKit.stream?.creationTime != nil) {
//                UserDefaultsConstant.requestStartTime.setValue(value: subscriberKit.stream?.creationTime)
//
//                let requestEndTime = Calendar.current.date(byAdding: .second, value: self.seconds, to: subscriberKit.stream?.creationTime ?? Date())
//                print("total sec start stream")
//                print(self.seconds)
//                if let timeOffset = UserDefaultsConstant.timeOffset.getValue() as? Int, let endTime = requestEndTime {
//                    let msec = Int(endTime.millisecondsSince1970 - Date().millisecondsSince1970) - timeOffset
//                    self.seconds = msec.msToSeconds
//                }
//                UserDefaultsConstant.requestEndTime.setValue(value: requestEndTime)
//            }
            
            if subscriberKit.stream != nil {
                self.streamStartTime = subscriberKit.stream?.creationTime.millisecondsSince1970

//                self.streamStartTime = subscriberKit.stream?.creationTime.millisecondsSince1970
//                if UserDefaultsConstant.requestStreamStartTime.getValue() == nil {
//                    UserDefaultsConstant.requestStreamStartTime.setValue(value: self.streamStartTime)
//                }
            }
            
            DispatchQueue.main.async {
                if self.callTimer == nil {
                    self.runTimer()
                }
                self.subsCriberLoader.stopAnimating()
                self.subsCriberLoader.isHidden = true
            }
        }
    }
    
    func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        print("Subscriber failed: \(error.localizedDescription)")
        self.otSubscriberError = error
        
        if callTimer != nil {
            self.callTimer.invalidate()
            self.callTimer = nil
        }
    }
}

extension VideoCallViewController {
    func initializeButtonClicks() {
        
        _ = videoToggleButton.rx.tap.bind {
            
            self.publisher.publishVideo = !self.publisher.publishVideo
            
            self.videoAudioPausedLabel.isHidden = self.publisher.publishVideo
            
            if !self.publisher.publishVideo {
                self.videoAudioPausedLabel.text = "video.paused".localized
            }
            
            UIView.transition(with: self.videoToggleButton, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.videoToggleButton.isSelected = !self.videoToggleButton.isSelected
            }, completion: nil)
        }
        
        _ = audioToggleButton.rx.tap.bind {
            
            self.publisher.publishAudio = !self.publisher.publishAudio
            
            self.videoAudioPausedLabel.isHidden = self.publisher.publishAudio
            
            if !self.publisher.publishAudio {
                self.videoAudioPausedLabel.text = "mic.muted".localized
            }
            
            UIView.transition(with: self.audioToggleButton, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.audioToggleButton.isSelected = !self.audioToggleButton.isSelected
            }, completion: nil)
        }
        
        _ = cameraSwitchToggleButton.rx.tap.bind {
            if self.currentCameraPosition == .front {
                print("camera is now front and will change to back")
                self.publisher.cameraPosition = .back
                self.currentCameraPosition = .back
            } else {
                print("camera is now back and will change to front")
                self.publisher.cameraPosition = .front
                self.currentCameraPosition = .front
            }
            
            UIView.transition(with: self.cameraSwitchToggleButton, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.cameraSwitchToggleButton.isSelected = !self.cameraSwitchToggleButton.isSelected
            }, completion: nil)
        }
    }
    
}
