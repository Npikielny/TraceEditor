//
//  TraceHandling.swift
//  TraceEditor
//
//  Created by Noah Pikielny on 7/24/20.
//  Copyright © 2020 Noah Pikielny. All rights reserved.
//

import Cocoa

struct Trace {
    var index: Int32
    var selected: Bool = false
    var type: Int32
    var parent: Int32 = -1
    func getType() -> TraceType {
        return TraceType(rawValue: self.type) ?? .Undefined
    }
}

enum TraceType: Int32 {
    case CellBody = 0
    case ProximalProcess = 1
    case Sheath = 2
    case Undefined = 3
}

struct Point {
    var n: Int32
    var type: Int32
    var position: SIMD3<Float>
    var radius: Float
    var parent: Int32
    var trace: Int32 = 0
    func getType() -> TraceType {
        return TraceType(rawValue: self.type) ?? .Undefined
    }
}

extension GUIController {

    func addTraces(_ Traces: [Trace]?, _ Points: [Point]?) {
        if let UNWPTraces = Traces, let UNWPPoints = Points {
            self.traces = Traces
            self.points = Points
            self.tracesBuffer = device?.makeBuffer(bytes: UNWPTraces, length: MemoryLayout<Trace>.stride * UNWPTraces.count, options: .storageModeShared)
            self.pointsBuffer = device?.makeBuffer(bytes: UNWPPoints, length: MemoryLayout<Point >.stride * UNWPPoints.count, options: .storageModeManaged)
        }
    }
    
    func editTraces(_ Type: Int32) {
        if let _ = self.traces {
            let Traces = self.traces!.filter({$0.selected})
            for i in Traces.map({$0.index}) {
                self.traces![Int(i)].type = Type
            }
        }
    }
    
    func deleteTrace() {
        if let _ = self.traces, let _ = self.points {
            let Traces = self.traces!.filter({$0.selected})
//            Traces.removeAll(where: {$0.selected == false})
            var deletedTraces: [Int32: Int32] = [:]
            for i in Traces {
                deletedTraces[i.index] = Int32(self.points!.filter({$0.trace == i.index}).count)
            }
            
            self.points?.removeAll(where: { deletingPoint in Traces.contains(where: {$0.index == deletingPoint.trace})})
            
            for i in 0..<self.points!.count {
                self.points![i].n = Int32(i+1)
                if self.points![i].parent != -1 {
                    self.points![i].parent -= deletedTraces.map({($0.key < self.points![i].trace) ? $0.value : 0}).reduce(0, +)
                }
                self.points![i].trace -= deletedTraces.map({($0.key < self.points![i].trace) ? 1 : 0}).reduce(0, +)
            }
            
            self.traces?.removeAll(where: {checkingTrace in
                Traces.contains(where: {$0.index == checkingTrace.index})
            })
            
            for i in 0..<self.traces!.count {
                self.traces![i].index = Int32(i)
            }
            
            
            memcpy(self.tracesBuffer?.contents(), self.traces, MemoryLayout<Trace>.stride*self.traces!.count)
            
            memcpy(self.pointsBuffer?.contents(), self.points, MemoryLayout<Point>.stride*self.points!.count)
            
            self.pointsBuffer?.didModifyRange(0..<self.pointsBuffer!.length)
            
            self.uniform.kernelWidth = Int32(ceil(pow(Float(self.points!.count),0.5)))
            self.uniform.pointCount = Int32(self.points!.count)
            memcpy(self.uniformBuffer!.contents(), [self.uniform], MemoryLayout<Uniform>.stride)
            self.uniformBuffer?.didModifyRange(0..<self.uniformBuffer!.length)
        }
    }
}
