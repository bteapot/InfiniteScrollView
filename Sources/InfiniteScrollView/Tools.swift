//
//  Tools.swift
//  InfiniteScrollView
//
//  Created by Денис Либит on 23.04.2021.
//

import Foundation
import UIKit


extension UIEdgeInsets {
    var vertical: CGFloat {
        return self.top + self.bottom
    }
    
    var horizontal: CGFloat {
        return self.left + self.right
    }
}

extension CGRect {
    var center: CGPoint {
        CGPoint(
            x: self.midX,
            y: self.midY
        )
    }
    
    func expanded(by insets: UIEdgeInsets) -> CGRect {
        CGRect(
            x:      self.minX   - insets.left,
            y:      self.minY   - insets.top,
            width:  self.width  + insets.horizontal,
            height: self.height + insets.vertical
        )
    }
}
