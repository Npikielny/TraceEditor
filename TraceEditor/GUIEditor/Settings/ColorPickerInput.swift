//
//  ColorPickerInput.swift
//  TraceEditor
//
//  Created by Noah Pikielny on 7/28/20.
//  Copyright © 2020 Noah Pikielny. All rights reserved.
//

import Cocoa

class ColorPickerInput: NSView {
    
    var title: NSText = {
        let text = NSText()
        text.isEditable = false
        text.isSelectable = false
        text.backgroundColor = NSColor.clear
        return text
    }()
    
    var colorShower: NSView = {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.cornerRadius = 5
        return view
    }()
    
    lazy var editButton = NSButton(title: "Edit", target: self, action: #selector(editColor))
    
    @objc func editColor() {
        let cp = NSColorPanel.shared
        cp.setTarget(self)
        cp.setAction(#selector(colorDidChange))
        cp.makeKeyAndOrderFront(self)
        cp.isContinuous = true
    }
    @objc func colorDidChange(sender:AnyObject) {
        if let cp = sender as? NSColorPanel {
            self.colorShower.layer?.backgroundColor = cp.color.cgColor
            executable(cp.color)
        }
    }
    var executable: (NSColor) -> () = {_ in}
    
    init(_ Title: String, _ StartingColor: NSColor) {
        super.init(frame: .zero)
        self.colorShower.layer?.backgroundColor = StartingColor.cgColor
        self.translatesAutoresizingMaskIntoConstraints = false
        self.title.string = Title
        
        [title, colorShower, editButton].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        })
        title.widthAnchor.constraint(equalToConstant: 100).isActive = true
        title.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
        title.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 2.5).isActive = true
        title.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        colorShower.leftAnchor.constraint(equalTo: title.rightAnchor, constant: 5).isActive = true
        colorShower.widthAnchor.constraint(equalToConstant: 15).isActive = true
        colorShower.heightAnchor.constraint(equalToConstant: 15).isActive = true
        colorShower.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        editButton.leftAnchor.constraint(equalTo: colorShower.rightAnchor, constant: 10).isActive = true
        editButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
