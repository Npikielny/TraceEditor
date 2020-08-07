//
//  EditNeuronController.swift
//  TraceEditor
//
//  Created by Noah Pikielny on 8/2/20.
//  Copyright © 2020 Noah Pikielny. All rights reserved.
//

import Cocoa

class EditNeuronController: NSViewController, NSCollectionViewDelegate, NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout{
    
    var selectedCount: Int {
        didSet {
            neuronIndexText.string = "Neuron Count: \(self.selectedCount)"
        }
    }
    
    var mainEditor: TraceLayoutController
    
    init(_ count: Int, SuperController: TraceLayoutController) {
        selectedCount = count
        self.mainEditor = SuperController
        
        super.init(nibName: "EditNeuronController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var neuronIndexText: NSText = {
        let text = NSTextView()
        text.isEditable = false
        text.isSelectable = false
        text.backgroundColor = NSColor.clear
        text.alignment = .center
        text.string = "Neuron Count: \(selectedCount)"
        return text
    }()
    
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
        return collectionView
    }()
    
    lazy var setTypeButton: NSButton = {
        let button = NSButton(title: "Set Type", target: self, action: #selector(setType))
        return button
    }()
    
    @objc func setType() {
        if let selection = self.selectionType {
            mainEditor.setNeuronType(Type: Int32(selection))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        [neuronIndexText, collectionView, setTypeButton].forEach({
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        neuronIndexText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        neuronIndexText.topAnchor.constraint(equalTo: view.topAnchor, constant: 5).isActive = true
        neuronIndexText.heightAnchor.constraint(equalToConstant: 15).isActive = true
        neuronIndexText.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        collectionView.topAnchor.constraint(equalTo: neuronIndexText.bottomAnchor, constant: 5).isActive = true
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30).isActive = true
        
        setTypeButton.topAnchor.constraint(greaterThanOrEqualTo: collectionView.bottomAnchor, constant: 5).isActive = true
        setTypeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        setTypeButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5).isActive = true
    }
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let selectionTypes = ["Oligodendrocyte", "NG2 Progenitor", "Neuron", "Undefined"]
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
    
    var selectionType: Int?
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
//        selectionType = indexPaths.first.item
        if let selectedCell = indexPaths.first {
            selectionType = selectedCell.item
        }
        
    }
    func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
        self.selectionType = nil
    }
    
}
