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
    var emboldenInput = SliderInput(Title: "Highlight", Min: 0.1, Max: 5, Current: 1)
    var embolden: Float = 5 {
        didSet {
            self.guiController.uniform.embolden = self.embolden
            self.guiController.editUniform()
        }
    }
    //Soma Color Picker
    var CellBodyColorInput = ColorPickerInput("Soma Color: ", NSColor.white)
    var CellBodyColor: NSColor = .white {
        didSet {
            self.guiController.uniform.CellBodyColor = SIMD3<Float>(Float(self.CellBodyColor.redComponent), Float(self.CellBodyColor.greenComponent), Float(self.CellBodyColor.blueComponent))
            self.guiController.editUniform()
        }
    }
    //Process Color Picker
    var ProcessColorInput = ColorPickerInput("Process Color: ", NSColor.red)
    var ProcessColor: NSColor = .red {
        didSet {
            self.guiController.uniform.ProcessColor = SIMD3<Float>(Float(self.ProcessColor.redComponent), Float(self.ProcessColor.greenComponent), Float(self.ProcessColor.blueComponent))
            self.guiController.editUniform()
        }
    }
    //Sheath Color Picker
    var SheathColorInput = ColorPickerInput("Sheath Color: ", NSColor.cyan)
    var SheathColor: NSColor = .cyan {
        didSet {
            self.guiController.uniform.SheathColor = SIMD3<Float>(Float(self.SheathColor.redComponent), Float(self.SheathColor.greenComponent), Float(self.SheathColor.blueComponent))
            self.guiController.editUniform()
        }
    }
    //Undefined Color Picker
    var UndefinedColorInput = ColorPickerInput("Undefined: ", NSColor.yellow)
    var UndefinedColor: NSColor = .yellow {
        didSet {
            self.guiController.uniform.UndefinedColor = SIMD3<Float>(Float(self.UndefinedColor.redComponent), Float(self.UndefinedColor.greenComponent), Float(self.UndefinedColor.blueComponent))
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
        
        var last = emboldenInput.bottomAnchor
        [CellBodyColorInput, ProcessColorInput, SheathColorInput, UndefinedColorInput].forEach({
            view.addSubview($0)
            $0.topAnchor.constraint(equalTo: last, constant: 5).isActive = true
            $0.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            $0.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 30).isActive = true
            
            last = $0.bottomAnchor
        })
        CellBodyColorInput.executable = {self.CellBodyColor = $0}
        ProcessColorInput.executable = {self.ProcessColor = $0}
        SheathColorInput.executable = {self.SheathColor = $0}
        UndefinedColorInput.executable = {self.UndefinedColor = $0}
//        view.addSubview(baseColorInput)
//        baseColorInput.topAnchor.constraint(equalTo: emboldenInput.bottomAnchor, constant: 5).isActive = true
//        baseColorInput.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
//        baseColorInput.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
//        baseColorInput.heightAnchor.constraint(equalToConstant: 30).isActive = true
//
//        baseColorInput.executable = { self.baseColor = $0 }
        
        view.addSubview(selectionColorInput)
        selectionColorInput.topAnchor.constraint(equalTo: last, constant: 5).isActive = true
        selectionColorInput.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        selectionColorInput.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        selectionColorInput.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
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
