//
//  SelectionTypeItem.swift
//  TraceEditor
//
//  Created by Noah Pikielny on 7/31/20.
//  Copyright © 2020 Noah Pikielny. All rights reserved.
//

import Cocoa

class SelectionTypeItem: NSCollectionViewItem {
    
    static var reuseIdentifier = NSUserInterfaceItemIdentifier("SelectionIdentifier")
    
    var selectionTypeText: NSText = {
        let text = NSTextView()
        text.isEditable = false
        text.isSelectable = false
        text.backgroundColor = NSColor.clear
        text.alignment = .center
        text.string = "SelectionType"
        text.translatesAutoresizingMaskIntoConstraints = false
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
        view.addSubview(selectionTypeText)
        selectionTypeText.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        selectionTypeText.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        selectionTypeText.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        selectionTypeText.heightAnchor.constraint(equalToConstant: 15).isActive = true
    }
    
}
