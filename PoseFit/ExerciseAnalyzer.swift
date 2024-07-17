

import Foundation
import CoreGraphics
import MLKit
import CoreML


class ExerciseAnalyzer: ObservableObject {
    
    private var lastFeedbackTime = Date()
    @Published var feedbacks: [String] = []
    @Published var isUserInactive: Bool = false
    private var totalFeedbacks = 0
    private var positiveFeedbacks = 0
   
   

  

    var keyPointTriples: [(String, String, String)] = []
    var poses : [Pose] = []
    var shouldReset = false
    
    var thresholdValue = 150.0
    var angleThreshold = 5.0
 
    var exerciseName = ""
    var isDisabled: Bool = false
   
  
    var userAngles: [Double] = []
    var referenceAngles: [[Double]] = []
    
    var analysisTimer: Timer?
        let analysisInterval: TimeInterval = 5
   
    

    func calculateAngle(A: CGPoint, B: CGPoint, C: CGPoint) -> Double {
        let vectorAB = CGPoint(x: B.x - A.x, y: B.y - A.y)
        let vectorBC = CGPoint(x: C.x - B.x, y: C.y - B.y)
        
        let dotProduct = (vectorAB.x * vectorBC.x) + (vectorAB.y * vectorBC.y)
        let magnitudeAB = sqrt(pow(vectorAB.x, 2) + pow(vectorAB.y, 2))
        let magnitudeBC = sqrt(pow(vectorBC.x, 2) + pow(vectorBC.y, 2))
        
        let angleInRadians = acos(dotProduct / (magnitudeAB * magnitudeBC))
        let angleInDegrees = angleInRadians * (180.0 / .pi)
        
        return (180-angleInDegrees)
    }


 
    

   
    func loadReferenceData(forExercise exercise: Exercise) {
        
      
        referenceAngles = exercise.referenceAngles
        keyPointTriples = exercise.keyPointTriples
        exerciseName = exercise.name
        
     
        print(referenceAngles)
        
        print(keyPointTriples)
      
    }
    
    func addUserPose(pose: Pose) {
       
        if (exerciseName != "" ) && !(isDisabled) {
              var allTripletsAboveThreshold = true

              for (jointA, jointB, jointC) in keyPointTriples {
                  let landmarkTypeA = PoseLandmarkType(rawValue: jointA)
                  let landmarkTypeB = PoseLandmarkType(rawValue: jointB)
                  let landmarkTypeC = PoseLandmarkType(rawValue: jointC)

                  let landmarkA = pose.landmark(ofType: landmarkTypeA)
                  let landmarkB = pose.landmark(ofType: landmarkTypeB)
                  let landmarkC = pose.landmark(ofType: landmarkTypeC)

                  
                  if landmarkA.inFrameLikelihood <= 0.7 || landmarkB.inFrameLikelihood <= 0.7 || landmarkC.inFrameLikelihood <= 0.7 {
                      allTripletsAboveThreshold = false
                      break
                  }
              }

              if allTripletsAboveThreshold {
                  self.poses.append(pose)
                  print("Added")
              }
          
         
            
          
          
            DispatchQueue.global(qos: .userInteractive).async {
                if(self.exerciseName == "Plank")
                {
                    let currentTime = Date()
                    if currentTime.timeIntervalSince(self.lastFeedbackTime) >= 5.0 {
                        
                        self.analyzeExercise()
                        self.lastFeedbackTime = Date()
                        self.poses = []
                        
                    }
                }
                else{
                    self.analyzeExercise()
                }
              
                    
                 
                
                }
        }
    }
    func setShouldResetTrue()
    {
        shouldReset = true
        print("Reset request recieved!")
      
    }
    func resetPoses() {
        poses = []
    }
    
    
    
    func analyzeExercise() {
        let currentPoses = poses
        guard !currentPoses.isEmpty, !keyPointTriples.isEmpty else {
            print("Nincs elég adat az elemzéshez.")
           
            return
        }
        
        var newFeedbacks = [String]()
        var anglesUser: [[Double]] = []
        var filteredAnglesUser: [[Double]] = []
        
      

        for (i, (jointA, jointB, jointC)) in keyPointTriples.enumerated() {
          
            if !(i < referenceAngles.count)
            {
             
                continue
            }
          
            
            if !(currentPoses.count >= referenceAngles[i].count) {
             
                continue
            }
          

           let anglesForJointTriple  = currentPoses.map { pose -> Double in
                let landmarkA = pose.landmark(ofType: PoseLandmarkType(rawValue: jointA))
                let landmarkB = pose.landmark(ofType: PoseLandmarkType(rawValue: jointB))
                let landmarkC = pose.landmark(ofType: PoseLandmarkType(rawValue: jointC))
                let angle = calculateAngle(A: CGPoint(x: landmarkA.position.x, y: landmarkA.position.y),
                                           B: CGPoint(x: landmarkB.position.x, y: landmarkB.position.y),
                                           C: CGPoint(x: landmarkC.position.x, y: landmarkC.position.y))
                return angle
            }
            anglesUser.append(anglesForJointTriple)
           
        
         
            
            
            
        

           var  filteredAnglesForJointTriples = applyMedianFilter(sequence: anglesForJointTriple)
            filteredAnglesForJointTriples = filterAngles(sequence: filteredAnglesForJointTriples)
            
            filteredAnglesUser.append(filteredAnglesForJointTriples)
          
            
              
            
        }
        if exerciseName == "Plank"
        {
            
            for( i, fa) in filteredAnglesUser.enumerated() {
                
               
             
                 
                    let dtwDistance = computeDTWDistance(sequence1: referenceAngles[i], sequence2: fa)
                    let feedback = generateFeedback(angleDifference: dtwDistance, joints: keyPointTriples[i],index: i, filteredAnglesUser: filteredAnglesUser[i])
                    newFeedbacks.append(feedback)
                    
                    print("Referencia szögek: \(referenceAngles[i])")
                    print("Referencia szögek: \(referenceAngles[i])")
                    print("Felhasználói szögek: \(anglesUser[i])")
                    print("Szűrt felhasználói szögek: \(filteredAnglesUser[i])")
                    print("Kulcspontok: (\(keyPointTriples[i].0), \(keyPointTriples[i].1), \(keyPointTriples[i].2)), DTW Távolság: \(dtwDistance), Visszajelzés: \(feedback)")
                    
                
                    if !newFeedbacks.isEmpty {
                        
                        
                        DispatchQueue.main.async {
                            self.feedbacks = newFeedbacks
                        }
                     
                        print("RESET")
                        poses = []
                    }
                  
                    
                    
                
              
            }
        }

        else if shouldReset  {
          
            var occured = false
          
        
            for( i, fa) in filteredAnglesUser.enumerated() {
                
                //print(referenceAngles[i])
                //print(fa)
                //print(keyPointTriples[i])
                print(fa)
               
                //let trendChange = checkForTrendChange(in: fa, windowSize: 5) ?? false
                let similarityCheck = checkAngleSimilarityToReference(
                    userAngles: fa,
                    referenceAngles: referenceAngles[i],
                    windowSize: 3,
                    similarityThreshold: 40.0
                ) ?? false

                let refmax = referenceAngles[i].max()
                let refmin = referenceAngles[i].min()
                if (similarityCheck || refmax == refmin) {
                  
                 
                    let dtwDistance = computeDTWDistance(sequence1: referenceAngles[i], sequence2: fa)
                    let feedback = generateFeedback(angleDifference: dtwDistance, joints: keyPointTriples[i],index: i, filteredAnglesUser: fa)
                    newFeedbacks.append(feedback)
                    
                    print("Referencia szögek: \(referenceAngles[i])")
                   
                    print("Felhasználói szögek: \(anglesUser[i])")
                    print("Szűrt felhasználói szögek: \(fa)")
                    print("Kulcspontok: (\(keyPointTriples[i].0), \(keyPointTriples[i].1), \(keyPointTriples[i].2)), DTW Távolság: \(dtwDistance), Visszajelzés: \(feedback)")
                    
                    if(similarityCheck && !(refmax == refmin))
                    {
                        occured = true
                        
                    }

                    
                }
              
            }
            if(occured)
            {
                if !newFeedbacks.isEmpty  {
                   
                    DispatchQueue.main.async{
                     
                  
                        
                        self.feedbacks = newFeedbacks
                        print(self.feedbacks)
                    }
                    print("RESET")
                    shouldReset = false
                    poses = []
                    
                  
                   
                }
                
                
            }
        }
       
    }
    
    func checkAngleSimilarityToReference(userAngles: [Double], referenceAngles: [Double], windowSize: Int, similarityThreshold: Double) -> Bool? {
        guard !userAngles.isEmpty, !referenceAngles.isEmpty, userAngles.count >= windowSize, windowSize >= 1 else { return nil }

        let recentUserAngles = Array(userAngles.suffix(windowSize))
        let averageOfRecentUserAngles = recentUserAngles.reduce(0, +) / Double(recentUserAngles.count)
        let referenceFinalAngle = referenceAngles.last!

        return abs(averageOfRecentUserAngles - referenceFinalAngle) <= similarityThreshold
    }



    
    //WindowSize min 3
    func checkForTrendChange(in array: [Double], windowSize: Int) -> Bool? {
        guard array.count >= windowSize, windowSize >= 3 else { return nil }

        let recentValues = Array(array.suffix(windowSize))
        var trendChanges = 0

        for i in 2..<recentValues.count {
            if recentValues[i] > recentValues[i - 1] && recentValues[i - 1] < recentValues[i - 2] {
                trendChanges += 1
            } else if recentValues[i] < recentValues[i - 1] && recentValues[i - 1] > recentValues[i - 2] {
                trendChanges += 1
            }
        }

        return trendChanges > 0
    }



     
    func filterAngles(sequence: [Double], threshold: Double = 3.0) -> [Double] {
        guard !sequence.isEmpty else { return [] }

        var filteredSequence: [Double] = [sequence.first!] 
        var previousValue = sequence.first ?? 0

        for value in sequence.dropFirst() {
            if abs(value - previousValue) > threshold {
                filteredSequence.append(value)
                previousValue = value
            }
        }

        return filteredSequence
    }
    
    func calculatePerformancePercentage() -> Double {
            return (Double(positiveFeedbacks) / Double(totalFeedbacks)) * 100.0
        }

     
    func resetPerformanceTracking() {
            totalFeedbacks = 0
            positiveFeedbacks = 0
        }


   
    func applyMedianFilter(sequence: [Double]) -> [Double] {
          let filterSize = 3
          let halfSize = filterSize / 2
          var filteredSequence = [Double]()

          for i in 0..<sequence.count {
              var window = [Double]()

              for j in -halfSize...halfSize {
                  let index = i + j
                  if index >= 0 && index < sequence.count {
                      window.append(sequence[index])
                  }
              }

              let medianValue = window.sorted(by: <)[window.count / 2]
              filteredSequence.append(medianValue)
          }

          return filteredSequence
      }


    private func computeDTWDistance(sequence1: [Double], sequence2: [Double]) -> Double {
        guard !sequence1.isEmpty && !sequence2.isEmpty else {
            print("One or both of the sequences are empty.")
            return Double.greatestFiniteMagnitude
        }

        let sequence1Length = sequence1.count
        let sequence2Length = sequence2.count
        var dtwMatrix = Array(repeating: Array(repeating: Double.greatestFiniteMagnitude, count: sequence2Length + 1), count: sequence1Length + 1)
        dtwMatrix[0][0] = 0

     
        for i in 1...sequence1Length {
            for j in 1...sequence2Length {
                let cost = abs(sequence1[i - 1] - sequence2[j - 1])
                dtwMatrix[i][j] = cost + min(dtwMatrix[i-1][j], dtwMatrix[i][j-1], dtwMatrix[i-1][j-1])
            }
        }

      
        let finalDistance = dtwMatrix[sequence1Length][sequence2Length]
             
        return finalDistance
    }


   

     func generateFeedback(angleDifference: Double, joints: (String,String,String), index: Int, filteredAnglesUser: [Double]) -> String {
        totalFeedbacks += 1
         
         let side = joints.0.contains("Left") ? "bal" : "jobb"
        
        if exerciseName == "Fekvőtámasz" {
            
               if joints == ("RightShoulder", "RightElbow", "RightWrist") || joints == ("LeftShoulder", "LeftElbow", "LeftWrist") {
                   
               
                   
                   if angleDifference > thresholdValue {
                       let userMinAngle = filteredAnglesUser.min() ?? 0
                          let referenceMinAngle = referenceAngles[index].min() ?? 0
                          let tolerance = 20.0

                          if userMinAngle > referenceMinAngle + tolerance {
                              return "Hajlítsd jobban a karodat!"
                          } else if userMinAngle < referenceMinAngle - tolerance*2 {
                              return "Ne menj túl mélyre!"
                          } else {
                              positiveFeedbacks += 1
                              return "Jó a karhajlításod!"
                          }
                       
                       
                   } else {
                       positiveFeedbacks += 1
                       return "Jó a karhajlításod!"
                   }
               }
            if joints == ("LeftAnkle", "LeftHip", "LeftShoulder") || joints ==  ("RightAnkle", "RightHip", "RightShoulder"){
                if angleDifference > thresholdValue {
                    
                  
                    let userMaxAngle = filteredAnglesUser.max() ?? 180
                    let referenceMaxAngle = referenceAngles[index].max() ?? 180
                    
                       let tolerance = 15.0

                    if angleDifference > thresholdValue {
                         if userMaxAngle < referenceMaxAngle - tolerance {
                            return "Tartsd egyenesen a törzsed!"
                        } else {
                            positiveFeedbacks += 1
                            return "Jó a csípőmagasságod!"
                        }
                    }
                     
                    
                } else {
                    positiveFeedbacks += 1
                    return "Jó a csípőmagasságod!"
                }
            }
            if joints ==  ("LeftHip", "LeftKnee", "LeftAnkle") || joints ==  ("RightHip", "RightKnee", "RightAnkle"){
                if angleDifference > thresholdValue {
                    
                  
                    let userMaxAngle = filteredAnglesUser.max() ?? 180
                    let referenceMaxAngle = referenceAngles[index].max() ?? 180
                    
                       let tolerance = 15.0

                    if angleDifference > thresholdValue {
                         if userMaxAngle < referenceMaxAngle - tolerance {
                            return "Tartsd egyenesen a lábaid!"
                        } else {
                            positiveFeedbacks += 1
                            return "Jól tartod a lábaid!"
                        }
                    }
                     
                    
                } else {
                    positiveFeedbacks += 1
                    return "Jól tartod a lábaid!"
                }
            }
            
            
            
           }
        if exerciseName == "Guggolás" {
               if joints == ("LeftHip", "LeftKnee", "LeftAnkle") || joints == ("RightHip", "RightKnee", "RightAnkle") {
                   if angleDifference > thresholdValue {
                       let userMinAngle = filteredAnglesUser.min() ?? 0
                          let referenceMinAngle = referenceAngles[index].min() ?? 0
                          let tolerance = 40.0

                          if userMinAngle > referenceMinAngle + tolerance {
                              return "Mélyebbre kell guggolnod!"
                          } else if userMinAngle < referenceMinAngle - tolerance  {
                              return "Ne guggolj túl mélyre!"
                          } else {
                              positiveFeedbacks += 1
                              return "Jól csinálod a guggolást!"
                          }
                   } else {
                       positiveFeedbacks += 1
                       return "Jól csinálod a guggolást!"
                   }
               }
           }
        if exerciseName == "Felülés" {
            if joints == ("LeftShoulder", "LeftHip", "LeftAnkle") || joints == ("RightShoulder", "RightHip", "RightAnkle") {
                let userMinAngle = filteredAnglesUser.min() ?? 0
                let userMaxAngle = filteredAnglesUser.max() ?? 180
                let referenceMinAngle = referenceAngles[index].min() ?? 0
                let referenceMaxAngle = referenceAngles[index].max() ?? 180
                let tolerance = 30.0
                
                if angleDifference > thresholdValue {
                    if userMinAngle > referenceMinAngle + tolerance {
                        return "Emelkedj magasabbra!"
                    } else if userMaxAngle < referenceMaxAngle - tolerance {
                        return "Ereszd le a törzsed teljesen!"
                    } else {
                        positiveFeedbacks += 1
                        return "Jól végzed a felüléseket!"
                    }
                } else {
                    positiveFeedbacks += 1
                    return "Jól végzed a felüléseket!"
                }
            }
            else if joints == ("LeftHip", "LeftKnee", "LeftAnkle") || joints == ("RightHip", "RightKnee", "RightAnkle") {
                let userMinAngle = filteredAnglesUser.min() ?? 0
                let userMaxAngle = filteredAnglesUser.max() ?? 180
                let referenceMinAngle = referenceAngles[index].min() ?? 0
                let referenceMaxAngle = referenceAngles[index].max() ?? 180
                let tolerance = 15.0
                if angleDifference > thresholdValue {
                    if userMinAngle > referenceMinAngle + tolerance {
                        return "Ne hajlítsd ennyire a lábad!"
                    } else if userMaxAngle < referenceMaxAngle - tolerance {
                        return "Hajlítsd jobban a lábad!"
                    } else {
                        positiveFeedbacks += 1
                        return "Jól tartod a lábad!"
                    }
                }
                else{
                    positiveFeedbacks += 1
                    return "Jól tartod a lábad!"
                }
                
            }
        }
         if exerciseName == "Felhúzás" {
             
             if joints == ("RightShoulder", "RightElbow", "RightWrist") || joints == ("LeftShoulder", "LeftElbow", "LeftWrist") {
                 
                 let userMinAngle = filteredAnglesUser.min() ?? 0
                 let referenceMinAngle = referenceAngles[index].min() ?? 0
                 let tolerance = 20.0
                 
                 if angleDifference > thresholdValue {
                     if userMinAngle > referenceMinAngle + tolerance  {
                         
                         return "Húzd fel magad magasabbra!"
                     } else {
                         positiveFeedbacks += 1
                         return "Jól csinálod!"
                     }
                 }
                 positiveFeedbacks += 1
                 return "Jól csinálod!"
             }
         }

        if exerciseName == "Plank" {
            if joints == ("LeftShoulder", "LeftHip", "LeftKnee") || joints == ("RightShoulder", "RightHip", "RightKnee") {
                    let averageAngle = filteredAnglesUser.reduce(0, +) / Double(filteredAnglesUser.count)

                      let referenceMaxAngle = referenceAngles[index].max() ?? 0
                let tolerance = 10.0
                
                      if angleDifference > thresholdValue {
                           if averageAngle < referenceMaxAngle - tolerance {
                              return "Tartsd egyenesen a törzsed!"
                          } else {
                              positiveFeedbacks += 1
                              return "Nagyszerű plank tartás!"
                          }
                      }
             else {
                positiveFeedbacks += 1
                return "Nagyszerű plank tartás!"
            }
                  }

            }
        
        
           
           if angleDifference < thresholdValue {
               positiveFeedbacks += 1
               return "Szép munka, csak így tovább!"
               
           } else {
               return "Javíts a helyzeteden!"
           }
    }

}
