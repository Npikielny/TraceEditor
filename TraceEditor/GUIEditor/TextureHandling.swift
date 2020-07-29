//
//  TextureHandling.swift
//  TraceEditor
//
//  Created by Noah Pikielny on 7/28/20.
//  Copyright © 2020 Noah Pikielny. All rights reserved.
//

import MetalKit

extension GUIController {
    
    func loadTextures(_ FilePath: String) -> [MTLTexture] {
        let textureLoader = MTKTextureLoader(device: device!)
        let textureLoaderOption = [
            MTKTextureLoader.Option.allocateMipmaps: NSNumber(value: false),
            MTKTextureLoader.Option.SRGB: NSNumber(value: false),
        ]
         var tempTextures = [(Int,MTLTexture)]()
        let fileManager = FileManager.default
        let enumerator:FileManager.DirectoryEnumerator = fileManager.enumerator(atPath: FilePath)!
        do {
            while let element = enumerator.nextObject() as? String {
                if element.hasSuffix("tiff") {
                    let url = URL(fileURLWithPath: FilePath+"/"+element)
                    tempTextures.append((Int(element.prefix(element.count - 5))!, try textureLoader.newTexture(URL: url, options: textureLoaderOption)))
                }else {
                    print("Invalid")
                }
            }
        }catch {
            print(error)
        }
        tempTextures.sort(by: {$0.0 < $1.0})
        
        print("Count: ",tempTextures.count)
        return tempTextures.map({$0.1})
    }
    
    func setTextures(_ FilePath: String) {
            let tempTextures = loadTextures(FilePath)
            self.textures = tempTextures
            let renderTargetDescriptor = MTLTextureDescriptor()
            renderTargetDescriptor.pixelFormat = MTLPixelFormat.rgba32Float
            renderTargetDescriptor.textureType = MTLTextureType.type2D
            renderTargetDescriptor.width = Int(tempTextures[0].width)
            renderTargetDescriptor.height = Int(tempTextures[0].height)
            renderTargetDescriptor.storageMode = MTLStorageMode.private;
            renderTargetDescriptor.usage = [MTLTextureUsage.shaderRead, MTLTextureUsage.shaderWrite]
            
            self.presentingImage = device?.makeTexture(descriptor: renderTargetDescriptor)
            
            self.dimensionConstraint?.isActive = false
            self.dimensionConstraint = imageHolder.widthAnchor.constraint(equalTo: imageHolder.heightAnchor, multiplier: CGFloat(tempTextures[0].width)/CGFloat(tempTextures[0].height))
            self.dimensionConstraint?.isActive = true
            
            self.frameInput.maxFrame = tempTextures.count - 1
    }
}
