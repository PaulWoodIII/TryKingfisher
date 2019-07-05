//
//  Assets.swift
//  TryKingfisher
//
//  Created by Paul Wood on 7/5/19.
//  Copyright © 2019 Paul Wood. All rights reserved.
//

import Foundation
import UIKit

struct Assets {}

extension Assets {
  enum Images: String {
    case beardPlaceHolder = "BeardPlaceholder"
    
    var uiImage : UIImage {
      return UIImage(named: self.rawValue)!
    }
  }
}

