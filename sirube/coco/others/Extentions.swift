//  Extentions.swift

import UIKit

extension UIColor {
  
  static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
    return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
  }
  
  static func mainVanilla() -> UIColor {
    return UIColor.rgb(red: 247, green: 239, blue: 221)
  }
  
  static func mainGold() -> UIColor {
    return UIColor.rgb(red: 219, green: 193, blue: 115)
  }
  
  static func subGold() -> UIColor {
    return UIColor.rgb(red: 162, green: 154, blue: 132)
  }
  
  static func mainEmerald() -> UIColor {
    return UIColor.rgb(red: 146, green: 213, blue: 208)
  }
  
  static func lightEmerald() -> UIColor {
    return UIColor.rgb(red: 200, green: 225, blue: 225)
  }
  
  static func mainBlue() -> UIColor {
    return UIColor.rgb(red: 130, green: 182, blue: 232)
  }
  
  static func darkPurple() -> UIColor {
    return UIColor.rgb(red: 58, green: 49, blue: 131)
  }
  
  static func subPurple() -> UIColor {
    return UIColor.rgb(red: 194, green: 192, blue: 211)
  }
  
  static func redPurple() -> UIColor {
    return UIColor.rgb(red: 195, green: 75, blue: 149)
  }
  
  static func subGray() -> UIColor {
    return UIColor.rgb(red: 211, green: 211, blue: 211)
  }
  
  static func LINEGreen() -> UIColor {
    return UIColor.rgb(red: 7, green: 196, blue: 62)
  }
  
  
}

extension UIView {
  func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?,  paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {
    
    translatesAutoresizingMaskIntoConstraints = false
    
    if let top = top {
      self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
    }
    
    if let left = left {
      self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
    }
    
    if let bottom = bottom {
      bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
    }
    
    if let right = right {
      rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
    }
    
    if width != 0 {
      widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    if height != 0 {
      heightAnchor.constraint(equalToConstant: height).isActive = true
    }
  }
  
}
