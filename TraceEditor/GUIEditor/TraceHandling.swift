//
//  TraceHandling.swift
//  TraceEditor
//
//  Created by Noah Pikielny on 7/24/20.
//  Copyright © 2020 Noah Pikielny. All rights reserved.
//

import Foundation

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
    case OligoProcess = 0
    case NG2Process = 1
    case Axon = 2
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
    
    func isFloat(_ text: String) -> Bool {
        if let _ = Float(text) {
            return true
        }else {
            return false
        }
    }

    func getTraces(_ FilePath: String) throws -> ([Trace],[Point]) {
        var traces = [Trace]()
        var points = [Point]()
        do {
            let contents = try String(contentsOfFile: FilePath)
            let rows = contents.split(separator: "\r\n").map({String($0)})
            var itemsInRows = (rows.map({$0.split(separator: " ")}))
            itemsInRows.removeAll(where: {isFloat(String($0[0])) == false})
            itemsInRows.removeAll(where: {$0.count < 7})
            let validItems = itemsInRows.map({$0.map({Float($0)!})})
            points = validItems.map({Point(n: Int32($0[0]),
                                           type: Int32($0[1]),
                                           position: SIMD3<Float>($0[2],$0[3],$0[4]),
                                           radius: $0[5],
                                           parent: Int32($0[6]))})
            var traceIndex: Int32 = -1
            var lastType: Int32 = points[0].type
            for i in 0..<points.count {
                if points[i].parent == -1 {
                    traceIndex += 1
                    traces.append(Trace(index: traceIndex, type: lastType))
                }
                points[i].trace = traceIndex
                lastType = points[i].type
            }
        } catch {
            throw error
            // contents could not be loaded
        }
        
        return (traces, points)
    }
    
    func loadTraces(_ FilePath: String) {
        do {
            let data = try getTraces(FilePath)
            self.traces = data.0
            self.tracesBuffer = device!.makeBuffer(bytes: data.0, length: MemoryLayout<Trace>.stride*data.0.count, options: .storageModeShared)!
            self.points = data.1
            self.pointsBuffer = device?.makeBuffer(bytes: data.1, length: MemoryLayout<Point>.stride*data.1.count, options: .storageModeManaged)
        } catch {
            print(error)
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
            print("TC:",Traces.count)
            var deletedTraces: [Int32: Int32] = [:]
            for i in Traces {
                deletedTraces[i.index] = Int32(self.points!.filter({$0.trace == i.index}).count)
            }
            self.traces?.removeAll(where: {checkingTrace in
                Traces.contains(where: {$0.index == checkingTrace.index})
            })
            for i in 0..<self.traces!.count {
                self.traces![i].index = Int32(i)
            }
            self.points?.removeAll(where: { deletingPoint in Traces.contains(where: {$0.index == deletingPoint.trace})})
            
            for i in 0..<self.points!.count {
                self.points![i].n = Int32(i+1)
                if self.points![i].parent != -1 {
                    self.points![i].parent -= deletedTraces.map({($0.key < self.points![i].trace) ? $0.value : 0}).reduce(0, +)
                }
                self.points![i].trace -= deletedTraces.map({($0.key < self.points![i].trace) ? 1 : 0}).reduce(0, +)
            }
            memcpy(self.tracesBuffer?.contents(), self.traces, MemoryLayout<Trace>.stride*self.traces!.count)
//            memcpy(self.pointsBuffer?.contents(), self.points, MemoryLayout<Point>.stride*self.points!.count)
//            self.pointsBuffer = device?.makeBuffer(bytes: self.points!, length: MemoryLayout<Point>.stride*self.points!.count, options: .storageModeManaged)
            self.pointsBuffer?.didModifyRange(0..<self.pointsBuffer!.length)
            
//            self.uniform = Uniform(kernelWidth: Int32(ceil(pow(Float(PointCount),0.5))), dimensions: Dimensions, imageSize: SIMD3<Float>(Float(self.presentingImage!.width), Float(self.presentingImage!.height), Float(self.textures.count)), selectionType: self.selectionType.rawValue)
            self.uniform.kernelWidth = Int32(ceil(pow(Float(self.points!.count),0.5)))
            self.uniform.pointCount = Int32(self.points!.count)
            memcpy(self.uniformBuffer!.contents(), [self.uniform], MemoryLayout<Uniform>.stride)
            self.uniformBuffer?.didModifyRange(0..<self.uniformBuffer!.length)
            
////            var deletedPoints: Int32 = 0
////            for i in 0..<self.points!.count {
////                if Traces.contains(where: {self.points![i-Int(deletedPoints)].trace == $0.index}) {
////                    self.points!.remove(at: i - Int(deletedPoints))
////                    deletedPoints += 1
////                }else {
////                    self.points![i-Int(deletedPoints)].n -= deletedPoints
////                    if self.points![i-Int(deletedPoints)].parent > 0 {
////                        self.points![i-Int(deletedPoints)].parent -= deletedPoints
////                    }
////                    self.points![i-Int(deletedPoints)].trace -= Traces.map({ deletingTrace in
////                        if deletingTrace.index < self.points![i-Int(deletedPoints)].trace {
////                            return Int32(1)
////                        }else {
////                            return Int32(0)
////                        }
////                    }).reduce(0,+)
////                }
////            }
//
//
//
//            self.traces?.removeAll(where: {mainTrace in Traces.contains(where: {deletionTrace in deletionTrace.index == mainTrace.index})})
//            for i in 0..<traces!.count {
//                self.traces![i].index = Int32(i)
//            }
//
//            memcpy(self.pointsBuffer?.contents(), self.points!, MemoryLayout<Point>.stride*self.points!.count)
//            self.pointsBuffer?.didModifyRange(0..<self.pointsBuffer!.length)
//            if self.points!.count > 0 {
//                self.pointsBuffer = device?.makeBuffer(bytes: self.points!, length: MemoryLayout<Point>.stride*self.points!.count, options: .storageModeManaged)
//                self.pointsBuffer?.didModifyRange(0..<self.pointsBuffer!.length)
//            }

//            memcpy(self.tracesBuffer?.contents(), self.traces!, MemoryLayout<Trace>.stride*self.traces!.count)
//            self.tracesBuffer?.didModifyRange(0..<self.tracesBuffer!.length)
        }
    }
}
