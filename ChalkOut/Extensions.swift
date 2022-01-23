//
//  Extensions.swift
//  ChalkOut
//
//  Created by Dexiree Colon on 1/23/22.
//

import Foundation
import UIKit

extension UIColor{
    
    // hexadecimal chart
    var hexChart: [String] {
        return ["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"]
    }
    
    func getHex() -> String {
        // get colors info
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        // convert to Ints
        let red = Int(r*255)
        let green = Int(g*255)
        let blue = Int(b*255)
        
        // multiply by 16 get the Ints
        let r1 = Int(red/16)
        let g1 = Int(green/16)
        let b1 = Int(blue/16)
        // get the remainder
        let r2 = red%16
        let g2 = green%16
        let b2 = blue%16
        
        // take first half and second halves and convert to hexiadecimal
        return "\(hexChart[r1])\(hexChart[r2])\(hexChart[g1])\(hexChart[g2])\(hexChart[b1])\(hexChart[b2])"
    }
    
    func convertRGB(from hex: String) -> UIColor {

        let r1 = hexChart.firstIndex(of: hex[0])!
        let r2 = hexChart.firstIndex(of: hex[1])!
        let red = ((CGFloat(r1) * 16) + CGFloat(r2)) / 255.0
        
        let g1 = hexChart.firstIndex(of: hex[2])!
        let g2 = hexChart.firstIndex(of: hex[3])!
        let green = ((CGFloat(g1) * 16) + CGFloat(g2)) / 255.0
        
        let b1 = hexChart.firstIndex(of: hex[4])!
        let b2 = hexChart.firstIndex(of: hex[5])!
        let blue = ((CGFloat(b1) * 16) + CGFloat(b2)) / 255.0
        
        print("RED:\(red), GREEN:\(green), BLUE:\(blue)")
        let color = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        
        return color
    }
}

extension String {

    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}
