//
//  TraceHandling.swift
//  TraceEditor
//
//  Created by Noah Pikielny on 7/24/20.
//  Copyright © 2020 Noah Pikielny. All rights reserved.
//

import Foundation
extension GUIController {
    struct Trace {
        var index: Int32
        var selected: Bool = false
    }

    struct Point {
        var n: Int32
        var type: Int32
        var position: SIMD3<Float>
        var radius: Float
        var parent: Int32
        var trace: Int32 = 0
    }

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
            for i in 0..<points.count {
                if points[i].parent == -1 {
                    traceIndex += 1
                    traces.append(Trace(index: traceIndex))
                }
                points[i].trace = traceIndex
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
            self.tracesBuffer = device!.makeBuffer(bytes: data.0, length: MemoryLayout<Trace>.stride*data.0.count, options: .storageModeManaged)!
            self.points = data.1
            self.pointsBuffer = device?.makeBuffer(bytes: data.1, length: MemoryLayout<Point>.stride*data.1.count, options: .storageModeManaged)
        } catch {
            print(error)
        }
    }
}
