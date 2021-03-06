//
//  ChatRightBaseCell.swift
//  Yep
//
//  Created by NIX on 15/6/4.
//  Copyright (c) 2015年 Catch Inc. All rights reserved.
//

import UIKit

let sendingAnimationName = "RotationOnStateAnimation"

class ChatRightBaseCell: ChatBaseCell {
    
    lazy var dotImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 15, y: 0, width: 26, height: 26)
        imageView.image = UIImage(named: "icon_dot_sending")
        imageView.contentMode = .Center
        return imageView
    }()
    
    override var inGroup: Bool {
        willSet {
            dotImageView.hidden = newValue ? true : false
        }
    }
    
    var messageSendState: MessageSendState = .NotSend {
        didSet {
            switch messageSendState {

            case MessageSendState.NotSend:
                dotImageView.image = UIImage(named: "icon_dot_sending")
                dotImageView.hidden = false
                
                delay(0.1) { [weak self] in
                    if let messageSendState = self?.messageSendState where messageSendState == .NotSend {
                        self?.showSendingAnimation()
                    }
                }

            case MessageSendState.Successed:
                dotImageView.image = UIImage(named: "icon_dot_unread")
                dotImageView.hidden = false

                removeSendingAnimation()

            case MessageSendState.Read:
                dotImageView.hidden = true

                removeSendingAnimation()

            case MessageSendState.Failed:
                dotImageView.image = UIImage(named: "icon_dot_failed")
                dotImageView.hidden = false

                removeSendingAnimation()
            }
        }
    }

    var message: Message? {
        didSet {
            tryUpdateMessageState()
        }
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(dotImageView)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatRightBaseCell.tryUpdateMessageState), name: MessageNotification.MessageStateChanged, object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func tryUpdateMessageState() {

        guard !inGroup else {
            return
        }

        if let message = message {
            if !message.invalidated {
                if let messageSendState = MessageSendState(rawValue: message.sendState) {
                    self.messageSendState = messageSendState
                }
            }
        }
    }

    func showSendingAnimation() {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0.0
        animation.toValue = 2 * M_PI
        animation.duration = 1.0
        animation.repeatCount = MAXFLOAT
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            self?.dotImageView.layer.addAnimation(animation, forKey: sendingAnimationName)
        }
    }

    func removeSendingAnimation() {
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            self?.dotImageView.layer.removeAnimationForKey(sendingAnimationName)
        }
    }
}
