//
//  SVWWClass.swift
//  PubNubSDKTest
//
//  Created by Zakk Hoyt on 2/6/15.
//  Copyright (c) 2015 Zakk Hoyt. All rights reserved.
//

import UIKit

class SVWWClass: NSObject {
    var what: String
    var location: SVWWStruct;
    
    convenience init(what:String, latitude:Double, longitude:Double) {
        var location = SVWWStruct(latitude: 37.11, longitude: -122.0)
        self.init(what:what, location:location)
    }
    
    init(what:String, location:SVWWStruct){
        self.what = what;
        self.location = location;
        super.init();
    }
}




