//
//  Item.swift
//  fast-vocab
//
//  Created by Nguyen Duc Tuan on 26/7/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
