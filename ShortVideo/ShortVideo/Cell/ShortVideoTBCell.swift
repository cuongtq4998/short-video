//
//  ShortVideoTBCell.swift
//  ShortVideo
//
//  Created by Quoc Cuong on 02/11/2022.
//

import UIKit
import AVFoundation

typealias OnPlayerReady = () -> Void

class ShortVideoTBCell: UITableViewCell {
    
    var container:UIView = UIView.init()
    var gradientLayer:CAGradientLayer = CAGradientLayer.init()
    var pauseIcon:UIImageView = UIImageView.init(image: UIImage.init(named: "icon_play_pause"))
    var playerStatusBar:UIView = UIView.init()
    var singleTapGesture:UITapGestureRecognizer?
    var lastTapTime:TimeInterval = 0
    var lastTapPoint:CGPoint = .zero
    
    var playerView:AVPlayerView = AVPlayerView.init()
    
    var onPlayerReady:OnPlayerReady?
    var isPlayerReady:Bool = false
    
    var short: ShortModel?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = ColorClear
        lastTapTime = 0
        lastTapPoint = .zero
        initSubViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isPlayerReady = false
        playerView.cancelLoading()
    }
}

extension ShortVideoTBCell {
    func initSubViews() {
        playerView.delegate = self
        contentView.addSubview(playerView)
        
        singleTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleGesture(sender:)))
        contentView.addGestureRecognizer(singleTapGesture!)
    }
    
    func initData(short: ShortModel) {
        self.short = short
        playerView.setPlayerSourceUrl(url: short.url ?? "")
    }
    
    func play() {
        playerView.play()
    }
    
    func pause() {
        playerView.pause()
    }
    
    func replay() {
        playerView.replay()
    }
}

//gesture
extension ShortVideoTBCell {
    @objc func handleGesture(sender: UITapGestureRecognizer) {
        switch sender.view?.tag {
//        case COMMENT_TAP_ACTION:
//            CommentsPopView.init(awemeId: aweme?.aweme_id ?? "").show()
//            break
//        case SHARE_TAP_ACTION:
//            SharePopView.init().show()
//            break
        default:
            //获取点击坐标，用于设置爱心显示位置
            let point = sender.location(in: contentView)
            //获取当前时间
            let time = CACurrentMediaTime()
            //判断当前点击时间与上次点击时间的时间间隔
            if (time - lastTapTime) > 0.25 {
                //推迟0.25秒执行单击方法
                self.perform(#selector(singleTapAction), with: nil, afterDelay: 0.25)
            } else {
                //取消执行单击方法
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(singleTapAction), object: nil)
                //执行连击显示爱心的方法
//                showLikeViewAnim(newPoint: point, oldPoint: lastTapPoint)
            }
            //更新上一次点击位置
            lastTapPoint = point
            //更新上一次点击时间
            lastTapTime = time
            break
        }
    }
    
    @objc func singleTapAction() {
        showPauseViewAnim(rate: playerView.rate())
        playerView.updatePlayerState()
    }
}

//animation
extension ShortVideoTBCell {
    func showPauseViewAnim(rate:CGFloat) {
        if rate == 0 {
            UIView.animate(withDuration: 0.25, animations: {
                self.pauseIcon.alpha = 0.0
            }) { finished in
                self.pauseIcon.isHidden = true
            }
        } else {
            pauseIcon.isHidden = false
            pauseIcon.transform = CGAffineTransform.init(scaleX: 1.8, y: 1.8)
            pauseIcon.alpha = 1.0
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseIn, animations: {
                self.pauseIcon.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
            }) { finished in
            }
        }
    }
    
    func startLoadingPlayItemAnim(_ isStart:Bool = true) {
        if isStart {
            playerStatusBar.backgroundColor = ColorWhite
            playerStatusBar.isHidden = false
            playerStatusBar.layer.removeAllAnimations()
            
            let animationGroup = CAAnimationGroup.init()
            animationGroup.duration = 0.5
            animationGroup.beginTime = CACurrentMediaTime()
            animationGroup.repeatCount = .infinity
            animationGroup.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeInEaseOut)
            
            let scaleAnim = CABasicAnimation.init()
            scaleAnim.keyPath = "transform.scale.x"
            scaleAnim.fromValue = 1.0
            scaleAnim.toValue = 1.0 * screenWidth
            
            let alphaAnim = CABasicAnimation.init()
            alphaAnim.keyPath = "opacity"
            alphaAnim.fromValue = 1.0
            alphaAnim.toValue = 0.2
            
            animationGroup.animations = [scaleAnim, alphaAnim]
            playerStatusBar.layer.add(animationGroup, forKey: nil)
        } else {
            playerStatusBar.layer.removeAllAnimations()
            playerStatusBar.isHidden = true
        }
        
    }
}

extension ShortVideoTBCell: AVPlayerUpdateDelegate {
    func onProgressUpdate(current: CGFloat, total: CGFloat) {
        
    }
    
    func onPlayItemStatusUpdate(status: AVPlayerItem.Status) {
        switch status {
        case .unknown:
            print("⏳", "startLoadingPlayItemAnim(false)")
            startLoadingPlayItemAnim()
            break
        case .readyToPlay:
            print("✅", "startLoadingPlayItemAnim(false)")
            
            isPlayerReady = true
            onPlayerReady?()
            break
        case .failed:
            startLoadingPlayItemAnim(false)
            break
        @unknown default:
            fatalError()
        }
    }
}
    
