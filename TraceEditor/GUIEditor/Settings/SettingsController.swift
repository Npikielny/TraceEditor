//
//  SettingsController.swift
//  TraceEditor
//
//  Created by Noah Pikielny on 7/27/20.
//  Copyright © 2020 Noah Pikielny. All rights reserved.
//

import Cocoa

class SettingsController: NSViewController {
    
    var guiController: GUIController!
    
    convenience init(_ Editor: GUIController) {
        self.init(nibName: "SettingsController", bundle: nil)
        self.guiController = Editor
    }
    
    //Fade -> Slider
    var fadeInput = SliderInput(Title: "Fade", Min: 0, Max: 5, Current: 2)
    var fade: Float = 2 {
        didSet {
            self.guiController.uniform.fade = self.fade
            self.guiController.editUniform()
        }
    }
    //Embolden Size
    var emboldenInput = SliderInput(Title: "Highlight", Min: 1, Max: 10, Current: 5)
    var embolden: Float = 5 {
        didSet {
            self.guiController.uniform.embolden = self.embolden
            self.guiController.editUniform()
        }
    }
    //Selection Color Picker
    var baseColorInput = ColorPickerInput("Base Color: ", NSColor.red)
    var baseColor: NSColor = .red {
        didSet {
            self.guiController.uniform.baseColor = SIMD3<Float>(Float(self.baseColor.redComponent), Float(self.baseColor.greenComponent), Float(self.baseColor.blueComponent))
            self.guiController.editUniform()
        }
    }
    //Selection Color Picker
    var selectionColorInput = ColorPickerInput("Selection Color: ", NSColor.green)
    var selectionColor: NSColor = .green {
        didSet {
            self.guiController.uniform.selectionColor = SIMD3<Float>(Float(self.selectionColor.redComponent), Float(self.selectionColor.greenComponent), Float(self.selectionColor.blueComponent))
            self.guiController.editUniform()
        }
    }
    //Show background -> Check
    lazy var showBackgroundButton = NSButton(checkboxWithTitle: "Draw Image", target: self, action: #selector(toggleButtonActivated))
    //Grayscale -> Check
    lazy var grayScaleButton = NSButton(checkboxWithTitle: "Use Gray Scale", target: self, action: #selector(toggleButtonActivated))
    //Show traces -> Check
    lazy var showTracesButton = NSButton(checkboxWithTitle: "Show Traces", target: self, action: #selector(toggleButtonActivated))
    //Selection shows -> Check
    lazy var showSelectionButton = NSButton(checkboxWithTitle: "Show Selected Traces", target: self, action: #selector(toggleButtonActivated))
    
    @objc func toggleButtonActivated() {
        self.guiController.uniform.showImages = (showBackgroundButton.state == NSButton.StateValue.on)
        self.guiController.uniform.grayScale = (grayScaleButton.state == NSButton.StateValue.on)
        self.guiController.uniform.showTraces = (showTracesButton.state == NSButton.StateValue.on)
        self.guiController.uniform.showSelection = (showSelectionButton.state == NSButton.StateValue.on)
        self.guiController.editUniform()
    }
    
    //Tools -> Switch
        //Join
        //Cut
        //Delete
    //
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        view.addSubview(fadeInput)
        fadeInput.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        fadeInput.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        fadeInput.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        fadeInput.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        fadeInput.executable = { self.fade = $0 }
        
        view.addSubview(emboldenInput)
        emboldenInput.topAnchor.constraint(equalTo: fadeInput.bottomAnchor, constant: 5).isActive = true
        emboldenInput.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        emboldenInput.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        emboldenInput.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        emboldenInput.executable = { self.embolden = $0 }
        
        view.addSubview(baseColorInput)
        baseColorInput.topAnchor.constraint(equalTo: emboldenInput.bottomAnchor, constant: 5).isActive = true
        baseColorInput.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        baseColorInput.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        baseColorInput.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        baseColorInput.executable = { self.baseColor = $0 }
        
        view.addSubview(selectionColorInput)
        selectionColorInput.topAnchor.constraint(equalTo: baseColorInput.bottomAnchor, constant: 5).isActive = true
        selectionColorInput.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        selectionColorInput.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        selectionColorInput.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        selectionColorInput.executable = { self.selectionColor = $0 }
        
        [showBackgroundButton, grayScaleButton, showTracesButton, showSelectionButton].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.state = NSButton.StateValue.on
            view.addSubview($0)
            $0.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        })
        showBackgroundButton.topAnchor.constraint(equalTo: selectionColorInput.bottomAnchor, constant: 5).isActive = true
        grayScaleButton.topAnchor.constraint(equalTo: showBackgroundButton.bottomAnchor, constant: 10).isActive = true
        grayScaleButton.state = NSButton.StateValue.off
        showTracesButton.topAnchor.constraint(equalTo: grayScaleButton.bottomAnchor, constant: 10).isActive = true
        showSelectionButton.topAnchor.constraint(equalTo: showTracesButton.bottomAnchor, constant: 10).isActive = true
    }
    
}
