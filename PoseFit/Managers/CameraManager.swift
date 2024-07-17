
import SwiftUI
import AVFoundation
import Vision
import MLKit
import MLImage
import CoreML



@objc(CameraViewController)
class CameraViewController: UIViewController {
    
    init(poseDetectionManager: PoseDetectionManager, repetitionCounter: RepetitionCounter, exerciseAnalyzer: ExerciseAnalyzer) {
       
        self.poseDetectionManager = poseDetectionManager
        self.repetitionCounter = repetitionCounter
        self.exerciseAnalyzer = exerciseAnalyzer
     
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
 
    var currentCameraPosition: AVCaptureDevice.Position = .front
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer?
    var maskLayer = CAShapeLayer()
    var onRepCounterChanged: ((Int) -> Void)?
       var repCounter: Int = 0 {
           didSet {
               onRepCounterChanged?(repCounter)
           }
       }
  
  
    var previousLandmarks: [PoseLandmark]!
    var poseDetectionManager: PoseDetectionManager
    var exerciseAnalyzer: ExerciseAnalyzer
    var repetitionCounter: RepetitionCounter
    var videoOutput: AVCaptureVideoDataOutput!
    private var lastFrame: CMSampleBuffer?
   
    private lazy var sessionQueue = DispatchQueue(label: Constant.sessionQueueLabel)

    private lazy var previewOverlayView: UIImageView = {

      precondition(isViewLoaded)
      let previewOverlayView = UIImageView(frame: .zero)
      previewOverlayView.contentMode = UIView.ContentMode.scaleAspectFill
      previewOverlayView.translatesAutoresizingMaskIntoConstraints = false
      return previewOverlayView
    }()

    private lazy var annotationOverlayView: UIView = {
      precondition(isViewLoaded)
      let annotationOverlayView = UIView(frame: .zero)
      annotationOverlayView.translatesAutoresizingMaskIntoConstraints = false
      return annotationOverlayView
    }()
    
    private func setUpPreviewOverlayView() {
        self.view.addSubview(previewOverlayView)
      NSLayoutConstraint.activate([
        previewOverlayView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
        previewOverlayView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        previewOverlayView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
        previewOverlayView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),


      ])
    }

    private func setUpAnnotationOverlayView() {
        self.view.addSubview(annotationOverlayView)
      NSLayoutConstraint.activate([
        annotationOverlayView.topAnchor.constraint(equalTo: self.view.topAnchor),
        annotationOverlayView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
        annotationOverlayView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        annotationOverlayView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

      ])
    }
    private func setUpCaptureSessionOutput() {
      weak var weakSelf = self
      sessionQueue.async {
        guard let strongSelf = weakSelf else {
          print("Self is nil!")
          return
        }
        strongSelf.captureSession.beginConfiguration()
       
          strongSelf.captureSession.sessionPreset = AVCaptureSession.Preset.medium

        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [
          (kCVPixelBufferPixelFormatTypeKey as String): kCVPixelFormatType_32BGRA
        ]
        output.alwaysDiscardsLateVideoFrames = true
        let outputQueue = DispatchQueue(label: Constant.videoDataOutputQueueLabel)
        output.setSampleBufferDelegate(strongSelf, queue: outputQueue)
        guard strongSelf.captureSession.canAddOutput(output) else {
          print("Failed to add capture session output.")
          return
        }
        strongSelf.captureSession.addOutput(output)
          
    
        strongSelf.captureSession.commitConfiguration()
      }
    }
    private func captureDevice(forPosition position: AVCaptureDevice.Position) -> AVCaptureDevice? {
      if #available(iOS 10.0, *) {
        let discoverySession = AVCaptureDevice.DiscoverySession(
          deviceTypes: [.builtInWideAngleCamera],
          mediaType: .video,
          position: .unspecified
        )
        return discoverySession.devices.first { $0.position == position }
      }
      return nil
    }

    private func setUpCaptureSessionInput(for position: AVCaptureDevice.Position) {
      weak var weakSelf = self
      sessionQueue.async {
        guard let strongSelf = weakSelf else {
          print("Self is nil!")
          return
        }
        let cameraPosition: AVCaptureDevice.Position = position
        guard let device = strongSelf.captureDevice(forPosition: cameraPosition) else {
          print("Failed to get capture device for camera position: \(cameraPosition)")
          return
        }
        do {
          strongSelf.captureSession.beginConfiguration()
          let currentInputs = strongSelf.captureSession.inputs
          for input in currentInputs {
            strongSelf.captureSession.removeInput(input)
          }

          let input = try AVCaptureDeviceInput(device: device)
          guard strongSelf.captureSession.canAddInput(input) else {
            print("Failed to add capture session input.")
            return
          }
          strongSelf.captureSession.addInput(input)
          strongSelf.captureSession.commitConfiguration()
        } catch {
          print("Failed to create capture device input: \(error.localizedDescription)")
        }
      }
    }
    
    @objc private func toggleCamera() {
        currentCameraPosition = currentCameraPosition == .front ? .back : .front
        setUpCaptureSessionInput(for: currentCameraPosition)
    }



    
    override func viewDidLoad() {
      super.viewDidLoad()
    
      captureSession = AVCaptureSession()
      previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
      

     
        if let previewLayer = previewLayer {
               previewLayer.frame = view.bounds
               previewLayer.videoGravity = .resizeAspectFill
               view.layer.addSublayer(previewLayer)
           }
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleCamera))
        doubleTapGesture.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleTapGesture)

      setUpPreviewOverlayView()
      setUpAnnotationOverlayView()
      setUpCaptureSessionOutput()
      setUpCaptureSessionInput(for:currentCameraPosition)
       
       
    }
    

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession.stopRunning()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.global(qos: .background).async{
            self.captureSession.startRunning()
        }
    }

    override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()

        previewLayer?.frame = self.view.bounds
    }
    private func updatePreviewOverlayViewWithImageBuffer(_ imageBuffer: CVImageBuffer?) {
      guard let imageBuffer = imageBuffer else {
        return
      }
        let orientation = UIUtilities.imageOrientation(
            fromDevicePosition: currentCameraPosition
        )

      let image = UIUtilities.createUIImage(from: imageBuffer, orientation: orientation)
      previewOverlayView.image = image
    }
    private func removeDetectionAnnotations() {
      for annotationView in annotationOverlayView.subviews {
        annotationView.removeFromSuperview()
      }
    }
    private func updatePreviewOverlayViewWithLastFrame() {
      guard let lastFrame = lastFrame,
        let imageBuffer = CMSampleBufferGetImageBuffer(lastFrame)
      else {
        return
      }
      self.updatePreviewOverlayViewWithImageBuffer(imageBuffer)
      self.removeDetectionAnnotations()
    }

  
    
    private func detectPose(in image: MLImage, width: CGFloat, height: CGFloat) {
      
            poseDetectionManager.detectPose(in: image, width: width, height: height) { [weak self] poses in
                guard let self = self else {
                    print("Self is nil!")
                    return
                }
                self.updatePreviewOverlayViewWithLastFrame()
                guard !poses.isEmpty else {
                    print("Pose detector returned no results.")
                    annotationOverlayView.subviews.forEach { $0.removeFromSuperview() }
                    DispatchQueue.main.async {
                        self.poseDetectionManager.detectionFailed = true
                    }
                    return
                }
                
                
                repetitionCounter.processPose(poses[0])
                
                
                self.exerciseAnalyzer.addUserPose(pose: poses[0])
                
                
            
                self.poseDetectionManager.detectionFailed = false

                let treshold = 0.7
                
                self.drawPoses(poses, width: width, height: height, treshold: Float(treshold))
                
            }
            
            
            
            
            
        
        }
    
 

       
            
            
            

            
    func drawPoses(_ poses: [Pose], width: CGFloat, height: CGFloat, treshold: Float) {

        annotationOverlayView.subviews.forEach { $0.removeFromSuperview() }
       


        poses.forEach { pose in

            let poseOverlayView = UIUtilities.createPoseOverlayView(
                forPose: pose,
                inViewWithBounds: self.annotationOverlayView.bounds,
                lineWidth: 2,
                dotRadius: 3,
                treshold: treshold,
                positionTransformationClosure: { (position) -> CGPoint in
                    return self.normalizedPoint(fromVisionPoint: position, width: width, height: height)
                }
                
            )
            self.annotationOverlayView.addSubview(poseOverlayView)
        }
    }
            
    private func normalizedPoint(
      fromVisionPoint point: VisionPoint,
      width: CGFloat,
      height: CGFloat
    ) -> CGPoint {
      let cgPoint = CGPoint(x: point.x, y: point.y)
      var normalizedPoint = CGPoint(x: cgPoint.x / width, y: cgPoint.y / height)
      normalizedPoint = previewLayer!.layerPointConverted(fromCaptureDevicePoint: normalizedPoint)
      return normalizedPoint
    }
            
            
            
            
           
            
        }
        extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
            func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
                
                guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                  print("Failed to get image buffer from sample buffer.")
                  return
                }
                let visionImage = VisionImage(buffer: sampleBuffer)
                let orientation = UIUtilities.imageOrientation(
                  fromDevicePosition:  .front
                )
                visionImage.orientation = orientation
                
                
                guard let inputImage = MLImage(sampleBuffer: sampleBuffer) else {
                  print("Failed to create MLImage from sample buffer.")
                  return
                }
                inputImage.orientation = orientation
             
                let imageWidth = CGFloat(CVPixelBufferGetWidth(imageBuffer))
                let imageHeight = CGFloat(CVPixelBufferGetHeight(imageBuffer))
                
              
               
                
                if(!repetitionCounter.isDisabled && !poseDetectionManager.isDisabled && !exerciseAnalyzer.isDisabled)
                {
                    self.detectPose(in: inputImage, width: imageWidth, height: imageHeight)
                }
                else
                {
                    DispatchQueue.main.sync{
                        if(!annotationOverlayView.subviews.isEmpty)
                        {
                            annotationOverlayView.subviews.forEach { $0.removeFromSuperview() }
                            
                        }
                    }
                }
               
              
             
            
               
            }
          

        }
private enum Constant {
  static let alertControllerTitle = "Vision Detectors"
  static let alertControllerMessage = "Select a detector"
  static let cancelActionTitleText = "Cancel"
  static let videoDataOutputQueueLabel = "com.google.mlkit.visiondetector.VideoDataOutputQueue"
  static let sessionQueueLabel = "com.google.mlkit.visiondetector.SessionQueue"
  static let noResultsMessage = "No Results"
  static let localModelFile = (name: "bird", type: "tflite")
  static let labelConfidenceThreshold = 0.75
  static let smallDotRadius: CGFloat = 4.0
  static let lineWidth: CGFloat = 3.0
  static let originalScale: CGFloat = 1.0
  static let padding: CGFloat = 10.0
  static let resultsLabelHeight: CGFloat = 200.0
  static let resultsLabelLines = 5
  static let imageLabelResultFrameX = 0.4
  static let imageLabelResultFrameY = 0.1
  static let imageLabelResultFrameWidth = 0.5
  static let imageLabelResultFrameHeight = 0.8
  static let segmentationMaskAlpha: CGFloat = 0.5
}
struct CameraView: UIViewControllerRepresentable {
    typealias UIViewControllerType = CameraViewController
    var poseDetectionManager: PoseDetectionManager
    var repetitionCounter: RepetitionCounter
    var exerciseAnalyzer: ExerciseAnalyzer
  
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController(poseDetectionManager: poseDetectionManager, repetitionCounter: repetitionCounter, exerciseAnalyzer: exerciseAnalyzer)
        
        return controller
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        
    }
}



