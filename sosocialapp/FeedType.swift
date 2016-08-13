//
//  FeedType.swift
//  sosocialapp
//
//  Created by David Zielski on 8/11/16.
//  Copyright © 2016 mobiledez. All rights reserved.
//

import Foundation


class FeedType {
    
    static let ft = FeedType()
    
    enum FeedTypeEnum {
        case allFeed
        case likeFeed
        case friendFeed
        case userFeed
    }
    
    var feedTypeToShow = FeedTypeEnum.allFeed
    
}
