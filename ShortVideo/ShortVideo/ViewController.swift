//
//  ViewController.swift
//  ShortVideo
//
//  Created by Quoc Cuong on 02/11/2022.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var shortTableView: UITableView!
    
    let reuseIdentify = "shortCell"
    
    var shortArr: [ShortModel]? = ShortModel.showDataHome()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
}

extension ViewController {
    private func configUI(){
        shortTableView.register(ShortVideoTBCell.self, forCellReuseIdentifier: reuseIdentify)
        
        shortTableView.delegate = self
        shortTableView.dataSource = self
        shortTableView.isPagingEnabled = true
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shortArr?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let shortModel = shortArr?[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentify, for: indexPath) as! ShortVideoTBCell
        cell.backgroundColor = shortModel?.color
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height
    }
    
}

