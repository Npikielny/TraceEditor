//
//  FrameViewer.swift
//  TraceEditor
//
//  Created by Noah Pikielny on 7/26/20.
//  Copyright © 2020 Noah Pikielny. All rights reserved.
//

import Cocoa

class FrameViewer: NSView, NSTextDelegate {
    lazy var currentFrame: NSText = {
        let text = NSText()
        text.font = NSFont.systemFont(ofSize: 15)
        text.textColor = NSColor.systemGray
        text.backgroundColor = NSColor.clear
        text.string = "0"
        text.delegate = self
        return text
    }()
    func textDidChange(_ notification: Notification) {
        if currentFrame.string == "" {
            slider.intValue = Int32(0)
            executable(self.slider.intValue)
            self.currentFrame.string = "0"
            return
        }else if let value = Int(currentFrame.string) {
            if value <= maxFrame && value >= 0{
                slider.intValue = Int32(value)
                executable(self.slider.intValue)
                return
            }
        }
        self.currentFrame.string = "\(self.slider.intValue)"
    }
    
    lazy var totalFrames: NSText = {
        let text = NSText()
        text.font = NSFont.systemFont(ofSize: 15)
        text.textColor = NSColor.systemGray
        text.backgroundColor = NSColor.clear
        text.string = " / \(self.maxFrame)"
        text.isEditable = false
        text.isSelectable = false
        text.discardCursorRects()
        return text
    }()
    
    var maxFrame: Int {
        didSet {
            self.totalFrames.string = " / \(self.maxFrame)"
            slider.maxValue = Double(self.maxFrame)
            slider.numberOfTickMarks = self.maxFrame+1
            slider.intValue = Int32(0)
            self.currentFrame.string = "0"
        }
    }
    
    lazy var slider: NSSlider = {
        let slider = NSSlider(target: self, action: #selector(sliderValueChanged))
        slider.allowsTickMarkValuesOnly = true
        return slider
    }()
    
    @objc func sliderValueChanged() {
        self.currentFrame.string = "\(self.slider.intValue)"
        executable(self.slider.intValue)
    }
    
    var executable: (Int32) -> () = {_ in}
    
    init(MaxFrame: Int) {
        self.maxFrame = MaxFrame
        super.init(frame: .zero)
        
        slider.numberOfTickMarks = MaxFrame + 1
        slider.maxValue = Double(MaxFrame)
        
        [currentFrame,totalFrames,slider].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
            $0.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
            $0.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        })
        currentFrame.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        currentFrame.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        totalFrames.leftAnchor.constraint(equalTo: currentFrame.rightAnchor).isActive = true
        totalFrames.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        slider.leftAnchor.constraint(equalTo: totalFrames.rightAnchor, constant: 5).isActive = true
        slider.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
