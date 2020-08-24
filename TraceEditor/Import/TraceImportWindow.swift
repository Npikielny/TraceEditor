//
//  TraceImportWindow.swift
//  TraceEditor
//
//  Created by Noah Pikielny on 8/11/20.
//  Copyright © 2020 Noah Pikielny. All rights reserved.
//

import Cocoa

class TraceImportWindow: NSViewController {
    var editor: GUIController
    init(Editor: GUIController) {
        self.editor = Editor
        super.init(nibName: "TraceImportWindow", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    lazy var finishButton: NSButton = {
        let button = NSButton(title: "Load Traces", target: self, action: #selector(finishSelection))
        return button
    }()
    
    @objc func setTraces() {
    }
    
    @objc func finishSelection() {
        let importer = Importer()
//        let completionFunction: (Any) -> () = {
//            (data) in
//            let UNWPDData = data as! ([MTLTexture]?, MTLTexture?, [Trace]?, [Point]?, SIMD3<Float>?)
//            self.editor.addTraces(UNWPDData.2, UNWPDData.3)
//            self.view.window?.close()
//        }
        
        importer.importDataToEditor(imageDirectory: nil, TracePath: tracesFilePathText.string, Editor: self.editor) {
//            Completion((textures, presentingImage, traces, points, voxelCorrection))
            data in
            let UNWPDData = data as! ([MTLTexture]?, MTLTexture?, [Trace]?, [Point]?, SIMD3<Float>?)
            self.editor.addTraces(UNWPDData.2, UNWPDData.3)
            self.view.window?.close()
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        [tracesLabel, tracesFilePathText, setTracesButton, finishButton].forEach({
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        tracesLabel.leftAnchor.constraint(equalTo: view.leftAnchor,constant: 10).isActive = true
        tracesLabel.topAnchor.constraint(equalTo: view.topAnchor,constant: 10).isActive = true
        tracesLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        tracesLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        setTracesButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -5).isActive = true
        setTracesButton.centerYAnchor.constraint(equalTo: tracesFilePathText.centerYAnchor).isActive = true
        setTracesButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
        
        tracesFilePathText.topAnchor.constraint(equalTo: tracesLabel.bottomAnchor, constant: 0).isActive = true
        tracesFilePathText.leftAnchor.constraint(equalTo: tracesLabel.leftAnchor).isActive = true
        tracesFilePathText.rightAnchor.constraint(equalTo: setTracesButton.leftAnchor, constant: -5).isActive = true
        tracesFilePathText.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        finishButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        finishButton.topAnchor.constraint(equalTo: tracesFilePathText.bottomAnchor, constant: 10).isActive = true
        finishButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
    }
    
}
