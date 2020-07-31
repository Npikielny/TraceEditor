//
//  TraceLayoutController.swift
//  TraceEditor
//
//  Created by Noah Pikielny on 7/30/20.
//  Copyright © 2020 Noah Pikielny. All rights reserved.
//

import Cocoa

class TraceLayoutController: NSViewController {
    
    var guiController: GUIController
    
    lazy var traceCollectionView: TraceCollectionView = TraceCollectionView(Controller: self.guiController)
    var selectionCollectionView = SelectionTypeCollectionView()
    
    init(guiController: GUIController) {
        self.guiController = guiController
        super.init(nibName: "TraceLayoutController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(traceCollectionView)
        traceCollectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
        traceCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        traceCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        traceCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        view.addSubview(selectionCollectionView)
        selectionCollectionView.bottomAnchor.constraint(equalTo: traceCollectionView.topAnchor).isActive = true
        selectionCollectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        selectionCollectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        selectionCollectionView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    }
    
}

class ResizingCollectionView: NSCollectionView {
  override var frame: NSRect {
    didSet {
      collectionViewLayout?.invalidateLayout()
    }
  }
}
