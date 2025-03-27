//
//  Constant.swift
//  Task2
//
//  Created by chiam shwuyeh on 2025-03-26.
//

import Foundation
import SwiftUI

typealias MainFont = Constant.Font.HelveticaNeue

enum Constant {
    enum Color: String {
//        #if MAXIS || TESTFLIGHT_MAXIS
        case mainColor = "#563C7C"
        case tintColor = "#40C706"
//        #else
//        case mainColor = "#563C7C"
//        case tintColor = "#A13BA9"
//        #endif
    }
   
    enum Font {
        enum HelveticaNeue: String {
            case ultraLightItalic = "UltraLightItalic"
            case medium = "Medium"
            case mediumItalic = "MediumItalic"
            case ultraLight = "UltraLight"
            case italic = "Italic"
            case light = "Light"
            case thinItalic = "ThinItalic"
            case lightItalic = "LightItalic"
            case bold = "Bold"
            case thin = "Thin"
            case condensedBlack = "CondensedBlack"
            case condensedBold = "CondensedBold"
            case boldItalic = "BoldItalic"
            
            func with(size: CGFloat) -> UIFont {
                return UIFont(name: "HelveticaNeue-\(rawValue)", size: size)!
            }
        }
    }
}
