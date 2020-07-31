//
//  TraceLayoutCell.swift
//  TraceEditor
//
//  Created by Noah Pikielny on 7/30/20.
//  Copyright © 2020 Noah Pikielny. All rights reserved.
//

import Cocoa

class TraceLayoutCell: NSCollectionViewItem {

    static var reuseIdentifier = NSUserInterfaceItemIdentifier("TraceIdentifier")
    
    convenience init () {
        self.init(nibName: "TraceLayoutCell", bundle: nil)
        self.view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    //Type
    var type: NSTextView = {
        let text = NSTextView()
        text.isEditable = false
        text.isSelectable = false
        text.backgroundColor = NSColor.clear
        text.string = "Type"
        return text
    }()
    //Number
    var number: NSTextView = {
        let text = NSTextView()
        text.isEditable = false
        text.isSelectable = false
        text.backgroundColor = NSColor.clear
        text.string = "Number"
        return text
    }()
    
    
    
    override var isSelected: Bool {
        didSet {
            self.view.layer?.backgroundColor = self.isSelected ? NSColor.systemRed.cgColor : NSColor.systemGray.cgColor
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.systemGray.cgColor
        view.layer?.cornerRadius = 5
        
        [type, number].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        })
        
        number.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 5).isActive = true
        number.widthAnchor.constraint(equalToConstant: 50).isActive = true
        number.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        number.heightAnchor.constraint(equalToConstant: 15).isActive = true
        
        type.leftAnchor.constraint(equalTo: number.rightAnchor, constant: 5).isActive = true
        type.widthAnchor.constraint(equalToConstant: 75).isActive = true
        type.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        type.heightAnchor.constraint(equalToConstant: 15).isActive = true
    }
    
}
