//
//  SliderInput.swift
//  TraceEditor
//
//  Created by Noah Pikielny on 7/27/20.
//  Copyright © 2020 Noah Pikielny. All rights reserved.
//

import Cocoa

class SliderInput: NSView, NSTextDelegate {
    
    var title: NSText = {
        let text = NSText()
        text.isEditable = false
        text.isSelectable = false
        text.backgroundColor = NSColor.clear
        return text
    }()
    
    lazy var slider: NSSlider = {
        let slider = NSSlider(target: self, action: #selector(sliderValueChanged))
        return slider
    }()
    
    @objc func sliderValueChanged() {
        outputLabel.string = "\(round(slider.doubleValue*100)/100)"
        executable(self.slider.floatValue)
    }
    
    lazy var outputLabel: NSText = {
        let text = NSText()
        text.backgroundColor = NSColor.clear
        text.alignment = .center
        text.delegate = self
        return text
    }()
    
    func textDidChange(_ notification: Notification) {
        if let doubleValue = Double(outputLabel.string) {
            if doubleValue <= slider.maxValue && doubleValue >= slider.minValue {
                self.slider.doubleValue = doubleValue
                sliderValueChanged()
                return
            }
        }
        outputLabel.string = "\(round(slider.doubleValue))"
    }
    
    var executable: (Float) -> () = {
        _ in
    }
    
    init(Title: String, Min: Double, Max: Double, Current: Double) {
        self.title.string = Title
        super.init(frame: .zero)
        self.outputLabel.string = String(Current)
        slider.minValue = Min
        slider.maxValue = Max
        slider.doubleValue = Current
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        [title,slider,outputLabel].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        })
        
        title.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 2.5).isActive = true
        title.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
        title.widthAnchor.constraint(equalToConstant: 75).isActive = true
        title.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        slider.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        slider.leftAnchor.constraint(equalTo: title.rightAnchor, constant: 5).isActive = true
        slider.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1, constant: -10).isActive = true
        slider.rightAnchor.constraint(equalTo: outputLabel.leftAnchor, constant: -5).isActive = true
        slider.widthAnchor.constraint(greaterThanOrEqualToConstant: 75).isActive = true
        
        outputLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 5).isActive = true
        outputLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
        outputLabel.leftAnchor.constraint(equalTo: slider.rightAnchor, constant: 5).isActive = true
        outputLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
        outputLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -5).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
