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
    
    lazy var editButton: NSButton = {
        let button = NSButton(title: "Edit Neurons", target: self, action: #selector(editNeurons))
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    @objc func editNeurons() {
        if let traces = self.guiController.traces {
            if traces.contains(where: {$0.selected}) {
                let selectedCount = traces.filter({$0.selected}).count
                let window = NSWindow(contentViewController: EditNeuronController(selectedCount, SuperController: self))
                window.title = "Neuron Editor"
                window.makeKeyAndOrderFront(self)
            }
        }
    }
    
    func setNeuronType(Type: Int32) { // Called From EditNeuronController
        self.guiController.editTraces(Type)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(editButton)
        editButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        editButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 5).isActive = true
        
        view.addSubview(selectionCollectionView)
        selectionCollectionView.topAnchor.constraint(equalTo: editButton.bottomAnchor, constant: 5).isActive = true
        selectionCollectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        selectionCollectionView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        selectionCollectionView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        view.addSubview(traceCollectionView)
        traceCollectionView.topAnchor.constraint(equalTo: selectionCollectionView.bottomAnchor).isActive = true
        traceCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        traceCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        traceCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
}

class ResizingCollectionView: NSCollectionView {
  override var frame: NSRect {
    didSet {
      collectionViewLayout?.invalidateLayout()
    }
  }
}
