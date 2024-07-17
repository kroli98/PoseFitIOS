import Foundation
import CoreGraphics
import MLKit

class RepetitionCounter: ObservableObject {
    
    
   
    enum ExerciseState {
        case start
        case middle
        case finished
    }

    var exercise: Exercise
    var currentState: ExerciseState = .start
    @Published var repCounter = 0
    var isDisabled: Bool = false
    var threshold: Float = 0.7
    

    init(exercise: Exercise) {
        self.exercise = exercise
      
    }

    func processPose(_ pose: Pose)  {
        if(!isDisabled)
        {
            if (exercise.name == "Fekvőtámasz")
            {
                processPushups(from: pose)
            }
            else if(exercise.name == "Guggolás")
            {
                processSquats(from: pose)
            }
            else if(exercise.name == "Felülés")
            {
                processSitups(from: pose)
            }
            else if(exercise.name == "Felhúzás")
            {
                processPullUps(from: pose)
            }
           
        }
        
    }
    func updateExercise(newExercise: Exercise) {
            self.exercise = newExercise
            self.repCounter = 0
            self.currentState = .start
      
        }

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
    func processSitups(from pose: Pose) {
        let startEndAngle: Double = 170.0
        let middleAngle: Double = 160.0
        let rightShoulder = pose.landmark(ofType: .rightShoulder)
        let rightHip = pose.landmark(ofType: .rightHip)
        let rightAnkle = pose.landmark(ofType: .rightAnkle)
        let leftShoulder = pose.landmark(ofType: .leftShoulder)
        let leftHip = pose.landmark(ofType: .leftHip)
        let leftAnkle = pose.landmark(ofType: .leftAnkle)

        if (rightShoulder.inFrameLikelihood > threshold &&
            rightHip.inFrameLikelihood > threshold &&
            rightAnkle.inFrameLikelihood > threshold &&
            leftShoulder.inFrameLikelihood > threshold &&
            leftHip.inFrameLikelihood > threshold &&
            leftAnkle.inFrameLikelihood > threshold) {

            let right_shoulder_hip_ankle_angle = calculateAngle(
                A: CGPoint(x: rightShoulder.position.x, y: rightShoulder.position.y),
                B: CGPoint(x: rightHip.position.x, y: rightHip.position.y),
                C: CGPoint(x: rightAnkle.position.x, y: rightAnkle.position.y)
            )
            
            let left_shoulder_hip_ankle_angle = calculateAngle(
                A: CGPoint(x: leftShoulder.position.x, y: leftShoulder.position.y),
                B: CGPoint(x: leftHip.position.x, y: leftHip.position.y),
                C: CGPoint(x: leftAnkle.position.x, y: leftAnkle.position.y)
            )
          

            let avg_angle = (right_shoulder_hip_ankle_angle + left_shoulder_hip_ankle_angle) / 2.0
            

            switch currentState {
            case .start:
                if avg_angle <= middleAngle {
                    currentState = .middle
                }
            case .middle:
                if avg_angle >= startEndAngle {
                    currentState = .finished
                }
            case .finished:
                if avg_angle > middleAngle {
                    repCounter += 1
                    currentState = .start
                    print("Repetition count: \(repCounter)")
                } else if avg_angle >= startEndAngle {
                    currentState = .middle
                }
            }
        }
    }

   

    func processSquats(from pose: Pose) {
        let completedAngle: Double = 150.0
        let rightHip = pose.landmark(ofType: .rightHip)
        let rightKnee = pose.landmark(ofType: .rightKnee)
        let rightAnkle = pose.landmark(ofType: .rightAnkle)
        let leftHip = pose.landmark(ofType: .leftHip)
        let leftKnee = pose.landmark(ofType: .leftKnee)
        let leftAnkle = pose.landmark(ofType: .leftAnkle)

        if (rightHip.inFrameLikelihood > threshold &&
            rightKnee.inFrameLikelihood > threshold &&
            rightAnkle.inFrameLikelihood > threshold &&
            leftHip.inFrameLikelihood > threshold &&
            leftKnee.inFrameLikelihood > threshold &&
            leftAnkle.inFrameLikelihood > threshold) {

            let right_hip_knee_ankle_angle = calculateAngle(
                A: CGPoint(x: rightHip.position.x, y: rightHip.position.y),
                B: CGPoint(x: rightKnee.position.x, y: rightKnee.position.y),
                C: CGPoint(x: rightAnkle.position.x, y: rightAnkle.position.y)
            )
            
            let left_hip_knee_ankle_angle = calculateAngle(
                A: CGPoint(x: leftHip.position.x, y: leftHip.position.y),
                B: CGPoint(x: leftKnee.position.x, y: leftKnee.position.y),
                C: CGPoint(x: leftAnkle.position.x, y: leftAnkle.position.y)
            )

            let avg_angle = (right_hip_knee_ankle_angle + left_hip_knee_ankle_angle) / 2.0

            switch currentState {
            case .start:
                if avg_angle <= completedAngle {
                    currentState = .middle
                }
            case .middle:
                if avg_angle > completedAngle {
                    currentState = .finished
                }
            case .finished:
                if avg_angle > 160 {
                    repCounter += 1
                    currentState = .start
                    print("Repetition count: \(repCounter)")
                } else if avg_angle <= completedAngle {
                    currentState = .start
                }
            }
        }
    }
    func processPullUps(from pose: Pose) {
        // Az ideális szögek és az állapotváltások pontosítása a "Pull Up" gyakorlathoz
        let startEndAngle: Double = 140.0 // Feltételezve, hogy magas szög jelzi a kezdő/befejező állapotot
        let middleAngle: Double = 80.0 // Feltételezve, hogy alacsony szög jelzi a középső állapotot

        let rightElbow = pose.landmark(ofType: .rightElbow)
        let rightShoulder = pose.landmark(ofType: .rightShoulder)
        let rightWrist = pose.landmark(ofType: .rightWrist)
        let leftElbow = pose.landmark(ofType: .leftElbow)
        let leftShoulder = pose.landmark(ofType: .leftShoulder)
        let leftWrist = pose.landmark(ofType: .leftWrist)

        if (rightShoulder.inFrameLikelihood > threshold &&
            rightElbow.inFrameLikelihood > threshold &&
            rightWrist.inFrameLikelihood > threshold &&
            leftShoulder.inFrameLikelihood > threshold &&
            leftElbow.inFrameLikelihood > threshold &&
            leftWrist.inFrameLikelihood > threshold) {

            let rightAngle = calculateAngle(
                A: CGPoint(x: rightShoulder.position.x, y: rightShoulder.position.y),
                B: CGPoint(x: rightElbow.position.x, y: rightElbow.position.y),
                C: CGPoint(x: rightWrist.position.x, y: rightWrist.position.y)
            )

            let leftAngle = calculateAngle(
                A: CGPoint(x: leftShoulder.position.x, y: leftShoulder.position.y),
                B: CGPoint(x: leftElbow.position.x, y: leftElbow.position.y),
                C: CGPoint(x: leftWrist.position.x, y: leftWrist.position.y)
            )

            let avg_angle = (rightAngle + leftAngle) / 2.0

          
            switch currentState {
            case .start:
                if avg_angle <= middleAngle {
                    currentState = .middle
                }
            case .middle:
                if avg_angle >= startEndAngle {
                    currentState = .finished
                }
            case .finished:
                if avg_angle > middleAngle {
                    repCounter += 1
                    currentState = .start
                    print("Repetition count: \(repCounter)")
                } else if avg_angle >= startEndAngle {
                    currentState = .middle
                }
            }
        }
    }




    func processPushups(from pose: Pose) {
            
            let completedAngle: Double = 110.0
            let rightShoulder = pose.landmark(ofType: .rightShoulder)
            let rightElbow = pose.landmark(ofType: .rightElbow)
            let rightWrist = pose.landmark(ofType: .rightWrist)
            let leftShoulder = pose.landmark(ofType: .leftShoulder)
            let leftElbow = pose.landmark(ofType: .leftElbow)
            let leftWrist = pose.landmark(ofType: .leftWrist)
            
            if (rightShoulder.inFrameLikelihood > threshold &&
                rightElbow.inFrameLikelihood > threshold &&
                rightWrist.inFrameLikelihood > threshold &&
                leftShoulder.inFrameLikelihood > threshold &&
                leftElbow.inFrameLikelihood > threshold &&
                leftWrist.inFrameLikelihood > threshold) {

                let right_shoulder_elbow_wrist_angle = calculateAngle(
                    A: CGPoint(x: rightShoulder.position.x, y: rightShoulder.position.y),
                    B: CGPoint(x: rightElbow.position.x, y: rightElbow.position.y),
                    C: CGPoint(x: rightWrist.position.x, y: rightWrist.position.y)
                )
                
                let left_shoulder_elbow_wrist_angle = calculateAngle(
                    A: CGPoint(x: leftShoulder.position.x, y: leftShoulder.position.y),
                    B: CGPoint(x: leftElbow.position.x, y: leftElbow.position.y),
                    C: CGPoint(x: leftWrist.position.x, y: leftWrist.position.y)
                )
                
                //print("Szög: \(left_shoulder_elbow_wrist_angle)")
                
                let avg_angle = (right_shoulder_elbow_wrist_angle + left_shoulder_elbow_wrist_angle) / 2.0
                
                //print("Átlag Szög: \(left_shoulder_elbow_wrist_angle)")
               // print(avg_angle)

                switch currentState {
                case .start:
                    if avg_angle <= completedAngle {
                        currentState = .middle
                    }
                case .middle:
                    if avg_angle > completedAngle {
                        currentState = .finished
                    }
                case .finished:
                    if avg_angle > 130 {
                        repCounter += 1
                        currentState = .start
                        print("Repetition count: \(repCounter)")
                    } else if avg_angle <= completedAngle {
                        currentState = .middle
                    }
                }
            }
        }
    }


