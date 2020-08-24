//
//  FileInputController.swift
//  TraceEditor
//
//  Created by Noah Pikielny on 7/26/20.
//  Copyright © 2020 Noah Pikielny. All rights reserved.
//

import Cocoa

class FileInputController: NSViewController {
    var executable: ((([MTLTexture]?, MTLTexture?, [Trace]?, [Point]?, SIMD3<Float>?)) -> ())?
    convenience init (_ Executable: (([MTLTexture]?, MTLTexture?, [Trace]?, [Point]?)) -> () = {_ in}) {
        self.init(nibName: "FileInputController", bundle: nil)
    }
    
    let tracesLabel: NSText = {
        let text = NSText()
        text.isEditable = false
        text.isSelectable = false
        text.string = "Trace File (swc)"
        text.translatesAutoresizingMaskIntoConstraints = false
        text.backgroundColor = NSColor.clear
        text.alignment = .center
        return text
    }()
    
    let tracesFilePathText: NSText = {
        let text = NSText()
        return text
    }()
    
    lazy var setTracesButton: NSButton = {
        let button = NSButton(title: "Find File", target: self, action: #selector(setTraces))
        return button
    }()
    
    @objc func setTraces () {
        let traceSetter = NSOpenPanel()
        traceSetter.allowsMultipleSelection = false
        traceSetter.canChooseDirectories = true
        traceSetter.canChooseFiles = false
        let response = traceSetter.runModal()
        if response == NSApplication.ModalResponse.OK {
            if let url = traceSetter.url {
                self.tracesFilePathText.string = url.path
            }
        }
    }
    
    let imagesLabel: NSText = {
        let text = NSText()
        text.isEditable = false
        text.isSelectable = false
        text.string = "Images Directory"
        text.translatesAutoresizingMaskIntoConstraints = false
        text.backgroundColor = NSColor.clear
        text.alignment = .center
        return text
    }()
    
    let imageDirectoryPathText: NSText = {
        let text = NSText()
        return text
    }()
    
    lazy var setImagesButton: NSButton = {
        let button = NSButton(title: "Find Files", target: self, action: #selector(setImages))
        return button
    }()
    
    @objc func setImages () {
        let imageSetter = NSOpenPanel()
        imageSetter.allowsMultipleSelection = false
        imageSetter.canChooseDirectories = true
        imageSetter.canChooseFiles = false
        let response = imageSetter.runModal()
        if response == NSApplication.ModalResponse.OK {
            if let url = imageSetter.url {
                self.imageDirectoryPathText.string = url.path
            }
        }
    }
    
    lazy var finishButton: NSButton = {
        let button = NSButton(title: "Load Files", target: self, action: #selector(FinishSelection))
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    @objc func FinishSelection () {
        if imageDirectoryPathText.string != "" {
            self.view.window?.close()
            
            let importer = Importer()
            importer.loadEditorFromFiles(imageDirectory: self.imageDirectoryPathText.string, TracePath: self.tracesFilePathText.string)
        }else {
            if tracesFilePathText.string.suffix(4) != ".swc" {
                tracesFilePathText.string = "Invalid file. It must be a .swc"
            }
            if imageDirectoryPathText.string == "" {
                imageDirectoryPathText.string = "Please point this to a directory of images"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        [(tracesFilePathText, setTracesButton),(imageDirectoryPathText, setImagesButton)].forEach({
            $0.0.translatesAutoresizingMaskIntoConstraints = false
            $0.1.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0.0)
            view.addSubview($0.1)
            $0.1.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -25).isActive = true
            $0.1.widthAnchor.constraint(equalToConstant: 75).isActive = true
            
            $0.0.rightAnchor.constraint(equalTo: $0.1.leftAnchor, constant: -5).isActive = true
            $0.0.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25).isActive = true
            
            $0.0.heightAnchor.constraint(equalToConstant: 50).isActive = true
            $0.0.centerYAnchor.constraint(equalTo: $0.1.centerYAnchor).isActive = true
            
            $0.0.widthAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
        })
            
        setTracesButton.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -50).isActive = true
        setImagesButton.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: 50).isActive = true
        
        view.addSubview(finishButton)
        finishButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        finishButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15).isActive = true
        finishButton.topAnchor.constraint(greaterThanOrEqualTo: imageDirectoryPathText.bottomAnchor, constant: 5).isActive = true
        
        view.addSubview(tracesLabel)
        view.addSubview(imagesLabel)
        tracesLabel.leftAnchor.constraint(equalTo: tracesFilePathText.leftAnchor).isActive = true
        tracesLabel.rightAnchor.constraint(equalTo: setTracesButton.rightAnchor).isActive = true
        tracesLabel.bottomAnchor.constraint(equalTo: tracesFilePathText.topAnchor, constant: -5).isActive = true
        tracesLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        imagesLabel.leftAnchor.constraint(equalTo: imageDirectoryPathText.leftAnchor).isActive = true
        imagesLabel.rightAnchor.constraint(equalTo: setImagesButton.rightAnchor).isActive = true
        imagesLabel.bottomAnchor.constraint(equalTo: imageDirectoryPathText.topAnchor, constant: -5).isActive = true
        imagesLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
    }
    
}
