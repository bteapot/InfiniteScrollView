//
//  Direction.swift
//  InfiniteScrollView
//
//  Created by Денис Либит on 23.04.2021.
//

import Foundation
import UIKit


extension InfiniteScrollView {
    public enum Direction {
        case horizontal
        case vertical
    }
}

extension InfiniteScrollView.Direction {
    var isHorizontal: Bool {
        self == .horizontal
    }
    
    // lon: от `longitudinal axis` – продольная ось
    // lat: от `latitudinal axis`  – попечечная ось
    
    // MARK: - CGPoint
    
    func point(lon: CGFloat, lat: CGFloat) -> CGPoint {
        self.isHorizontal ?
            CGPoint(
                x: lon,
                y: lat
            ) :
            CGPoint(
                x: lat,
                y: lon
            )
    }
    
    // MARK: - CGSize
    
    func size(lon: CGFloat, lat: CGFloat) -> CGSize {
        self.isHorizontal ?
            CGSize(
                width:  lon,
                height: lat
            ) :
            CGSize(
                width:  lat,
                height: lon
            )
    }
    
    func lon(of size: CGSize) -> CGFloat {
        self.isHorizontal ? size.width : size.height
    }
    
    func lat(of size: CGSize) -> CGFloat {
        self.isHorizontal ? size.height : size.width
    }
    
    // MARK: - CGRect
    
    func rect(minLon: CGFloat, minLat: CGFloat, lenLon: CGFloat, lenLat: CGFloat) -> CGRect {
        self.isHorizontal ?
            CGRect(
                x:      minLon,
                y:      minLat,
                width:  lenLon,
                height: lenLat
            ) :
            CGRect(
                x:      minLat,
                y:      minLon,
                width:  lenLat,
                height: lenLon
            )
    }
    
    func offset(rect: CGRect, lon: CGFloat, lat: CGFloat) -> CGRect {
        if self.isHorizontal {
            return rect.offsetBy(dx: lon, dy: lat)
        } else {
            return rect.offsetBy(dx: lat, dy: lon)
        }
    }
    
    func minLon(of rect: CGRect) -> CGFloat {
        self.isHorizontal ? rect.minX : rect.minY
    }
    
    func midLon(of rect: CGRect) -> CGFloat {
        self.isHorizontal ? rect.midX : rect.midY
    }
    
    func maxLon(of rect: CGRect) -> CGFloat {
        self.isHorizontal ? rect.maxX : rect.maxY
    }
    
    func minLat(of rect: CGRect) -> CGFloat {
        self.isHorizontal ? rect.minY : rect.minX
    }
    
    func midLat(of rect: CGRect) -> CGFloat {
        self.isHorizontal ? rect.midY : rect.midX
    }
    
    func maxLat(of rect: CGRect) -> CGFloat {
        self.isHorizontal ? rect.maxY : rect.maxX
    }
    
    func lenLon(of rect: CGRect) -> CGFloat {
        self.isHorizontal ? rect.width : rect.height
    }
    
    func lenLat(of rect: CGRect) -> CGFloat {
        self.isHorizontal ? rect.height : rect.width
    }
    
    // MARK: - UIEdgeInsets
    
    func insets(startLon: CGFloat = 0, startLat: CGFloat = 0, endLon: CGFloat = 0, endLat: CGFloat = 0) -> UIEdgeInsets {
        self.isHorizontal ?
            UIEdgeInsets(
                top:    startLat,
                left:   startLon,
                bottom: endLat,
                right:  endLon
            ) :
            UIEdgeInsets(
                top:    startLon,
                left:   startLat,
                bottom: endLon,
                right:  endLat
            )
    }
    
    func lon(of insets: UIEdgeInsets) -> CGFloat {
        self.isHorizontal ? insets.horizontal : insets.vertical
    }
    
    func startLon(of insets: UIEdgeInsets) -> CGFloat {
        self.isHorizontal ? insets.left : insets.top
    }
    
    func endLon(of insets: UIEdgeInsets) -> CGFloat {
        self.isHorizontal ? insets.right : insets.bottom
    }
    
    func lat(of insets: UIEdgeInsets) -> CGFloat {
        self.isHorizontal ? insets.vertical : insets.horizontal
    }
    
    func startLat(of insets: UIEdgeInsets) -> CGFloat {
        self.isHorizontal ? insets.top : insets.left
    }
    
    func endLat(of insets: UIEdgeInsets) -> CGFloat {
        self.isHorizontal ? insets.bottom : insets.right
    }
}
