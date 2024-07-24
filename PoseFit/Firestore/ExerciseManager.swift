import Foundation
import FirebaseFirestore

class ExerciseManager {
    
    static let shared = ExerciseManager()
    
    private init() {}
    
    func getExercises() async throws -> [DBExercise] {
        return try await withCheckedThrowingContinuation { continuation in
            Firestore.firestore().collection("exercises").getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching documents: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                } else {
                    if let querySnapshot = querySnapshot {
                        let exercises: [DBExercise] = querySnapshot.documents.compactMap { document in
                            do {
                                let exercise =  try document.data(as: DBExercise.self)
                                print("Successfully mapped document: \(document.documentID)")
                                return exercise
                            } catch {
                                print("Error mapping document \(document.documentID): \(error.localizedDescription)")
                                print("Document data: \(document.data())")
                                return nil
                            }
                        }
                        print("Total exercises mapped: \(exercises.count)")
                        continuation.resume(returning: exercises)
                    } else {
                        print("QuerySnapshot is nil")
                        continuation.resume(returning: [])
                    }
                }
            }
        }
    }
}
