//
//  ReferenceExerciseManager.swift
//  PoseGym
//
//  Created by Kiss Roland on 06/11/2023.
//

import Foundation
import UIKit

struct Landmark {
    var frameLabel: Double
    var positions: [CGPoint]
}

class ReferenceExerciseManager {
    var landmarks: [Landmark] = []

    func loadCSV(from filename: String) {
        let subdirectory = "ReferenceExercisesCSV"
            guard let path = Bundle.main.path(forResource: filename, ofType: "csv") else {
                print("A CSV fájl nem található a(z) \(subdirectory)/\(filename).csv helyen.")
                return
            }
        
        do {
            let content = try String(contentsOfFile: path, encoding: .utf8)
            let rows = content.components(separatedBy: .newlines)
            
            for (index, row) in rows.enumerated() {
                if index == 0 || row == "" { continue }
                
                let columns = row.components(separatedBy: ",")
                guard columns.count > 2, let frameLabel = Double(columns[0]) else {
                    print("Hiba az adatok formázásában a \(index). sorban.")
                    continue
                }
                
                var positions: [CGPoint] = []
                for i in stride(from: 1, to: columns.count, by: 3) {
                    if let x = Double(columns[i]), let y = Double(columns[i + 1]) {
                        positions.append(CGPoint(x: x, y: y))
                    }
                }
                
                let landmark = Landmark(frameLabel: frameLabel, positions: positions)
                landmarks.append(landmark)
            }
        } catch {
            print("Hiba történt a fájl beolvasása során: \(error)")
        }
    }
    
  
    func getReferenceLandmarks(from filename: String) -> [[CGPoint]] {
        loadCSV(from: filename)
        return landmarks.map { $0.positions }
    }
}

