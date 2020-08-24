//
//  Importer.swift
//  TraceEditor
//
//  Created by Noah Pikielny on 8/10/20.
//  Copyright © 2020 Noah Pikielny. All rights reserved.
//

import MetalKit

class Importer {
    let device = MTLCreateSystemDefaultDevice()
    
    var progressController = ProgressController()
    var semaphore = DispatchSemaphore(value: 1)
    
    func loadEditorFromFiles(imageDirectory: String, TracePath: String?) {
        let progressWindow = NSWindow(contentViewController: progressController)
        let screen = (NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 600, height: 600))
        progressWindow.setFrame(NSRect(x: (screen.width - 400) / 2, y: (screen.height - 200) / 2, width: 400, height: 200), display: true)
        progressWindow.title = "Importer"
        
        semaphore.wait()
        progressController.newTask(Title: "Loading Textures", Task: "", Progress: 0)
        progressController.progressBar.startAnimation(self)
            progressWindow.makeKeyAndOrderFront(self)
        semaphore.signal()
        
        let backgroundThread = DispatchQueue.global(qos: .background)
        
        backgroundThread.async {
            self.semaphore.wait()
            let textures = self.setTextures(imageDirectory) {
                DispatchQueue.main.async {
                    self.progressController.newTask(Title: "Loading Trace Data", Task: "Gathering File Data", Progress: 0.25)
                }
                self.semaphore.signal()
            }
            var TraceData: ([Trace],[Point],SIMD3<Float>?)?
            if let tracePath = TracePath {
                self.semaphore.wait()
                TraceData = self.loadTraces(FilePath: tracePath, RecursiveParenting: false)
                self.semaphore.signal()
            }
            
            self.semaphore.wait()
            DispatchQueue.main.sync {
                let controller = GUIController(Traces: TraceData?.0, Points: TraceData?.1, VoxelSize: TraceData?.2, Textures: textures.0, PresentingImage: textures.1)
                let window = NSWindow(contentViewController: controller)
                controller.setupMenuBar(&window.menu!)
                window.title = "Trace Editor"
                let screen = NSScreen.main?.frame.size
                window.setFrame(NSRect(x: 0, y: 0, width: screen!.height, height: screen!.height), display: true)
                window.makeKeyAndOrderFront(self)
                self.progressController.progressBar.stopAnimation(self)
                progressWindow.close()
            }
            self.semaphore.signal()
        }
    }
    
    func importDataToEditor(imageDirectory: String?, TracePath: String?, Editor: GUIController, Completion: @escaping (Any) -> () ) {
        let progressWindow = NSWindow(contentViewController: progressController)
        let screen = (NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 600, height: 600))
        progressWindow.setFrame(NSRect(x: (screen.width - 400) / 2, y: (screen.height - 200) / 2, width: 400, height: 200), display: true)
        progressWindow.title = "Importer"
        
        semaphore.wait()
        progressController.newTask(Title: "Loading Textures", Task: "", Progress: 0)
        progressController.progressBar.startAnimation(self)
            progressWindow.makeKeyAndOrderFront(self)
        semaphore.signal()
        
        let backgroundThread = DispatchQueue.global(qos: .background)
        
        var textures: [MTLTexture]?
        var presentingImage: MTLTexture?
        var traces: [Trace]?
        var points: [Point]?
        var voxelCorrection: SIMD3<Float>?
        
        self.semaphore.wait()
        backgroundThread.async {
            if let ImageDirectory = imageDirectory {
                let Textures = self.setTextures(ImageDirectory) {
                    DispatchQueue.main.async {
                        self.progressController.newTask(Title: "Loading Trace Data", Task: "Gathering File Data", Progress: 0.25)
                    }
                    self.semaphore.signal()
                }
                textures = Textures.0
                presentingImage = Textures.1
            }else {
                self.semaphore.signal()
            }
            self.semaphore.wait()
            var TraceData: ([Trace],[Point],SIMD3<Float>?)?
            if let tracePath = TracePath {
                TraceData = self.loadTraces(FilePath: tracePath, RecursiveParenting: false)
                traces = TraceData?.0
                points = TraceData?.1
                voxelCorrection = TraceData?.2
            }else {
                self.semaphore.wait()
            }
            self.semaphore.wait()
            DispatchQueue.main.sync {
                print("E",traces?.count, points?.count)
                Completion((textures, presentingImage, traces, points, voxelCorrection))
                self.progressController.view.window?.close()
            }
            self.semaphore.signal()
        }
    }
    
    func setTextures(_ FilePath: String, completion: @escaping () -> ()) -> ([MTLTexture],MTLTexture){
        let tempTextures = loadTextures(FilePath)
            
        let renderTargetDescriptor = MTLTextureDescriptor()
        renderTargetDescriptor.pixelFormat = MTLPixelFormat.rgba32Float
        renderTargetDescriptor.textureType = MTLTextureType.type2D
        renderTargetDescriptor.width = Int(tempTextures[0].width)
        renderTargetDescriptor.height = Int(tempTextures[0].height)
        renderTargetDescriptor.storageMode = MTLStorageMode.private;
        renderTargetDescriptor.usage = [MTLTextureUsage.shaderRead, MTLTextureUsage.shaderWrite]
            
        let presentingImage = device!.makeTexture(descriptor: renderTargetDescriptor)!
        completion()
        return (tempTextures, presentingImage)
            
    //        self.presentingImage = device?.makeTexture(descriptor: renderTargetDescriptor)
    //
    //        self.dimensionConstraint?.isActive = false
    //        self.dimensionConstraint = imageHolder.widthAnchor.constraint(equalTo: imageHolder.heightAnchor, multiplier: CGFloat(tempTextures[0].width)/CGFloat(tempTextures[0].height))
    //        self.dimensionConstraint?.isActive = true
    //
    //        self.frameInput.maxFrame = tempTextures.count - 1
    //        completion()
        }
    
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
    
    func loadTraces(FilePath: String, RecursiveParenting: Bool) -> ([Trace],[Point], SIMD3<Float>?)? {
        do {
            var data = try getTraces(FilePath, 0, 0, 0.25) {
                DispatchQueue.main.async {
                    self.progressController.increment(Task: "Assigning Parent Structure", Progress: 0)
                }
                self.semaphore.signal()
            }
            
            if RecursiveParenting {
                DispatchQueue.main.sync {
                    self.progressController.newTask(Title: "Finding Parent Structure", Task: "Searching For Duplicate Points", Progress: 0)
                }
                semaphore.wait()
                print("Assigning Parent Structure")
                let tempData: ([Trace],[Point]) = findParentStructure(data.0, data.1)
                data.0 = tempData.0
                data.1 = tempData.1
                DispatchQueue.main.sync {
                    self.progressController.increment(Task: "Assigning GPU Resources", Progress: 0)
                }
                semaphore.signal()
            }
            
            return (data)

        } catch {
            print(error)
            semaphore.signal()
            return nil
        }
    }
    
    func findParentStructure(_ traces: [Trace], _ points: [Point]) -> ([Trace],[Point]){
        var Traces = traces
        var Points = points
        let Max: Double = 0.35
        var sortedPoints = Points.filter({ checkingPoint in
            Points.contains(where: {$0.position == checkingPoint.position && $0.n != checkingPoint.n})
        })
        DispatchQueue.main.sync {
            self.progressController.increment(Task: "Sorting Matching Point", Progress: Max * 0.33)
        }
        sortedPoints.sort(by: {$0.position.x == $1.position.x})
        sortedPoints.sort(by: {$0.position.y <= $1.position.y})
        sortedPoints.sort(by: {$0.position.z <= $1.position.z})
        DispatchQueue.main.sync {
            self.progressController.increment(Task: "Editings Points", Progress: Max * 0.33)
        }
        
        let findMatchingPoints: (Int) -> Int = { pointIndex in
            var shift = 0
            while (sortedPoints[pointIndex + shift].position == sortedPoints[pointIndex].position) {
                if pointIndex + shift + 1 >= sortedPoints.count {
                    return shift
                }
                shift += 1
            }
            return shift
        }

        var checkingIndex = 0
        while checkingIndex < sortedPoints.count {
            let matched = findMatchingPoints(checkingIndex)
            if matched > 0 {
                let matchingPoints = Array(0...matched).map({return $0 + checkingIndex}).map({sortedPoints[$0]})
                var tracesToPoints: [Int32 : [Int32]] = [:]

                for i in matchingPoints {
                    if tracesToPoints.keys.contains(i.trace) {
                        tracesToPoints[i.trace]!.append(i.n - 1)
                    }else {
                        tracesToPoints[i.trace] = [i.n-1]
                    }
                }
                for i in tracesToPoints {
                    if i.value.count > 1 {
                        let sortedMultiTrace = i.value.sorted(by: {$0 < $1})
                        var itemsInTrace = Points.filter({$0.trace == i.key})
                        for k in 1..<sortedMultiTrace.count {
                            itemsInTrace = itemsInTrace.filter({$0.n - 1 >= sortedMultiTrace[k]})
                            let traceIndex = Int32(Traces.count)
                            Traces.append(Trace(index: traceIndex, type: Points[Int(sortedMultiTrace[k])].type, parent: i.key))
                            itemsInTrace.forEach({
                                Points[Int($0.n - 1)].trace = traceIndex
                            })
                        }
                    }
                }
            }
            checkingIndex += matched+1
        }
        
        DispatchQueue.main.sync {
            self.progressController.increment(Task: "Editings Points", Progress: Max * 0.34)
        }
        
        return (Traces,Points)
    }
    
    func isFloat(_ text: String) -> Bool {
        if let _ = Float(text) {
            return true
        }else {
            return false
        }
    }
    
    func getTraces(_ FilePath: String, _ nOffset: Int32, _ traceOffset: Int32, _ Max: Double, _ completion: @escaping () -> ()) throws -> ([Trace],[Point], SIMD3<Float>?) {
        var traces = [Trace]()
        var points = [Point]()
        var fromDiretory: Bool = false
        var voxelCorrection: SIMD3<Float>?
        
        do {
            DispatchQueue.main.sync {
                self.progressController.increment(Task: "Accessing File", Progress: 0)
            }
            if !(FilePath.suffix(4) == ".swc") {
                let fileManager = FileManager.default
                let enumerator:FileManager.DirectoryEnumerator = fileManager.enumerator(atPath: FilePath)!
                
                var tempTraces = [Trace]()
                var tempPoints = [[Point]]()
                while let element = enumerator.nextObject() as? String {
                    if (element.suffix(4) == ".swc") {
//                        let data = try getTraces(FilePath+"/"+element, Max * 0.01, {})
                        let data = try getTraces(FilePath+"/"+element, Int32(tempPoints.reduce([], +).count), Int32(tempTraces.count), Max * 0.01, {})
                        tempTraces += data.0
                        tempPoints.append(data.1)
                        voxelCorrection = data.2
                        fromDiretory = true
                    }
                }
//                for i in 0..<tempPoints.count {
//                    for k in 0..<tempPoints.count {
//                        if k != i {
//                            if let starterMatch = tempPoints[k].first(where: {$0.position == tempPoints[i][0].position}) {
//                                tempTraces[Int(tempPoints[i][0].trace)].parent = starterMatch.trace
//                            }else {
//                                if let enderMatch = tempPoints[k].first(where: {$0.position == tempPoints[i].last!.position}) {
//                                    tempTraces[Int(tempPoints[i][0].trace)].parent = enderMatch.trace
//                                }
//                            }
//                        }
//                    }
//                }
                traces = tempTraces
                points = tempPoints.reduce([], +)
                
                
            }else {
                let contents = try String(contentsOfFile: FilePath)
                let rows: [String] = {
                    if contents.contains("\r\n") {
                        return contents.split(separator: "\r\n").map({String($0)})
                    }else {
                        return contents.split(separator: "\n").map({String($0)})
                    }
                }()
//                DispatchQueue.main.sync {
//                    self.progressController.increment(Task: "Converting From String to Floats", Progress: Max * 0.5)
//                }
                var itemsInRows = (rows.map({$0.split(separator: " ")}))
                if let voxelIndex = itemsInRows.firstIndex(where: { row in row.map({String($0)}).contains("Voxel") }) {
                    var row = itemsInRows[voxelIndex][4..<7].map({String($0)})
                    row = row.map({item in
                        var tempItem = item
                        tempItem.removeAll(where: {$0 == ","})
                        return tempItem
                    })
                    let values: [Float] = row.map({
                        if let Value = Float($0) {
                            return Value
                        }else {
                            return Float(-1)
                        }
                    })
                    if !values.contains(-1) {
                        voxelCorrection = SIMD3<Float>(values[0],values[1],values[2])
                    }
                }
                itemsInRows.removeAll(where: {isFloat(String($0[0])) == false})
                itemsInRows.removeAll(where: {$0.count < 7})
                let validItems = itemsInRows.map({$0.map({Float($0)!})})
                points = validItems.map({Point(n: Int32($0[0])+nOffset,
                                               type: Int32($0[1]),
                                               position: SIMD3<Float>($0[2],$0[3],$0[4]),
                                               radius: $0[5],
                                               parent: Int32($0[6])+{if $0 == -1 {return Int32(0)} else {return nOffset}}($0[6]))})
//                DispatchQueue.main.sync {
//                    self.progressController.increment(Task: "Assigning Traces", Progress: Max * 0.4)
//                }
                var traceIndex: Int32 = -1+traceOffset
                var lastType: Int32 = points[0].type
                for i in 0..<points.count {
                    if points[i].parent == -1 {
                        traceIndex += 1
                        traces.append(Trace(index: traceIndex, type: lastType))
                    }
                    points[i].trace = traceIndex
                    lastType = points[i].type
                }
            }
        } catch {
            throw error
            // contents could not be loaded
        }
//        DispatchQueue.main.sync {
//            self.progressController.increment(Task: "Applying Voxel Offset", Progress: Max * 0.1)
//        }
        if let voxelFound = voxelCorrection {
            if !fromDiretory {
                points = points.map({
                    var newPoint = $0
                    newPoint.position /= voxelFound
                    return newPoint
                })
            }
        }
        completion()
        return (traces, points, voxelCorrection)
    }
}
