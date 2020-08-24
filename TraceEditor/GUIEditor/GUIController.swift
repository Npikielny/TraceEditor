//
//  GUIController.swift
//  TraceEditor
//
//  Created by Noah Pikielny on 7/24/20.
//  Copyright © 2020 Noah Pikielny. All rights reserved.
//

import MetalKit

class GUIController: NSViewController {
    
    var traceWindow: NSWindow!
    
    var voxelSize: SIMD3<Float>?
    
    convenience init(Traces: [Trace]?, Points: [Point]?, VoxelSize: SIMD3<Float>?, Textures: [MTLTexture], PresentingImage: MTLTexture) {
        self.init(nibName: "GUIController", bundle: nil)
        self.voxelSize = VoxelSize
        self.traces = Traces
        self.points = Points
        let device = MTLCreateSystemDefaultDevice()
        if let unwrappedTraces = Traces {
            self.tracesBuffer = device?.makeBuffer(bytes: unwrappedTraces, length: MemoryLayout<Trace>.stride*unwrappedTraces.count, options: .storageModeShared)
        }
        if let unwrappedPoints = Points {
            self.pointsBuffer = device?.makeBuffer(bytes: unwrappedPoints, length: MemoryLayout<Point>.stride*unwrappedPoints.count, options: .storageModeManaged)
        }
        self.textures = Textures
        
        self.presentingImage = PresentingImage
        
        setupUniformBuffers(PointCount: Int32(self.points!.count), Dimensions: SIMD3<Float>(Float(self.presentingImage!.width),Float(self.presentingImage!.height),0))
        
        let traceController = TraceLayoutController(guiController: self)
        self.traceWindow = NSWindow(contentViewController: traceController)
        self.traceWindow.title = "Trace Layout"
        self.traceWindow.makeKeyAndOrderFront(self)
        
        self.dimensionConstraint?.isActive = false
        self.dimensionConstraint = imageHolder.widthAnchor.constraint(equalTo: imageHolder.heightAnchor, multiplier: CGFloat(textures[0].width)/CGFloat(textures[0].height))
        self.dimensionConstraint?.isActive = true

        self.frameInput.maxFrame = textures.count - 1
        
    }
    
    lazy var imageHolder: MTKView = {
        let view = MTKView()
        view.drawableSize = CGSize(width: textures[0].width, height: textures[0].height)
        view.colorspace = CGColorSpace(name: CGColorSpace.linearSRGB)
        view.colorPixelFormat = MTLPixelFormat.rgba16Float
        view.autoResizeDrawable = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let device = MTLCreateSystemDefaultDevice()
    var library: MTLLibrary?
    var commandQueue: MTLCommandQueue?
    
    var copyFunction: MTLFunction?
    var copyPipeline: MTLComputePipelineState?
    var drawPipeline: MTLComputePipelineState?
    var renderPipeline: MTLRenderPipelineState?
    
    var uniform: Uniform!
    var uniformBuffer: MTLBuffer?
    
    var colors: ColorSet = ColorSet()
    var colorBuffer: MTLBuffer?
    
    var textures = [MTLTexture]()
    var heap: MTLHeap?
    var textureBuffer: MTLBuffer?
    
    
    var presentingImage: MTLTexture?
    
    var size: CGSize?
    
    var dimensionConstraint: NSLayoutConstraint?
    
    var traces: [Trace]?
    var tracesBuffer: MTLBuffer?
    
    var points: [Point]?
    var pointsBuffer: MTLBuffer?
    
    var needsCopy: Bool = true
    
    var imagesBuffer: MTLBuffer?
    
    lazy var frameInput: FrameViewer = {
        let viewer = FrameViewer(MaxFrame: 0)
        viewer.executable = { Frame in
            self.uniform.frame = Frame
            self.editUniform()
        }
        return viewer
    }()
    
    lazy var settingsButton: NSButton = {
        let button = NSButton(image: NSImage(named: NSImage.actionTemplateName)!, target: self, action: #selector(toggleSettings))
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var settingsWindow: NSWindow?
    @objc func toggleSettings () {
        if let window = settingsWindow {
            if window.isVisible {
                window.close()
            }else {
                window.makeKeyAndOrderFront(self)
            }
        }else {
            settingsWindow = NSWindow(contentViewController: SettingsController())
            (settingsWindow!.contentViewController as! SettingsController).guiController = self
            settingsWindow?.setFrame(NSRect(x: view.frame.width, y: 0, width: 200, height: 400), display: false)
            settingsWindow!.title = "Settings"
            settingsWindow!.makeKeyAndOrderFront(self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.addSubview(imageHolder)
        imageHolder.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imageHolder.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        imageHolder.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        imageHolder.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30).isActive = true
        
        view.setFrameSize(NSSize(width: self.textures[0].width, height: self.textures[0].height + 30))
        
        library = device?.makeDefaultLibrary()
        commandQueue = device?.makeCommandQueue()
        
        if let Library = library {
            let vertexFunction = Library.makeFunction(name: "copyVertex")
            let fragmentFunction = Library.makeFunction(name: "copyFragment")
            let renderDescriptor = MTLRenderPipelineDescriptor()
            renderDescriptor.sampleCount = imageHolder.sampleCount
            renderDescriptor.vertexFunction = vertexFunction
            renderDescriptor.fragmentFunction = fragmentFunction
            renderDescriptor.colorAttachments[0].pixelFormat = imageHolder.colorPixelFormat;
            createHeap()
            moveResourcesToHeap(fragmentFunction!)
            do {
                self.renderPipeline = try device!.makeRenderPipelineState(descriptor: renderDescriptor)
            } catch {
                print(error)
            }
            
            do {
                self.copyFunction = Library.makeFunction(name: "copy")!
                self.copyPipeline = try device?.makeComputePipelineState(function: copyFunction!)
            }catch {
                print(error)
            }
            do {
                let drawFunction = Library.makeFunction(name: "draw")!
                self.drawPipeline = try device?.makeComputePipelineState(function: drawFunction)
            }catch {
                print(error)
            }
            
        }
        
        
        imageHolder.device = self.device
        imageHolder.delegate = self
        
        NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) {
            self.flagsChanged(with: $0)
            return $0
        }
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            self.keyDown(with: $0)
            return $0
        }
        
        view.addSubview(frameInput)
        frameInput.topAnchor.constraint(equalTo: self.imageHolder.bottomAnchor, constant: 5).isActive = true
        frameInput.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 5).isActive = true
        frameInput.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -55).isActive = true
        frameInput.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5).isActive = true
        
        view.addSubview(settingsButton)
        settingsButton.leftAnchor.constraint(equalTo: frameInput.rightAnchor, constant: 5).isActive = true
        settingsButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -5).isActive = true
        settingsButton.bottomAnchor.constraint(equalTo: frameInput.bottomAnchor).isActive = true
        settingsButton.topAnchor.constraint(equalTo: frameInput.topAnchor).isActive = true
    }
    
    var selectionType: SelectionType = .single {
        didSet {
            self.editUniform()
            (self.traceWindow.contentViewController as! TraceLayoutController).selectionCollectionView.collectionView.deselectAll(self)
            (self.traceWindow.contentViewController as! TraceLayoutController).selectionCollectionView.collectionView.selectItems(at: Set<IndexPath>(arrayLiteral: IndexPath(item: Int(self.selectionType.rawValue), section: 0)), scrollPosition: NSCollectionView.ScrollPosition.top)
        }
    }
    
    enum SelectionType: Int32 {
        case single
        case addition
        case subtraction
        case negative
    }
//    override func performKeyEquivalent(with event: NSEvent) -> Bool {
//        return true
//    }
    
    var startingPosition: SIMD2<Int32>?
    var endingPosition: SIMD2<Int32>? {
        didSet {
            if let position = self.endingPosition {
                self.uniform.selecting = true
                self.uniform.selectionCenter = (self.startingPosition! &+ position)/2
                self.uniform.selectionSize = abs(position &- self.startingPosition!)
            }else {
                self.uniform.selecting = false
                self.uniform.selectionCenter = SIMD2<Int32>(-1,-1)
                self.uniform.selectionSize = SIMD2<Int32>(0,0)
            }
            editUniform()
            if let _ = self.endingPosition {
                self.needsCopy = true
            }
        }
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

