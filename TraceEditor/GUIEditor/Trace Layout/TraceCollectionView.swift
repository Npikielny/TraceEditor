//
//  TraceCollectionView.swift
//  TraceEditor
//
//  Created by Noah Pikielny on 7/31/20.
//  Copyright © 2020 Noah Pikielny. All rights reserved.
//

import Cocoa

class TraceCollectionView: NSView, NSCollectionViewDelegate, NSCollectionViewDelegateFlowLayout, NSCollectionViewDataSource {
    var controller: GUIController
    

    lazy var scrollView: NSScrollView = {
        let scroll = NSScrollView()
        return scroll
    }()
    
    lazy var collectionView: ResizingCollectionView = {
        let collectionView = ResizingCollectionView()
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        collectionView.register(TraceLayoutCell.self, forItemWithIdentifier: TraceLayoutCell.reuseIdentifier)
        
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.sectionInset = NSEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 2
        
        collectionView.collectionViewLayout = flowLayout
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.allowsMultipleSelection = true
        collectionView.isSelectable = true
        
        collectionView.register(TraceLayoutCell.self, forItemWithIdentifier: TraceLayoutCell.reuseIdentifier)
        return collectionView
    }()
    
    init(Controller: GUIController) {
        self.controller = Controller
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        [scrollView].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        })
        scrollView.documentView = collectionView
//        traceCollectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
//        traceCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
//        traceCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
//        traceCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        scrollView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalToConstant: 400).isActive = true
        scrollView.heightAnchor.constraint(greaterThanOrEqualToConstant: 150).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return controller.traces!.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: TraceLayoutCell.reuseIdentifier, for: indexPath) as! TraceLayoutCell
        item.number.string = String(indexPath.item)
        switch controller.traces![indexPath.item].getType() {
        case .OligoProcess:
            item.type.string = "Oligo"
        case .NG2Process:
            item.type.string = "NG2"
        case .Axon:
            item.type.string = "Axon"
        default:
            item.type.string = "Undefined"
        }
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        return NSSize(width: collectionView.frame.width-50, height: 20)
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        let pointer = self.controller.tracesBuffer!.contents()
        for i in indexPaths {
            self.controller.traces![i.item].selected = true
            memcpy(pointer + MemoryLayout<Trace>.stride*i.item, [controller.traces![i.item]], MemoryLayout<Trace>.stride)
        }
    }
    func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
        let pointer = self.controller.tracesBuffer!.contents()
        for i in indexPaths {
            self.controller.traces![i.item].selected = false
            memcpy(pointer + MemoryLayout<Trace>.stride*i.item, [controller.traces![i.item]], MemoryLayout<Trace>.stride)
        }
    }
}
