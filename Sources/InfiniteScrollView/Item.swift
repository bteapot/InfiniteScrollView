//
//  Item.swift
//  InfiniteScrollView
//
//  Created by Денис Либит on 23.04.2021.
//

import Foundation
import UIKit


extension InfiniteScrollView {
    public struct Item {
        internal init(
            scrollView: InfiniteScrollView,
            dataSource: InfiniteScrollViewDataSource,
            index:      Int
        ) {
            self.direction = scrollView.direction
            self.index     = index
            
            let info       = dataSource.view(isv: scrollView, index: index)
            self.view      = info.view
            self.length    = info.length
        }
        
        public   let index:     Int
        public   let view:      UIView
        internal let direction: Direction
        internal let length:    Length
    }
}

extension InfiniteScrollView.Item {
    var minLon: CGFloat {
        self.direction.minLon(of: self.view.frame)
    }
    
    var midLon: CGFloat {
        self.direction.midLon(of: self.view.frame)
    }
    
    var maxLon: CGFloat {
        self.direction.maxLon(of: self.view.frame)
    }
    
    var lenLon: CGFloat {
        self.direction.lenLon(of: self.view.frame)
    }
    
    func shift(by value: CGFloat) {
        if self.direction.isHorizontal {
            self.view.frame.origin.x += value
        } else {
            self.view.frame.origin.y += value
        }
    }
    
    enum Position {
        case center
        case before
        case after
    }
    
    func place(position: Position, point: CGFloat, insetted: CGRect, interitem: CGFloat) {
        // ещё не был добавлен?
        let initial: Bool =
            self.view.superview == nil
        
        // отключим анимацию фрейма?
        if initial {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
        }
        
        // длина элемента
        let lenLon: CGFloat = {
            switch self.length {
            case .auto:                return self.direction.lon(of: self.view.sizeThatFits(insetted.size))
            case .fixed(let length):   return length
            case .flexible(let ratio): return ratio * self.direction.lenLon(of: insetted)
            }
        }()
        
        // ширина элемента – в ширину safe-области
        let lenLat: CGFloat =
            self.direction.lenLat(of: insetted)
        
        // позиция элемента
        let minLon: CGFloat = {
            switch position {
            case .center: return point - lenLon / 2
            case .before: return point - lenLon - interitem
            case .after:  return point + interitem
            }
        }()
        
        let minLat: CGFloat =
            self.direction.minLat(of: insetted)
        
        self.view.frame =
            self.direction.rect(
                minLon: minLon,
                minLat: minLat,
                lenLon: lenLon,
                lenLat: lenLat
            )
        
        // запустим
        if initial {
            CATransaction.commit()
        }
    }
    
    func center(ratio: CGFloat, insetted: CGRect) {
        // длина элемента
        let lenLon: CGFloat = {
            switch self.length {
            case .auto:                return self.direction.lon(of: self.view.sizeThatFits(insetted.size))
            case .fixed(let length):   return length
            case .flexible(let ratio): return ratio * self.direction.lenLon(of: insetted)
            }
        }()
        
        // ширина элемента – в ширину safe-области
        let lenLat: CGFloat =
            self.direction.lenLat(of: insetted)
        
        // центр safe-области
        let insettedMidLon: CGFloat =
            self.direction.midLon(of: insetted)
        
        // ширина safe-области
        let insettedLenLon: CGFloat =
            self.direction.lenLon(of: insetted)
        
        // позиция элемента
        let minLon: CGFloat =
            insettedMidLon + (ratio * insettedLenLon - lenLon) / 2
            
        self.view.frame =
            self.direction.rect(
                minLon: minLon,
                minLat: 0,
                lenLon: lenLon,
                lenLat: lenLat
            )
    }
}
