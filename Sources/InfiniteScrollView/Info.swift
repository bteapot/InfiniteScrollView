//
//  Info.swift
//  InfiniteScrollView
//
//  Created by Денис Либит on 27.04.2021.
//

import Foundation
import UIKit


extension InfiniteScrollView {
    public struct Info {
        let view: UIView
        let length: Length
        
        public init(view: UIView, length: InfiniteScrollView.Length) {
            self.view = view
            self.length = length
        }
    }
}
