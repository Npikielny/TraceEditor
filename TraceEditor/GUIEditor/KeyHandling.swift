//
//  KeyHandling.swift
//  TraceEditor
//
//  Created by Noah Pikielny on 7/28/20.
//  Copyright © 2020 Noah Pikielny. All rights reserved.
//

import Cocoa

extension GUIController {
    
    override func flagsChanged(with event: NSEvent) {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        if flags.contains(.shift) && !flags.contains(.option) && !flags.contains(.command) {
            self.selectionType = .addition
        }else if !flags.contains(.shift) && flags.contains(.option) && !flags.contains(.command) {
            self.selectionType = .subtraction
        } else if flags.contains(.command) && !flags.contains(.option) && !flags.contains(.shift) {
            self.selectionType = .negative
        }else {
            self.selectionType = .single
        }
        self.uniform.selectionType = self.selectionType.rawValue
        self.editUniform()
    }
    override func keyDown(with event: NSEvent) {
        print(event.keyCode)
        if [7,51,117].contains(event.keyCode) { // Delete (or x)
            deleteTrace()
        } else if event.keyCode == 0{
            for i in 0..<self.traces!.count {
                self.traces![i].selected = true
                memcpy(self.tracesBuffer?.contents(), self.traces, self.tracesBuffer!.length)
            }
        } else {
            print(event.keyCode)
        }
    }
}
