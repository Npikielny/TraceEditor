//
//  SelectionTypeCollectionView.swift
//  TraceEditor
//
//  Created by Noah Pikielny on 7/31/20.
//  Copyright © 2020 Noah Pikielny. All rights reserved.
//

import Cocoa


class SelectionTypeCollectionView: NSView, NSCollectionViewDelegate, NSCollectionViewDelegateFlowLayout, NSCollectionViewDataSource {
    
    lazy var collectionView: ResizingCollectionView = {
        let collectionView = ResizingCollectionView()
        
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 5
        flowLayout.sectionInset = NSEdgeInsets(top: 0, left: 25, bottom: 0, right: 25 + 15)
        collectionView.collectionViewLayout = flowLayout
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.allowsMultipleSelection = false
        collectionView.isSelectable = true
        
        collectionView.register(SelectionTypeItem.self, forItemWithIdentifier: SelectionTypeItem.reuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    init() {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let selectionTypes = ["Single", "Addition", "Subtraction", "Negative"]
        let item = collectionView.makeItem(withIdentifier: SelectionTypeItem.reuseIdentifier, for: indexPath) as! SelectionTypeItem
        if indexPath.item == 0 {
            item.view.layer?.cornerRadius = 15
            item.view.layer?.masksToBounds = true
            item.view.layer?.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        }else if indexPath.item == 3 {
            item.view.layer?.cornerRadius = 15
            item.view.layer?.masksToBounds = true
            item.view.layer?.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        }
        item.selectionTypeText.string = selectionTypes[indexPath.item]
        return item
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        return NSSize(width: (collectionView.frame.width - 5 * 3 - 50 - 15) / 4, height: collectionView.frame.height - 10)
    }
}

