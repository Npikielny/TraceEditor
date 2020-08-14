//
//  TextureHandling.swift
//  TraceEditor
//
//  Created by Noah Pikielny on 7/28/20.
//  Copyright © 2020 Noah Pikielny. All rights reserved.
//

import MetalKit

extension GUIController {
    
    func createHeap() {
        let heapDescriptor = MTLHeapDescriptor()
        heapDescriptor.storageMode = .private
        heapDescriptor.size = 0
        
        for i in self.textures {
            let descriptor = descriptorFromTexture(i, storageMode: .private)
            var sizeAndAlign: MTLSizeAndAlign = device!.heapTextureSizeAndAlign(descriptor: descriptor)
            sizeAndAlign.size += (sizeAndAlign.size & (sizeAndAlign.align - 1)) + sizeAndAlign.align
            heapDescriptor.size += sizeAndAlign.size
        }
        self.heap = device?.makeHeap(descriptor: heapDescriptor)
    }
    
    func moveResourcesToHeap(_ function: MTLFunction) {
        let commandBuffer = commandQueue?.makeCommandBuffer()
        let blitEncoder = commandBuffer?.makeBlitCommandEncoder()
        let descriptor = descriptorFromTexture(self.textures[0], storageMode: .private)
        for (index,i) in self.textures.enumerated() {
            if let heapTexture = heap!.makeTexture(descriptor: descriptor) {
                blitEncoder?.pushDebugGroup("Blits " + ("\(index)"))
                
                var region = MTLRegionMake2D(0, 0, i.width, i.height)
                for level in 0..<i.mipmapLevelCount {
                    blitEncoder?.pushDebugGroup("Level \(level) Blit")
                    for slice in 0..<i.arrayLength {
                        blitEncoder?.copy(from: i, sourceSlice: slice, sourceLevel: level, sourceOrigin: region.origin, sourceSize: region.size, to: heapTexture, destinationSlice: slice, destinationLevel: level, destinationOrigin: region.origin)
                    }
                    region.size.width /= 2
                    region.size.height /= 2
                    region.size.width = region.size.width == 0 ? 1 : region.size.width
                    region.size.height = region.size.height == 0 ? 1 : region.size.height
                    
                    blitEncoder?.popDebugGroup()
                    
                    
                }
                self.textures[index] = heapTexture
            }
        }
        blitEncoder?.endEncoding()
        commandBuffer?.commit()
        
        let argumentEncoder = function.makeArgumentEncoder(bufferIndex: 1)
        self.textureBuffer = device?.makeBuffer(length: argumentEncoder.encodedLength, options: MTLResourceOptions(rawValue: 0))
        
        argumentEncoder.setArgumentBuffer(self.textureBuffer, offset: 0)
        
        
        for (index,i) in textures.enumerated() {
            argumentEncoder.setTexture(i, index: index)
        }
    }
    
    func descriptorFromTexture(_ texture: MTLTexture, storageMode: MTLStorageMode) -> MTLTextureDescriptor {
        let descriptor = MTLTextureDescriptor()
        descriptor.textureType = texture.textureType
        descriptor.pixelFormat = texture.pixelFormat
        descriptor.width = texture.width
        descriptor.height = texture.height
        descriptor.depth = texture.depth
        descriptor.mipmapLevelCount = texture.mipmapLevelCount
        descriptor.arrayLength = texture.arrayLength
        descriptor.sampleCount = texture.sampleCount
        descriptor.storageMode = storageMode
        
        return descriptor
    }
    
}
