//
//  UniformHandling.swift
//  TraceEditor
//
//  Created by Noah Pikielny on 7/28/20.
//  Copyright © 2020 Noah Pikielny. All rights reserved.
//

import Foundation

extension GUIController {
    struct Uniform {
        var kernelWidth: Int32
        var dimensions: SIMD3<Float>
        var imageSize: SIMD3<Float>
        var frame: Int32 = 0
        var selecting: Bool = false
        var selectionType: Int32
        var selectionCenter: SIMD2<Int32> = SIMD2<Int32>(-1,-1)
        var selectionSize: SIMD2<Int32> = SIMD2<Int32>(-1,-1)
        var selectionColor: SIMD3<Float> = SIMD3<Float>(0,1,0)
        
        var baseColor: SIMD3<Float> = SIMD3<Float>(1,0,0)
        var fade: Float = 2
        var embolden: Float = 5
        var showImages: Bool = true
        var grayScale: Bool = false
        var showTraces: Bool = true
        var showSelection: Bool = true

    }
    func setupUniform(PointCount: Int32, Dimensions: SIMD3<Float>) {
        self.uniform = Uniform(kernelWidth: Int32(ceil(pow(Float(PointCount),0.5))), dimensions: Dimensions, imageSize: SIMD3<Float>(Float(self.presentingImage!.width), Float(self.presentingImage!.height), Float(self.textures.count)), selectionType: self.selectionType.rawValue)
        self.uniformBuffer = device?.makeBuffer(bytes: [self.uniform], length: MemoryLayout<Uniform>.stride, options: .storageModeManaged)
    }
    func editUniform() {
        let pointer = self.uniformBuffer?.contents()
        memcpy(pointer, [self.uniform], MemoryLayout<Uniform>.stride)
        self.uniformBuffer!.didModifyRange(Range<Int>.init(NSRange(location: 0, length: self.uniformBuffer!.length))!)
    }
}
