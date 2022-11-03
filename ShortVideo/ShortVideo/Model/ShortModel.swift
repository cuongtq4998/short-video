//
//  ShortModel.swift
//  ShortVideo
//
//  Created by Quoc Cuong on 02/11/2022.
//

import Foundation
import UIKit

class ShortModel {
    var color: UIColor?
    let url: String? 
    
    init(color: UIColor? = .clear, url: String? = "") {
        self.color = color
        self.url = url
    } 
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(
           red:   .random(),
           green: .random(),
           blue:  .random(),
           alpha: 1.0
        )
    }
}
