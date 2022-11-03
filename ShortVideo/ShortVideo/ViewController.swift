//
//  ViewController.swift
//  ShortVideo
//
//  Created by Quoc Cuong on 02/11/2022.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var shortTableView: UITableView!
    
    let arrVideo: [String] = [
        "https://vod01-cdn.fptplay.net/ovod/_definst_/mp4/9x16/6_tung_maru_team_tung_maru_20220929/6_tung_maru_team_tung_maru_20220929.smil/playlist.m3u8",
        "https://vod01-cdn.fptplay.net/ovod/_definst_/mp4/9x16/2_nhat_khai_team_tung_maru_20220929/2_nhat_khai_team_tung_maru_20220929.smil/playlist.m3u8",
        "https://vod01-cdn.fptplay.net/ovod/_definst_/mp4/9x16/5_hung_cubi_team_tung_maru_20220929/5_hung_cubi_team_tung_maru_20220929.smil/playlist.m3u8",
        "https://vod01-cdn.fptplay.net/ovod/_definst_/mp4/9x16/3_tran_thanh_chuong_team_tung_maru_20220929/3_tran_thanh_chuong_team_tung_maru_20220929.smil/playlist.m3u8",
        "https://vod01-cdn.fptplay.net/ovod/_definst_/mp4/9x16/4_nguyen_minh_chung_team_tung_maru_20220929/4_nguyen_minh_chung_team_tung_maru_20220929.smil/playlist.m3u8",
        "https://vod01-cdn.fptplay.net/ovod/_definst_/mp4/9x16/1_hana_team_tung_maru_20220929/1_hana_team_tung_maru_20220929.smil/playlist.m3u8"
    ]
    
    let reuseIdentify = "shortCell"
    @objc dynamic var currentIndex:Int = 0
    
    var isCurPlayerPause:Bool = false
    var pageIndex:Int = 0
    
    var shortArr: [ShortModel]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shortArr = self.mockData()
        shortTableView.reloadData()
        configUI()
//        addListener()
    }
    
    public func mockData() -> [ShortModel]{
        var data: [ShortModel] = []
        
        for video in arrVideo {
            data.append(ShortModel(color: .random(), url: video))
        }
        return data
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        shortTableView?.layer.removeAllAnimations()
        let cells = shortTableView?.visibleCells as! [ShortVideoTBCell]
        for cell in cells {
            cell.playerView.cancelLoading()
        }
        NotificationCenter.default.removeObserver(self)
        self.removeObserver(self, forKeyPath: "currentIndex")
    }
}

extension ViewController {
    private func configUI(){
        shortTableView.register(ShortVideoTBCell.self, forCellReuseIdentifier: reuseIdentify)
        
        shortTableView.delegate = self
        shortTableView.dataSource = self
        shortTableView.isPagingEnabled = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            
            let curIndexPath = IndexPath.init(row: self.currentIndex, section: 0)
            self.shortTableView?.scrollToRow(at: curIndexPath, at: .middle, animated: false)
            self.addObserver(self, forKeyPath: "currentIndex", options: [.initial, .new], context: nil)
        }
    }
    
    private func addListener(){
        NotificationCenter.default.addObserver(self, selector: #selector(statusBarTouchBegin), name: NSNotification.Name(rawValue: StatusBarTouchBeginNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationBecomeActive), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shortArr?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let shortModel = shortArr?[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentify) as! ShortVideoTBCell
        cell.initData(short: shortModel!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height
    }
    
}


extension ViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        DispatchQueue.main.async {
            let translatedPoint = scrollView.panGestureRecognizer.translation(in: scrollView)
            scrollView.panGestureRecognizer.isEnabled = false
            
            if translatedPoint.y < -50 && self.currentIndex < (self.shortArr!.count - 1) {
                self.currentIndex += 1
            }
            if translatedPoint.y > 50 && self.currentIndex > 0 {
                self.currentIndex -= 1
            }
            UIView.animate(withDuration: 0.01, delay: 0.0, options: .beginFromCurrentState, animations: {
                self.shortTableView?.scrollToRow(at: IndexPath.init(row: self.currentIndex, section: 0), at: .middle, animated: true)
            }, completion: { finished in
                scrollView.panGestureRecognizer.isEnabled = true
            })
        }
    }
}

extension ViewController {
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "currentIndex") {
            isCurPlayerPause = false
            var cell = shortTableView?.cellForRow(at: IndexPath.init(row: currentIndex, section: 0)) as? ShortVideoTBCell
            if cell?.isPlayerReady ?? false {
                cell?.replay()
            } else {
                AVPlayerManager.shared().pauseAll()
                cell?.onPlayerReady = {[weak self] in
                    if let indexPath = self?.shortTableView?.indexPath(for: cell!) {
                        if !(self?.isCurPlayerPause ?? true) && indexPath.row == self?.currentIndex {
                            cell?.play()
                        }
                    }
                }
            }
        }else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    @objc func statusBarTouchBegin() {
        currentIndex = 0
    }
    
    @objc func applicationBecomeActive() {
        let cell = shortTableView?.cellForRow(at: IndexPath.init(row: currentIndex, section: 0)) as! ShortVideoTBCell
        if !isCurPlayerPause {
            cell.playerView.play()
        }
    }
    
    @objc func applicationEnterBackground() {
        let cell = shortTableView?.cellForRow(at: IndexPath.init(row: currentIndex, section: 0)) as! ShortVideoTBCell
        isCurPlayerPause = cell.playerView.rate() == 0 ? true :false
        cell.playerView.pause()
    }
}
