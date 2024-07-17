
import Foundation
import MLKitPoseDetectionAccurate
import MLKitPoseDetection
import MLKit

class PoseDetectionManager: ObservableObject {
    var poseDetector: PoseDetector
    var frameCount = 0
    var startTime: CFAbsoluteTime!
    @Published var isDisabled = true
    @Published var detectionFailed: Bool = false
    var fpsHistory: [Double] = []
    @Published var averageFPS: Double = 0.0
    
    init() {
        let options =  AccuratePoseDetectorOptions()
        options.detectorMode = .stream
        self.poseDetector = PoseDetector.poseDetector(options: options)
        startTime = CFAbsoluteTimeGetCurrent()
    }
    
    func detectPose(in image: MLImage, width: CGFloat, height: CGFloat, completion: @escaping ([Pose]) -> Void) {
       
            var poses: [Pose] = []
            
            
            do {
            poses = try poseDetector.results(in: image)
             
                
        } catch let error {
            print("Failed to detect poses with error: \(error.localizedDescription).")
            
            return
        }
        let currentTime = CFAbsoluteTimeGetCurrent()
        let elapsedTime = currentTime - startTime
        frameCount += 1
        
        if elapsedTime >= 1.0 {
                   let fps = Double(frameCount) / elapsedTime
                   fpsHistory.append(fps)
                   
                   if fpsHistory.count > 10 {
                       fpsHistory.removeFirst(fpsHistory.count - 10)
                   }

                   averageFPS = fpsHistory.reduce(0, +) / Double(fpsHistory.count)
                   print(averageFPS)

                   frameCount = 0
                   startTime = currentTime
               }
     
        
        DispatchQueue.main.async {
            completion(poses)
        }
    
       
    }
    
   
}
