//
//  RenderHandling.swift
//  TraceEditor
//
//  Created by Noah Pikielny on 7/24/20.
//  Copyright © 2020 Noah Pikielny. All rights reserved.
//

import MetalKit

extension GUIController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    
    func draw(in view: MTKView) {
        if let _ = self.uniformBuffer {
            let commandBuffer = commandQueue?.makeCommandBuffer()
            if let _ = self.presentingImage {
                if self.needsCopy {
                    let copyEncoder = commandBuffer?.makeComputeCommandEncoder()
                    copyEncoder?.setComputePipelineState(self.copyPipeline!)
                    copyEncoder?.setTexture(self.presentingImage!, index: 0)
                    copyEncoder?.dispatchThreadgroups(MTLSizeMake((Int(self.presentingImage!.width)  + 8 - 1) / 8, (Int(self.presentingImage!.height) + 8 - 1) / 8, 1), threadsPerThreadgroup: MTLSize(width: 8, height: 8, depth: 1))
                    copyEncoder?.endEncoding()
    //                self.needsCopy = false
                }
                if uniform.showTraces {
                    if let _ = self.points, let _ = self.traces {
                        if self.points!.count > 0 && self.traces!.count > 0{
                            let drawEncoder = commandBuffer?.makeComputeCommandEncoder()
                            drawEncoder?.setComputePipelineState(self.drawPipeline!)
                            let buffers = [self.tracesBuffer, self.pointsBuffer, self.uniformBuffer, self.colorBuffer]
                            drawEncoder?.setBuffers(buffers, offsets: Array(repeating: 0, count: buffers.count), range: 0..<buffers.count)
                            drawEncoder?.setTexture(self.presentingImage, index: 1)
                            drawEncoder?.dispatchThreadgroups(MTLSize(width: Int(self.uniform.kernelWidth+7) / 8, height:Int(self.uniform.kernelWidth+7) / 8, depth: 1), threadsPerThreadgroup: MTLSize(width: 8, height: 8, depth: 1))
                            drawEncoder?.endEncoding()
                        }
                    }
                }
                if let renderPassDescriptor = view.currentRenderPassDescriptor {
                    //Copies the ray calculation from the texture to the drawable
                    let renderEncoder = commandBuffer!.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
                    renderEncoder.setRenderPipelineState(renderPipeline!)
                    renderEncoder.setFragmentBuffer(self.uniformBuffer, offset: 0, index: 0)
                    renderEncoder.setFragmentBuffer(self.textureBuffer, offset: 0, index: 1)
                    renderEncoder.setFragmentTexture(self.presentingImage, index: 0)
                    if self.uniform.frame > 0 {
                        renderEncoder.setFragmentTexture(self.textures[Int(self.uniform.frame-1)], index: 2)
                    }
                    if Int(self.uniform.frame) < self.textures.count - 1 {
                        renderEncoder.setFragmentTexture(self.textures[Int(self.uniform.frame+1)], index: 3)
                    }
                    renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
                    renderEncoder.endEncoding()
                    commandBuffer!.present(view.currentDrawable!)
                    commandBuffer!.commit()
                }
            }
            let updatedTraces = self.tracesBuffer!.contents().bindMemory(to: Trace.self, capacity: self.traces!.count)
            let tracesCollectionView = (self.traceWindow.contentViewController as! TraceLayoutController).traceCollectionView.collectionView
            for i in 0..<self.traces!.count {
                self.traces![i].selected = updatedTraces[i].selected
    //            tracesCollectionView.item(at: IndexPath(item: i, section: 0))?.isSelected = updatedTraces[i].selected
            }
            tracesCollectionView.reloadData()
        }
    }
}
