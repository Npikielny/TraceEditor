//
//  UniformHandling.swift
//  TraceEditor
//
//  Created by Noah Pikielny on 7/28/20.
//  Copyright © 2020 Noah Pikielny. All rights reserved.
//

import Cocoa

extension GUIController {
    struct Uniform {
        var kernelWidth: Int32
        var pointCount: Int32
        var dimensions: SIMD3<Float>
        var imageSize: SIMD3<Float>
        var frame: Int32 = 0
        var selecting: Bool = false
        var selectionType: Int32
        var selectionCenter: SIMD2<Int32> = SIMD2<Int32>(-1,-1)
        var selectionSize: SIMD2<Int32> = SIMD2<Int32>(-1,-1)
        var selectionColor: SIMD3<Float> = SIMD3<Float>(0,1,0)
        
        var OligoColor: SIMD3<Float> = SIMD3<Float>(Float(NSColor.green.redComponent),Float(NSColor.green.greenComponent),Float(NSColor.green.blueComponent))
        var NG2Color: SIMD3<Float> = SIMD3<Float>(Float(NSColor.red.redComponent),Float(NSColor.red.greenComponent),Float(NSColor.red.blueComponent))
        var AxonColor: SIMD3<Float> = SIMD3<Float>(Float(NSColor.cyan.redComponent),Float(NSColor.cyan.greenComponent),Float(NSColor.cyan.blueComponent))
        var UndefinedColor: SIMD3<Float> = SIMD3<Float>(Float(NSColor.yellow.redComponent),Float(NSColor.yellow.greenComponent),Float(NSColor.yellow.blueComponent))
        
        
        
        
        var fade: Float = 2
        var embolden: Float = 1
        var showImages: Bool = true
        var grayScale: Bool = false
        var showTraces: Bool = true
        var showSelection: Bool = true

    }
    func setupUniform(PointCount: Int32, Dimensions: SIMD3<Float>) {
        self.uniform = Uniform(kernelWidth: Int32(ceil(pow(Float(PointCount),0.5))), pointCount: PointCount, dimensions: Dimensions, imageSize: SIMD3<Float>(Float(self.presentingImage!.width), Float(self.presentingImage!.height), Float(self.textures.count)), selectionType: self.selectionType.rawValue)
        self.uniformBuffer = device?.makeBuffer(bytes: [self.uniform], length: MemoryLayout<Uniform>.stride, options: .storageModeManaged)
    }
    func editUniform() {
        let pointer = self.uniformBuffer?.contents()
        memcpy(pointer, [self.uniform], MemoryLayout<Uniform>.stride)
        self.uniformBuffer!.didModifyRange(Range<Int>.init(NSRange(location: 0, length: self.uniformBuffer!.length))!)
    }
}
