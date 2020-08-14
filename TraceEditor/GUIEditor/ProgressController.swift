//
//  ProgressController.swift
//  TraceEditor
//
//  Created by Noah Pikielny on 8/10/20.
//  Copyright © 2020 Noah Pikielny. All rights reserved.
//

import Cocoa

class ProgressController: NSViewController {

    convenience init () {
        self.init(nibName: "ProgressController", bundle: nil)
    }
    
    var titleText: NSTextView = {
        let tv = NSTextView()
        tv.string = "Title"
        tv.backgroundColor = NSColor.clear
        tv.alignment = .center
        tv.isSelectable = false
        tv.isEditable = false
        tv.font = NSFont.boldSystemFont(ofSize: 30)
        return tv
    }()
    
    var progressBar: NSProgressIndicator = {
//        let indicator = NSProgressIndicator()
//        indicator.doubleValue = 0
//        indicator.controlSize = .regular
//        indicator.minValue = 0
//        indicator.maxValue = 1
//        indicator.usesThreadedAnimation = true
//        return indicator
        let bar = NSProgressIndicator()
        bar.minValue = 0
        bar.maxValue = 1
        bar.doubleValue = 0.0
        bar.isBezeled = true
        bar.isIndeterminate = false
        return bar
    }()
    
    var progressText: NSTextView = {
        let tv = NSTextView()
        tv.string = "Task"
        tv.backgroundColor = NSColor.clear
        tv.alignment = .center
        tv.isSelectable = false
        tv.isEditable = false
        return tv
    }()
    func toIncrement(Progress: Double) {
        progressBar.doubleValue = Progress
    }
    
    func increment(Task: String, Progress: Double) {
        progressText.string = Task
        progressBar.increment(by: Progress)
    }
    
    func newTask(Title: String, Task: String, Progress: Double) {
        titleText.string = Title
        progressText.string = Task
        progressBar.increment(by: Progress)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        [titleText, progressBar, progressText].forEach({
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        })
        
        titleText.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        titleText.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        titleText.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        progressBar.topAnchor.constraint(greaterThanOrEqualTo: titleText.bottomAnchor, constant: 20).isActive = true
        progressBar.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20).isActive = true
        progressBar.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        progressText.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 5).isActive = true
        progressText.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        progressText.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
}
