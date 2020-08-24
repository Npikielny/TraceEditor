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
        let newItem = NSMenuItem(title: "New Editor", action: #selector(newEditor), keyEquivalent: "n")
        let saveItem = NSMenuItem(title: "Save Trace", action: #selector(saveTrace), keyEquivalent: "s")
        let closeWindow = NSMenuItem(title: "Close Window", action: #selector(newEditor), keyEquivalent: "w")
        [newImage, newTrace, newItem, saveItem, closeWindow].forEach({
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
    func gatherTraceString() -> String {
        var traceString: String = "Voxel Size: \(self.voxelSize) \n"
//        let voxel = self.voxelSize ?? SIMD3<Float>(0,0,0)
        let voxel: SIMD3<Float> = {
            if let unwrappedCorrection = self.voxelSize {
                return unwrappedCorrection
            }else {
                return SIMD3<Float>(1,1,1)
            }
        }()
        
        let dataPoints: [String] = points!.map({
            return (String($0.n) + " " + String($0.type) + " " + String($0.position.x * voxel.x) + " " + String($0.position.y * voxel.y) + " " + String($0.position.z * voxel.z) + " " + String($0.radius) + " " + String($0.parent))
        })
//        print(dataPoints)
        for i in dataPoints {
            print(i)
            traceString += i + "\n"
        }
//        print(traceString)
        return traceString
    }
    @objc func saveTrace() {
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        savePanel.message = "Saving Traces"
        savePanel.nameFieldLabel = "File Name"
        savePanel.prompt = "Create"
        if savePanel.runModal() == NSApplication.ModalResponse.OK {
            let fileName = savePanel.nameFieldStringValue
            let directory = savePanel.directoryURL
            let path = (directory ?? URL(fileURLWithPath: "")).path + "/" + fileName + (( fileName.suffix(4) == ".swc") ? "" : ".swc")
            do {
                try gatherTraceString().write(to: URL(fileURLWithPath: path), atomically: true, encoding: .utf8)
            }catch {
                print(error)
            }
//            print(fileName)
//            print(path)
//            FileManager.default.createFile(atPath: path, contents: Data(), attributes: [:])
//            print(gatherTraceString())
            
        }
        
    }
}
