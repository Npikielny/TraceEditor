//
//  MouseHandling.swift
//  TraceEditor
//
//  Created by Noah Pikielny on 7/25/20.
//  Copyright © 2020 Noah Pikielny. All rights reserved.
//

import Cocoa

extension GUIController {
    
    func getPosition(event: NSEvent) -> SIMD2<Int32>? {
        if let texture = self.presentingImage {
            let location = SIMD2<Float>(Float(event.locationInWindow.x),Float(event.locationInWindow.y) - Float(self.view.frame.size.height - self.imageHolder.frame.size.height)) / SIMD2<Float>(Float(imageHolder.frame.size.width),Float(imageHolder.frame.size.height)) * SIMD2<Float>(Float(texture.width),Float(texture.height))
            return SIMD2<Int32>(Int32(location.x), Int32(location.y))
        }
        return nil
    }
    
    override func mouseDown(with event: NSEvent) {
        if self.selectionType == .single {
            for i in 0..<self.traces!.count {
                self.traces![i].selected = false
            }
            let pointer = self.tracesBuffer?.contents()
            memcpy(pointer, self.traces!, MemoryLayout<Trace>.stride*self.traces!.count)
//            self.tracesBuffer?.didModifyRange(Range<Int>.init(NSRange(location: 0, length: self.tracesBuffer!.length))!)
        }
        self.startingPosition = getPosition(event: event)
        self.endingPosition = getPosition(event: event)
        
        self.view.window?.makeFirstResponder(nil)
    }
    override func mouseDragged(with event: NSEvent) {
        if let _ = self.startingPosition {
            if self.selectionType == .single {
                for i in 0..<self.traces!.count {
                    self.traces![i].selected = false
                }
                let pointer = self.tracesBuffer?.contents()
                memcpy(pointer, self.traces!, MemoryLayout<Trace>.stride*self.traces!.count)
//                self.tracesBuffer?.didModifyRange(Range<Int>.init(NSRange(location: 0, length: self.tracesBuffer!.length))!)
            }
            self.endingPosition = getPosition(event: event)
        }
    }
    
    override func mouseUp(with event: NSEvent) {
//        self.startingPosition = nil
//        self.endingPosition = nil
        self.uniform.selecting = false
        print("SELECTING FALSE")
        editUniform()
    }
    
    override func scrollWheel(with event: NSEvent) {
//        print(event.scrollingDeltaX+event.scrollingDeltaY)
        let delta = event.scrollingDeltaY+event.scrollingDeltaX
        if delta > 0 {
            frameInput.slider.intValue += Int32(ceil(abs(delta)))
        }else {
            frameInput.slider.intValue -= Int32(ceil(abs(delta)))
        }
        frameInput.sliderValueChanged()
    }
}
