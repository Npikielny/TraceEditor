//
//  MenuBarHandling.swift
//  TraceEditor
//
//  Created by Noah Pikielny on 8/10/20.
//  Copyright © 2020 Noah Pikielny. All rights reserved.
//

import Cocoa

extension GUIController {
    func setupMenuBar(_ MainMenu: inout NSMenu) {
//        let menuBar = NSMenu()
        MainMenu.items = [MainMenu.items[0]]
        let fileActions = NSMenuItem()
        fileActions.title = "File"
        MainMenu.addItem(fileActions)
        
        let fileMenu = NSMenu()
        fileMenu.title = "File"
        let newImage = NSMenuItem(title: "Open New Image", action: #selector(newEditor), keyEquivalent: "o")
        let newTrace = NSMenuItem(title: "Open New Trace", action: #selector(importTrace), keyEquivalent: "i")
        let export = NSMenuItem(title: "Export", action: #selector(newEditor), keyEquivalent: "s")
        let newItem = NSMenuItem(title: "New Editor", action: #selector(newEditor), keyEquivalent: "n")
        let closeWindow = NSMenuItem(title: "Close Window", action: #selector(newEditor), keyEquivalent: "w")
        [newImage, newTrace, newItem, export, closeWindow].forEach({
            fileMenu.addItem($0)
        })
        
        MainMenu.setSubmenu(fileMenu, for: fileActions)
        
    }
    @objc func importTrace() {
        let traceImporter = TraceImportWindow(Editor: self)
        let window = NSWindow(contentViewController: traceImporter)
        window.title = "Trace Importer"
        window.makeKeyAndOrderFront(self)
//        let controller = FileInputController(false, { data in
//            if let Traces = data.2 {
//                self.traces = Traces
//            }
//            if let Points = data.3 {
//                self.points = Points
//            }
//        })
//        let window = NSWindow(contentViewController: controller)
//        window.title = "Trace Editor File Importer"
//        window.makeKeyAndOrderFront(self)
    }
    
    @objc func newEditor() {
        let controller = FileInputController()
        let window = NSWindow(contentViewController: controller)
        window.title = "Trace Editor File Importer"
        window.makeKeyAndOrderFront(self)
    }
}
