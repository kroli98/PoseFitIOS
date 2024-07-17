
import Foundation
struct Exercise:Identifiable{
    var keyPointTriples: [(String, String, String)]
    var referenceAngles: [[Double]]
    let id: UUID = UUID()
    let name: String
    var repetition: Int
    var set: Int
    var duration: Int?
    var isCompleted: Bool = false
    
    init(name: String, repetition: Int, set: Int, duration: Int?, keyPointTriples : [(String, String, String)], referenceAngles: [[Double]]) {
           self.name = name
           self.repetition = repetition
           self.set = set
           self.duration = duration
        self.keyPointTriples = keyPointTriples
        self.referenceAngles = referenceAngles
       }
    
    
}
struct Exercises {
    static var groupedSampleExercises: [[Exercise]] {
        return [
            [
                Exercise(name: "Fekvőtámasz", repetition: 15, set: 1, duration: nil, keyPointTriples: [], referenceAngles: []),
                Exercise(name: "Felülés", repetition: 20, set: 1, duration: nil, keyPointTriples: [], referenceAngles: []),
                Exercise(name: "Plank", repetition: 1, set: 1, duration: 30, keyPointTriples: [], referenceAngles: []),
                Exercise(name: "Guggolás", repetition: 20, set: 1, duration: nil, keyPointTriples: [], referenceAngles: [])
            ],

            [
                Exercise(name: "Fekvőtámasz", repetition: 15, set: 1, duration: nil, keyPointTriples: [], referenceAngles: []),
                Exercise(name: "Plank", repetition: 1, set: 1, duration: 30, keyPointTriples: [], referenceAngles: []),
                Exercise(name: "Guggolás", repetition: 20, set: 1, duration: nil, keyPointTriples: [], referenceAngles: [])
            ],

            [
                Exercise(name: "Fekvőtámasz", repetition: 15, set: 1, duration: nil, keyPointTriples: [], referenceAngles: []),
                Exercise(name: "Plank", repetition: 1, set: 1, duration: 30, keyPointTriples: [], referenceAngles: []),
                Exercise(name: "Felülés", repetition: 20, set: 1, duration: nil, keyPointTriples: [], referenceAngles: [])
            ],

            [
                Exercise(name: "Felülés", repetition: 20, set: 1, duration: nil, keyPointTriples: [], referenceAngles: [])
            ]
        ]
    }
    static var validExercises: [Exercise]{
        return [
            Exercise(
                name: "Fekvőtámasz",
                repetition: 15,
                set: 1,
                duration: nil,
                keyPointTriples: [
                    ("LeftShoulder", "LeftElbow", "LeftWrist"),
                    ("RightShoulder", "RightElbow", "RightWrist"),
                    ("LeftAnkle", "LeftHip", "LeftShoulder"),
                    ("RightAnkle", "RightHip", "RightShoulder"),
                    ("LeftHip", "LeftKnee", "LeftAnkle"),
                    ("RightHip", "RightKnee", "RightAnkle")
                ],
                referenceAngles: [
                    [173.0, 160.0, 145.0, 130.0, 120.0, 110.0, 100.0, 90.0, 80.0, 70.0,60.0,70.0, 80.0, 90.0, 100.0, 110.0, 120.0, 130.0, 145.0, 160.0, 173.0],
                    [173.0, 160.0, 145.0, 130.0, 120.0, 110.0, 100.0, 90.0, 80.0, 70.0,60.0,70.0, 80.0, 90.0, 100.0, 110.0, 120.0, 130.0, 145.0, 160.0, 173.0],
                    [180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0],
                    [180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0],
                    [180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0],
                    [180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0]
                ]
            )
,
            Exercise(name: "Felülés", repetition: 20, set: 1, duration: nil,
                     keyPointTriples: [
                         ("LeftShoulder", "LeftHip", "LeftAnkle"),
                         ("RightShoulder", "RightHip", "RightAnkle"),
                         ("LeftHip", "LeftKnee", "LeftAnkle"),
                         ("RightHip", "RightKnee", "RightAnkle")
                     ],
                     referenceAngles: [
                         [173.0, 160.0, 145.0, 130.0, 120.0, 110.0, 100.0, 90.0, 80.0, 90.0, 100.0, 110.0, 120.0, 130.0, 145.0, 160.0, 173.0],
                         [173.0, 160.0, 145.0, 130.0, 120.0, 110.0, 100.0, 90.0, 80.0, 90.0, 100.0, 110.0, 120.0, 130.0, 145.0, 160.0, 173.0],
                         [90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90],
                         [90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90, 90]
                     ])
,
            Exercise(name: "Plank", repetition: 1, set: 1, duration: 30, keyPointTriples: [("LeftShoulder", "LeftHip", "LeftKnee"), ("RightShoulder", "RightHip", "RightKnee")], referenceAngles: [[180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0], [180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0, 180.0]]),
            Exercise(name: "Guggolás", repetition: 20, set: 1, duration: nil, keyPointTriples: [("LeftHip", "LeftKnee", "LeftAnkle"), ("RightHip", "RightKnee", "RightAnkle")], referenceAngles: [[175.0, 169.75, 164.5, 159.25, 154.0, 148.75, 143.5, 138.25, 133.0, 127.75, 122.5, 117.25, 112.0, 106.75, 101.5, 96.25, 90.0, 96.25, 101.5, 106.75, 112.0, 117.25, 122.5, 127.75, 133.0, 138.25, 143.5, 148.75, 154.0, 159.25, 164.5, 169.75, 175.0], [175.0, 169.75, 164.5, 159.25, 154.0, 148.75, 143.5, 138.25, 133.0, 127.75, 122.5, 117.25, 112.0, 106.75, 101.5, 96.25, 90.0, 96.25, 101.5, 106.75, 112.0, 117.25, 122.5, 127.75, 133.0, 138.25, 143.5, 148.75, 154.0, 159.25, 164.5, 169.75, 175.0]]),
            Exercise(name: "Felhúzás", repetition: 10, set: 1, duration: nil,
                     keyPointTriples: [
                         ("LeftShoulder", "LeftElbow", "LeftWrist"),
                         ("RightShoulder", "RightElbow", "RightWrist")
                      
                     ],
                     referenceAngles: [
                         [180.0, 175.0, 170.0, 165.0, 160.0, 155.0, 150.0, 145.0, 140.0, 135.0, 130.0, 125.0, 120.0, 115.0, 110.0, 105.0, 100.0, 95.0, 90.0, 85.0, 80.0, 75.0, 70.0, 65.0, 60.0, 55.0, 50.0, 45.0, 50.0, 55.0, 60.0, 65.0, 70.0, 75.0, 80.0, 85.0, 90.0, 95.0, 100.0, 105.0, 110.0, 115.0, 120.0, 125.0, 130.0, 135.0, 140.0, 145.0, 150.0, 155.0, 160.0, 165.0, 170.0, 175.0, 180.0],
                         [180.0, 175.0, 170.0, 165.0, 160.0, 155.0, 150.0, 145.0, 140.0, 135.0, 130.0, 125.0, 120.0, 115.0, 110.0, 105.0, 100.0, 95.0, 90.0, 85.0, 80.0, 75.0, 70.0, 65.0, 60.0, 55.0, 50.0, 45.0, 50.0, 55.0, 60.0, 65.0, 70.0, 75.0, 80.0, 85.0, 90.0, 95.0, 100.0, 105.0, 110.0, 115.0, 120.0, 125.0, 130.0, 135.0, 140.0, 145.0, 150.0, 155.0, 160.0, 165.0, 170.0, 175.0, 180.0]
                     ])



        
        ]
    }
}

struct ExerciseData {
    var name: String
    var elapsedTime: Int
    var repetitions: Int
    var series: Int
    var correctness: Double
}






