//
//  Length.swift
//  InfiniteScrollView
//
//  Created by Денис Либит on 23.04.2021.
//

import Foundation
import UIKit


extension InfiniteScrollView {
    public enum Length {
        case auto
        case fixed(CGFloat)
        case flexible(CGFloat)
    }
}
