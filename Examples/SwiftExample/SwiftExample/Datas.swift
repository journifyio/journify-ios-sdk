//
//  Datas.swift
//  SwiftExample
//
//  Created by Mohammed on 2/8/23.
//

#if canImport(UIKit)

import UIKit

#endif
import Journify

class OutputPlugin: Plugin {
    let type: PluginType = .after
    let name: String
    
    var analytics: Journify?
    var textView: UITextView!
    
    required init(name: String) {
        self.name = name
    }
    
    init(textView: UITextView!) {
        self.textView = textView
        self.name = "output_capture"
    }
    
    func execute<T>(event: T?) -> T? where T : RawEvent {
        let string = event?.prettyPrint()
        textView.text = string
        return event
    }
}
