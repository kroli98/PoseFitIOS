//
//  PoseGymTests.swift
//  PoseGymTests
//
//  Created by Kiss Roland on 22/11/2023.
//

import XCTest


@testable import PoseFit



final class PoseGymTests: XCTestCase {

    override func setUpWithError() throws {
      
    }

    override func tearDownWithError() throws {
       
    }


    func testPerformanceExample() throws {
        
        measure {
          
        }
    }
 
    func testCalculateAngle() {
        let exerciseAnalyzer = ExerciseAnalyzer()
        
        // 1. Teszt:
        let pointA = CGPoint(x: 0, y: 0)
        let pointB = CGPoint(x: 1, y: 1)
        let pointC = CGPoint(x: 2, y: 0)

        let angle = exerciseAnalyzer.calculateAngle(A: pointA, B: pointB, C: pointC)
       
        XCTAssertEqual(angle, 90, accuracy: 0.01)
        
        
        // 2. Teszt:
        let horizontalPointA = CGPoint(x: 0, y: 0)
          let horizontalPointB = CGPoint(x: 1, y: 0)
          let horizontalPointC = CGPoint(x: 2, y: 0)
          let horizontalAngle = exerciseAnalyzer.calculateAngle(A: horizontalPointA, B: horizontalPointB, C: horizontalPointC)
        XCTAssertEqual(horizontalAngle, 180.0, accuracy: 0.01)

          // 3. Teszt:
          let verticalPointA = CGPoint(x: 0, y: 0)
          let verticalPointB = CGPoint(x: 0, y: 1)
          let verticalPointC = CGPoint(x: 0, y: 2)
          let verticalAngle = exerciseAnalyzer.calculateAngle(A: verticalPointA, B: verticalPointB, C: verticalPointC)
        XCTAssertEqual(verticalAngle, 180.0, accuracy: 0.01)

          

          // 4. Teszt
          let acutePointA = CGPoint(x: 0, y: 0)
          let acutePointB = CGPoint(x: 1, y: 0)
          let acutePointC = CGPoint(x: 1, y: 1)
          let acuteAngle = exerciseAnalyzer.calculateAngle(A: acutePointA, B: acutePointB, C: acutePointC)
        XCTAssertEqual(acuteAngle, 90.0, accuracy: 0.01)
        
        
        
    }
    func testFeedbackForPushup() {
        let exerciseAnalyzer = ExerciseAnalyzer()
        exerciseAnalyzer.loadReferenceData(forExercise: Exercises.validExercises[0])

        // Referenciaadat tesztelése, dtw érték küszöb alatt
        var feedback = exerciseAnalyzer.generateFeedback(angleDifference: 100, joints: ("RightShoulder", "RightElbow", "RightWrist"), index: 0, filteredAnglesUser: Exercises.validExercises[0].referenceAngles[0])

        XCTAssertEqual(feedback, "Jó a karhajlításod!")
        
        // Referenciaadat tesztelése, dtw érték küszöb felett
        feedback = exerciseAnalyzer.generateFeedback(angleDifference: 200, joints: ("RightShoulder", "RightElbow", "RightWrist"), index: 0, filteredAnglesUser: Exercises.validExercises[0].referenceAngles[0])

        XCTAssertEqual(feedback, "Jó a karhajlításod!")
        
        // Egyedi felhasználói adat tesztelése, dtw érték küszöb felett
        feedback = exerciseAnalyzer.generateFeedback(angleDifference: 200, joints: ("RightShoulder", "RightElbow", "RightWrist"), index: 0, filteredAnglesUser: [173.0, 160.0, 145.0, 130.0, 120.0, 130.0, 145.0, 160.0, 173.0])

        XCTAssertEqual(feedback, "Hajlítsd jobban a karodat!")
        
        // Egyedi felhasználói adat tesztelése, dtw érték küszöb felett
        feedback = exerciseAnalyzer.generateFeedback(angleDifference: 200, joints: ("RightShoulder", "RightElbow", "RightWrist"), index: 0, filteredAnglesUser: [173.0, 160.0, 145.0, 130.0, 120.0,110.0, 100.0, 90.0, 40.0, 90.0, 100.0, 110.0, 120.0, 130.0, 145.0, 160.0, 173.0])

        XCTAssertEqual(feedback,  "Ne menj túl mélyre!")
        
        
    }
    func testFeedbackForPlank() {
        let exerciseAnalyzer = ExerciseAnalyzer()
        exerciseAnalyzer.loadReferenceData(forExercise: Exercises.validExercises[2])

     
        // Referenciaadat tesztelése, dtw érték küszöb alatt

        var feedback = exerciseAnalyzer.generateFeedback(angleDifference: 100, joints: ("LeftShoulder", "LeftHip", "LeftAnkle"), index: 0, filteredAnglesUser: Exercises.validExercises[2].referenceAngles[0])

        XCTAssertEqual(feedback, "Kiváló plank tartás!")
        
        // Referenciaadat tesztelése, dtw érték küszöb felett
        feedback = exerciseAnalyzer.generateFeedback(angleDifference: 200, joints: ("LeftShoulder", "LeftHip", "LeftAnkle"), index: 0, filteredAnglesUser: Exercises.validExercises[2].referenceAngles[0])

        XCTAssertEqual(feedback, "Kiváló plank tartás!")
        
        // Egyedi felhasználói adat tesztelése, dtw érték küszöb felett
        feedback = exerciseAnalyzer.generateFeedback(angleDifference: 200, joints: ("LeftShoulder", "LeftHip", "LeftAnkle"), index: 0, filteredAnglesUser: [150.0,149.0, 148.0, 151.0, 160.0,155.0])

        XCTAssertEqual(feedback, "Tartsd egyenesen a törzsed!")
        
        // Egyedi felhasználói adat tesztelése, dtw érték küszöb felett
        feedback = exerciseAnalyzer.generateFeedback(angleDifference: 200, joints: ("LeftShoulder", "LeftHip", "LeftAnkle"), index: 0, filteredAnglesUser: [170.0,179.0, 170.0, 179.0, 181.0,175.0])

        XCTAssertEqual(feedback, "Kiváló plank tartás!")
    }
    func testFeedbackForSitups() {
        let exerciseAnalyzer = ExerciseAnalyzer()
        exerciseAnalyzer.loadReferenceData(forExercise: Exercises.validExercises[1])
        

        
        var userAnglesSitup = [180.0, 175.0,165.0,155.0,145.0,135.0,125.0, 115.0, 105.0,95.0, 105.0, 115.0, 125.0, 135.0, 145.0, 155.0, 165.0, 175.0, 180.0]

        var feedback = exerciseAnalyzer.generateFeedback(angleDifference: 200, joints: ("LeftShoulder", "LeftHip", "LeftAnkle"), index: 0, filteredAnglesUser: userAnglesSitup)

        XCTAssertEqual(feedback, "Jól végzed a felüléseket!")
        
        userAnglesSitup = [180.0, 175.0,165.0,155.0,145.0, 135.0, 145.0, 155.0, 165.0, 175.0, 180.0]

        feedback = exerciseAnalyzer.generateFeedback(angleDifference: 200, joints: ("LeftShoulder", "LeftHip", "LeftAnkle"), index: 0, filteredAnglesUser: userAnglesSitup)

        XCTAssertEqual(feedback, "Emelkedj magasabbra!")
        
        
        
        
    }

    func testFeedbackForSquats() {
        let exerciseAnalyzer = ExerciseAnalyzer()
        
        exerciseAnalyzer.loadReferenceData(forExercise: Exercises.validExercises[3])

        var userAnglesSquat = [180.0,175.0,165.0,155.0,145.0,135.0,125.0, 115.0, 105.0,95.0, 105.0, 115.0, 125.0, 135.0, 145.0, 155.0, 165.0, 175.0, 180.0]

        var feedback = exerciseAnalyzer.generateFeedback(angleDifference: 200, joints: ("RightHip", "RightKnee", "RightAnkle"), index: 1, filteredAnglesUser: userAnglesSquat)

        XCTAssertEqual(feedback, "Jól csinálod a guggolást!")
        
         userAnglesSquat = [180.0,175.0,165.0,155.0,145.0, 135.0, 145.0, 155.0, 165.0, 175.0, 180.0]

         feedback = exerciseAnalyzer.generateFeedback(angleDifference: 200, joints: ("RightHip", "RightKnee", "RightAnkle"), index: 1, filteredAnglesUser: userAnglesSquat)

        XCTAssertEqual(feedback, "Mélyebbre kell guggolnod!")
    }


    
    

}

