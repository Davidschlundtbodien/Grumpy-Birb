//
//  Level.swift
//  Grumpy Birb
//
//  Created by David Schlundt-Bodien on 9/30/20.
//  Copyright © 2020 David Schlundt-Bodien. All rights reserved.
//

import Foundation

struct Level {
    let birbs : [String]
    
    // Pulls birb array from level Plist
    init?(level: Int) {
        guard let levelDictionary = Levels.levelsDictionary["Level_\(level)"] as? [String:Any] else {
            return nil
        }
        guard let birbs = levelDictionary["Birbs"] as? [String] else {
            return nil
        }
        self.birbs = birbs
    }
}
