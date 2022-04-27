//
//  DataSource.swift
//  InfiniteScrollView
//
//  Created by Денис Либит on 23.04.2021.
//

import Foundation
import UIKit


public protocol InfiniteScrollViewDataSource: AnyObject {
    func initialIndex(isv: InfiniteScrollView) -> Int
    func view(isv: InfiniteScrollView, index: Int) -> InfiniteScrollView.Info
    func shown(isv: InfiniteScrollView, view: UIView, index: Int)
    func tap(isv: InfiniteScrollView, view: UIView, index: Int, point: CGPoint)
}
