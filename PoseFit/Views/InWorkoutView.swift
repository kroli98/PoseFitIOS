import SwiftUI
import AVFoundation
import MLKit
import MLImage
import CoreMotion
import CoreData
import SDWebImageSwiftUI
import AVFoundation
import HealthKit
import WatchConnectivity



struct InWorkoutView: View {
    
    @State var lastFeedbackMessages: [String] = []
    @State var lastSpokenFeedback: String? = nil
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isAnimating = true
    @State private var isCameraViewBig: Bool = true
    @StateObject private var poseDetectionManager = PoseDetectionManager()
    @StateObject private var exerciseAnalyzer = ExerciseAnalyzer()
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    @State private var synthesizer = AVSpeechSynthesizer()
    @State private var currentExercise = 0
    @State private var timer: Timer?
    @State private var feedbackMessages: [String] = []
        @State private var lastFeedbackMessage: String? = nil
    @State private var exerciseTimer: Timer?
    @State private var elapsedSeconds = 0
    @State private var exerciseElapsedSeconds = 0
    @StateObject private var repetitionCounter: RepetitionCounter
    @State private var isDeviceMoving: Bool = false
    @State private var stationarySeconds: Int = 0
    @State private var stationaryTimer: Timer? = nil
    @State private var isCountingDown: Bool = false
    @State private var countdownSeconds: Int = 10
    @State private var countdownTimer: Timer? = nil
    @State private var showCountdownText = true
    @State private var currentGroup = 0
    @State private var organizedExercisesGroups: [[Exercise]]
    @State private var isPaused: Bool = false
    @State private var lastFeedbacks: [String] = []
    @State var dismiss = false
    private var date = Date()
    let motionManager = CMMotionManager()
    @State private var navigateToFinishWorkoutView = false
    @State private var savedExercises: [ExerciseData] = []
    @State var newWorkout = Workout(context: PersistenceController.shared.container.viewContext)
    let healthStore = HKHealthStore()
    @State private var heartRate: Int = 0
  

    



    

    
    
    init(organizedExercisesGroups: [[Exercise]]){
        self._organizedExercisesGroups = State(initialValue: organizedExercisesGroups)
        self._repetitionCounter = StateObject(wrappedValue: RepetitionCounter(exercise: organizedExercisesGroups[0][0]))
        repetitionCounter.isDisabled = true
        exerciseAnalyzer.isDisabled = true
        poseDetectionManager.isDisabled = true
        newWorkout.date = Date()
        
        let setsData = ["organizedExercisesGroups": organizedExercisesGroups, "currentGroup": currentGroup, "currentExercise": currentExercise] as [String : Any]
        
      
      send(setsData: setsData)
    
       
    }
    private func getHeartRate() {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
           let timeSortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
           let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 5, sortDescriptors: [timeSortDescriptor]) { (query, results, error) in
               guard let samples = results as? [HKQuantitySample] else { return }
               
               let rates = samples.map { $0.quantity.doubleValue(for: HKUnit(from: "count/min")) }
               let averageRate = rates.reduce(0, +) / Double(rates.count)
               
               DispatchQueue.main.async {
                   self.heartRate = Int(averageRate)
               }
           }
           
           healthStore.execute(query)
      }
  
    func requestHealthKitAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device.")
            return
        }
        
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let dataTypes = Set([heartRateType])
        
        healthStore.requestAuthorization(toShare: nil, read: dataTypes) { success, error in
            if !success {
                print("Permission not granted to access heart rate data.")
            }
        }
    }
  

    
    var body: some View {
        
      
            GeometryReader { geometry in
                
                Spacer()
                VStack{
                    
                    
                    if(lastFeedbackMessage != nil)
                     {
                        Text(lastFeedbackMessage ?? "")
                            .font((lastFeedbackMessage != nil) ? .title3: .largeTitle)
                            .padding(.horizontal,10)
                            .padding(.vertical,5)
                            .background(
                             RoundedRectangle(cornerRadius: 20.0, style: .continuous)
                                 .fill(Color.gray)
                                 .foregroundColor(Color(UIColor.systemBackground))
                                 .shadow(radius: 15)
                            )
                    }
                        Spacer()
                    
                    HStack{
                        
                        HStack{
                            Image(systemName: "heart.fill")
                                .font(.title2)
                            Text("\(heartRate)")
                                .font(.title2)
                            
                        }
                      
                            .padding(.horizontal,10)
                            .padding(.vertical,5)
                            .background(
                                RoundedRectangle(cornerRadius: 20.0, style: .continuous)
                                    .fill(Color.gray)
                                    .foregroundColor(Color(UIColor.systemBackground))
                                    .shadow(radius: 15)
                                
                            )
                            .frame(minWidth: 0, maxWidth: .infinity)

                          

                 
                        
                        Text(timeFormatted(elapsedSeconds))
                            .font((lastFeedbackMessage != nil) ? .title3: .largeTitle)
                            .padding(.horizontal,10)
                            .padding(.vertical,5)
                            .background(
                                RoundedRectangle(cornerRadius: 20.0, style: .continuous)
                                    .fill(Color.gray)
                                    .foregroundColor(Color(UIColor.systemBackground))
                                    .shadow(radius: 15)
                                
                            )
                            .frame(minWidth: 0, maxWidth: .infinity)

                       
                        HStack{
                            
                            Image(systemName: "target")
                                .font(.title2)
                            Text("90 %")
                                .font(.title2)
                              
                            
                        }
                            
                            .padding(.horizontal,10)
                            .padding(.vertical,5)
                            .background(
                                RoundedRectangle(cornerRadius: 20.0, style: .continuous)
                                    .fill(Color.gray)
                                    .foregroundColor(Color(UIColor.systemBackground))
                                    .shadow(radius: 15)
                                
                            )
                            .frame(minWidth: 0, maxWidth: .infinity)
                        

                        
                   
                          
                     
                    }
                    
                
                    
                  
                  
                    Spacer()
                    
                    workoutView
                        .frame(width: geometry.size.width, height: geometry.size.width * (4/3))
                        .blur(radius: (isDeviceMoving && !isCountingDown) || (poseDetectionManager.detectionFailed && !isCountingDown) ? 5 : 0)
                        .overlay(pauseButton, alignment: .topTrailing)
                        .overlay(counterView, alignment: .topLeading)
                        .overlay(
                            Group {
                                
                                
                                if isCountingDown {
                                    
                                    
                                    countdownOverlay
                                }
                                
                                else if poseDetectionManager.detectionFailed {
                                    detectionFailedView
                                    detectionFailedView
                                } else if isDeviceMoving {
                                    movementDetectionOverlay
                                }
                            },
                            alignment: .center
                        )
                    
                    
                    
                  
                    infoView
                    bottomButtosView
                }
               
              
                .background(Color(UIColor.systemBackground))
                .onAppear {
                  /*
                    self.requestHealthKitAuthorization()
                        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                            self.getHeartRate()
                   }
                   */
                       
                    nextExercise(increment: false)
                    let currentExercise = organizedExercisesGroups[currentGroup][currentExercise]
                    exerciseAnalyzer.isDisabled = true
                    exerciseAnalyzer.loadReferenceData(forExercise: currentExercise)
                    UIApplication.shared.isIdleTimerDisabled = true
                    
                  
                    
                }
                .onDisappear{
                    UIApplication.shared.isIdleTimerDisabled = false
                  print("Disappered")
                    synthesizer.stopSpeaking(at: .immediate)
                    
                }
                
                
                NavigationLink(destination: FinishWorkoutView(completedExercises: savedExercises, dismiss: $dismiss), isActive: $navigateToFinishWorkoutView) {
                    EmptyView()
                }
                
            }
            .padding(.horizontal)
            .padding(.top)
           
            
            .onChange(of: dismiss) {
                newValue in
                if newValue {
                    presentationMode.wrappedValue.dismiss()

                }
            }

            .onChange(of: repetitionCounter.repCounter) { newRepCount in
                let ce = organizedExercisesGroups[currentGroup][currentExercise]
                if (newRepCount >= ce.repetition && !(ce.name == "Plank")) {
                    organizedExercisesGroups[currentGroup][currentExercise].isCompleted = true
                    completeExercise(isFinishedPressed: false)
                    
                    if(!organizedExercisesGroups.allSatisfy({
                        group in group.allSatisfy{$0.isCompleted}
                    }))
                    {
                        nextExercise()
                    }
                    else{
                        stopTimer()
                        stopExerciseTimer()
                        stopStationaryTimer()
                        repetitionCounter.isDisabled = true
                        exerciseAnalyzer.isDisabled = true
                        poseDetectionManager.isDisabled = true
                       
                        
                        
                       navigateToFinishWorkoutView = true
                    }
                }
                
            }
            .onChange(of: exerciseElapsedSeconds) { elapsedsec in
                let ce = organizedExercisesGroups[currentGroup][currentExercise]
                if ((ce.name == "Plank") && (ce.duration ?? 0 == elapsedsec)) {
                    organizedExercisesGroups[currentGroup][currentExercise].isCompleted = true
                    completeExercise(isFinishedPressed: false)
                    
                    if(!organizedExercisesGroups.allSatisfy({
                        group in group.allSatisfy{$0.isCompleted}
                    }))
                    {
                        nextExercise()
                    }
                    else{
                        stopTimer()
                        stopExerciseTimer()
                        stopStationaryTimer()
                        
                        
                        navigateToFinishWorkoutView = true
                    }
                }
                
            }
            
            .onAppear{
                navigationCoordinator.isNavigating = true
                UIApplication.shared.isIdleTimerDisabled = true
            }
            .onReceive(exerciseAnalyzer.$feedbacks) { newFeedbacks in
                withAnimation {
                    if !newFeedbacks.isEmpty && !isCountingDown {
                        var totalDelay: Double = 0
                        

                        for feedback in newFeedbacks {
                            if feedback != lastSpokenFeedback && !lastFeedbackMessages.contains(feedback){
                                let delayForCurrentFeedback = totalDelay
                                let displayDuration: Double = 1.0

                                DispatchQueue.main.asyncAfter(deadline: .now() + delayForCurrentFeedback) {
                                    self.lastFeedbackMessage = feedback
                                    
                                  
                                    lastSpokenFeedback = feedback
                                }

                                DispatchQueue.main.asyncAfter(deadline: .now() + delayForCurrentFeedback + displayDuration) {
                                    if self.lastFeedbackMessage == feedback {
                                        self.lastFeedbackMessage = nil
                                    }
                                }

                                totalDelay += displayDuration
                            }
                        }
                        lastFeedbackMessages = newFeedbacks
                    }
                }
            }


            
            
            
            
           
          
           
        
        .navigationBarBackButtonHidden(true)

    



        
        
        
        
    }
 

  
    var movementDetectionOverlay: some View {
        Group {
            if isDeviceMoving {
                Text("Ne mozgassa a készüléket!.")
                    .font(.title)
                    .padding(10)
                    .foregroundColor(Color(UIColor.label))
                    .shadow(radius:10 )
            }
        }
    }

    
    var workoutView: some View {
      
            ZStack {
                cameraViewFrame
                   
                SetsView(organizedExercisesGroups: organizedExercisesGroups, currentGroup: currentGroup, currentExercise: currentExercise)
                   
                    
                
                
            }
            
            
           
            
         
        
    }
    
    public func send(setsData: [String: Any]) {
        guard WCSession.default.activationState == .activated else {
            print("WCSession is not activated")
            return
        }
        
        #if os(watchOS)
        guard WCSession.default.isCompanionAppInstalled else {
            print("Companion app is not installed")
            return
        }
        #else
        guard WCSession.default.isWatchAppInstalled else {
            print("Watch app is not installed")
            return
        }
        #endif
        
        do {
            // Convert the Exercise objects to Data using NSKeyedArchiver
            if let exercises = setsData["organizedExercisesGroups"] as? [[Exercise]] {
                let encodedExercises = try NSKeyedArchiver.archivedData(withRootObject: exercises, requiringSecureCoding: false)
                var modifiedSetsData = setsData
                modifiedSetsData["organizedExercisesGroups"] = encodedExercises
                
                let encodedData = try NSKeyedArchiver.archivedData(withRootObject: modifiedSetsData, requiringSecureCoding: false)
                WCSession.default.sendMessageData(encodedData, replyHandler: { (response) in
                    if let responseData = response as? Data {
                        do {
                            if let responseDict = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(responseData) as? [String: Any] {
                                print("Received response: \(responseDict)")
                            }
                        } catch {
                            print("Failed to decode response data: \(error.localizedDescription)")
                        }
                    }
                }, errorHandler: { (error) in
                    print("Error sending message: \(error.localizedDescription)")
                })
            }
        } catch {
            print("Failed to encode sets data: \(error.localizedDescription)")
        }
    }


 
    
  
    var cameraViewFrame: some View {
        ZStack {
            cameraView
                .frame(width: .infinity , height: .infinity)
                .background(Color(UIColor.secondarySystemBackground))
                .foregroundColor(.white)
                .mask(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 0)
               
               
                
            
            if (isCountingDown && countdownSeconds >= 5) {
                let gifname = gifNameForExercise(organizedExercisesGroups[currentGroup][currentExercise].name)
                let exerciseName = organizedExercisesGroups[currentGroup][currentExercise].name
                if exerciseName == "Plank" {
                    ZStack {
                        Color.white
                            .frame(width: .infinity, height: .infinity)

                        Image("plank.jpeg")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: .infinity, height: .infinity)
                            .clipped()
                    }
                    .mask(RoundedRectangle(cornerRadius: 20, style: .continuous))
                           
                          
                          

                        
                       
                    
                } else  {
                    if((gifname) != nil)
                    {
                        AnimatedImage(name: gifname!, isAnimating: $isAnimating)
                            .mask(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .frame(width: .infinity, height: .infinity)
                    }
                   
                      
                }
            }
        }
        
    }


    
    @ViewBuilder
    private var detectionFailedView: some View {
        Group {
            if poseDetectionManager.detectionFailed {
                
                
                Text("Pozicionálja a telefont, hogy látszódjon!")
                    .font(.title)
                    .padding(10)
                    .foregroundColor(Color(UIColor.label))
                    .shadow(radius:10 )
                
            }
        }
    }
    @ViewBuilder
    private var counterView: some View {
        if #available(iOS 17.0, *) {
            if let duration = organizedExercisesGroups[currentGroup][currentExercise].duration {
                Text("\(timeFormatted(exerciseElapsedSeconds)) / \(timeFormatted(duration))")
                    .font(.largeTitle)
                    .padding(.horizontal,10)
                    .padding(.vertical,5)
                
                
                    .background(
                        RoundedRectangle(cornerRadius: 20.0, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
                            .fill(Color.gray)
                            .opacity(0.5)
                            .foregroundColor(Color(UIColor.systemBackground))
                            .shadow(radius: 15)
                    )
            }
            else
            {
                Text("\(repetitionCounter.repCounter) / \(organizedExercisesGroups[currentGroup][currentExercise].repetition)")
                    .font(.largeTitle)
                   
                    .padding(.horizontal,10)
                    .padding(.vertical,5)
                    .onChange(of: repetitionCounter.repCounter, {
                        if(repetitionCounter.repCounter != 0)
                        {
                            exerciseAnalyzer.setShouldResetTrue()
                        }
                    })
                
                
                    .background(
                        RoundedRectangle(cornerRadius: 20.0, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
                            .fill(Color.gray)
                            .opacity(0.5)
                            .foregroundColor(Color(UIColor.systemBackground))
                            .shadow(radius: 15)
                    )
            }
        } else {
          
        }
    }
    
    
   









   
    
    var cameraView: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    CameraView(poseDetectionManager: poseDetectionManager, repetitionCounter: repetitionCounter, exerciseAnalyzer: exerciseAnalyzer)
                        .mask(isCameraViewBig ? RoundedRectangle(cornerRadius: 0) : RoundedRectangle(cornerRadius: 20))
                        .frame(width: 112.5, height: 150)
                        
                        .scaleEffect(isCameraViewBig ? min(geometry.size.width / 112.5, geometry.size.height / 150) : 1, anchor: .bottomTrailing)
                    
                        .animation(.easeInOut)
                }
                .padding(.bottom, isCameraViewBig ? 0 : 40)
                .padding(.trailing, isCameraViewBig ? 0 : 16)
            }
          
        }
    }
    
    var pauseButton: some View {
        Button(action: {
            withAnimation(.smooth){
                pauseOrplayWorkout()
            }
        }) {
            
            Image(systemName: isPaused ? "play.circle" : "pause.circle")
                .font(.largeTitle)
                .foregroundColor(Color(UIColor.label))
        }
        .padding(10)
    }
    
    var infoView: some View {
        HStack {
            VStack(alignment: .leading){
                Group{
                       let currentExerciseObj = organizedExercisesGroups[currentGroup][currentExercise]
                       let completedSets = completedSetsForExercise(exercise: currentExerciseObj)
                       let totalSets = setsForExercise(exercise: currentExerciseObj)
                    Text("\(organizedExercisesGroups[currentGroup][currentExercise].name)")
                                   .font(.largeTitle)
                    if(completedSets != totalSets)
                    {
                        Text("\(completedSets+1) / \(totalSets) sorozat")
                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    }
                    else{
                        Text("\(completedSets) / \(totalSets) sorozat")
                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    }
                }
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(Color(UIColor.label))
            
            VStack{
                Text("\(timeFormatted(exerciseElapsedSeconds))")
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .onAppear{
                        startTimer()
                        startExerciseTimer()
                    }
                    .onDisappear{
                        stopTimer()
                        stopExerciseTimer()
                        stopStationaryTimer()
                    }
                
            }
        }
    }
    var countdownOverlay: some View {
    
            VStack {
                Group{
                    if showCountdownText {
                        Text("Helyezkedj el a következő gyakorlathoz!")
                            .font(.title3)
                            .transition(.move(edge: .top))
                    }
                    
                    Text("\(countdownSeconds)")
                        .font(.system(size: 60))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(maxHeight: .infinity)
            .background(Color.black.opacity(0.7))
            .foregroundColor(.white)
            .cornerRadius(20)
        
    }


    
    
    var bottomButtosView: some View {
        
        HStack(alignment: .center){
            
            Button(action: {
                
                stopTimer()
                stopExerciseTimer()
                stopStationaryTimer()
                completeExercise(isFinishedPressed: true)
              
             
                
            }) {
                Text("Befejezés")
                    .padding()
                    .foregroundColor(Color(UIColor.label))
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.gray)
                    )
                    .shadow(radius: 15)
            }
            Button(action: {
               
                organizedExercisesGroups[currentGroup][currentExercise].isCompleted = true
                completeExercise(isFinishedPressed: false)
                if(!organizedExercisesGroups.allSatisfy({
                    group in group.allSatisfy{$0.isCompleted}
                }))
                {
                    
                   nextExercise()
                }
            }) {
                HStack{
                    Text("Következő")
                    Image(systemName: "arrow.right.to.line")
                    
                        .font(.largeTitle)
                }
                .foregroundColor(Color(UIColor.label))
                .padding()
                .frame(maxWidth: .infinity)
                .frame(maxHeight: 60)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray)
                )
                .shadow(radius: 15)
            }
        }
        
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundColor(Color(UIColor.label))
        
        
        
        
    }
  
  
    func nextExercise(increment: Bool = true) {
        isCountingDown = true
        showCountdownText = true
        countdownSeconds = 10
        lastFeedbacks = []
        lastSpokenFeedback = nil
        lastFeedbackMessage = nil
        lastFeedbackMessages = []
        exerciseAnalyzer.shouldReset = false
        exerciseAnalyzer.feedbacks = []
        
       
        
        if increment {
            stopCountdownTimer()
           isPaused = false
            currentExercise += 1
          
            if currentExercise >= organizedExercisesGroups[currentGroup].count {
                currentExercise = 0
                currentGroup += 1
                if currentGroup >= organizedExercisesGroups.count {
                  
                    return
                }
            }
        }
      
        stopExerciseTimer()
        stopTimer()
        exerciseElapsedSeconds = 0
        startCountdownTimer()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showCountdownText = false
                
            }
        }
       
        
     
      
      
    }

  


    func gifNameForExercise(_ exerciseName: String) -> String? {
        switch exerciseName {
            case "Fekvőtámasz":
                return "pushup.gif"
            case "Guggolás":
                return "squat.gif"
      
        case "Felülés":
            return "situp.gif"
        default:
                   return nil
         
           
        }
    }



    
   
    func startTimer() {
        if !isCountingDown {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                elapsedSeconds += 1
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    func startExerciseTimer() {
        if !isCountingDown {
            exerciseTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                exerciseElapsedSeconds += 1
            }
        }
    }

  

    func stopExerciseTimer() {
        exerciseTimer?.invalidate()
        exerciseTimer = nil
    }
    func startMotionUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.1
            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!) { (motion, error) in
                if let motion = motion {
                    if sqrt(pow(motion.userAcceleration.x, 2) +
                            pow(motion.userAcceleration.y, 2) +
                            pow(motion.userAcceleration.z, 2)) > 0.02 {
                        
                        
                        self.isDeviceMoving = true
                        repetitionCounter.isDisabled = true
                        exerciseAnalyzer.isDisabled = true
                        poseDetectionManager.isDisabled = true
                        
                        exerciseAnalyzer.resetPoses()
                        
                      
                                           
                        
                    }
                    else{
                        
                                                 self.isDeviceMoving = false
                                                 self.repetitionCounter.isDisabled = false
                                                 self.exerciseAnalyzer.isDisabled = false
                                                 self.poseDetectionManager.isDisabled = false
                    }
                }
            }
        }
    }

    func startStationaryTimer() {
       
      
        print(isCountingDown)
        if stationaryTimer != nil || isCountingDown { return }

       

        stationaryTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if !self.isDeviceMoving {
             
                self.stationarySeconds += 1
                if self.stationarySeconds >= 3 {
                    self.stationarySeconds = 0
                    if self.timer == nil {
                        self.startTimer()
                    }
                    if self.exerciseTimer == nil {
                        self.startExerciseTimer()
                    }
                }
            } else {
              
                self.stationarySeconds = 0
                self.stopTimer()
                self.stopExerciseTimer()
            }
        }
    }

    func stopStationaryTimer() {
        stationaryTimer?.invalidate()
        stationaryTimer = nil
    }
    func startCountdownTimer() {
        poseDetectionManager.isDisabled = true
        repetitionCounter.isDisabled = true
        exerciseAnalyzer.isDisabled = true
        exerciseAnalyzer.resetPoses()
        exerciseAnalyzer.resetPerformanceTracking()
        let currEx = organizedExercisesGroups[currentGroup][currentExercise]
        
        exerciseAnalyzer.loadReferenceData(forExercise: currEx)
        
        repetitionCounter.updateExercise(newExercise: currEx)
        repetitionCounter.repCounter = 0
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if countdownSeconds > 0 {
                countdownSeconds -= 1
            } else {
                isCountingDown = false
                stopCountdownTimer()
               
                startExerciseTimer()
                startTimer()
                stationarySeconds = 0
                
                repetitionCounter.isDisabled = false
                poseDetectionManager.isDisabled = false
                exerciseAnalyzer.isDisabled = false
            }
        }
    }

    func stopCountdownTimer() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        //startMotionUpdates()
        startStationaryTimer()
       
    }
    func completedSetsForExercise(exercise: Exercise) -> Int {
     
        let allExercises = organizedExercisesGroups.flatMap { $0 }
        
        let completedMatchingExercises = allExercises.filter { $0.name == exercise.name && $0.isCompleted }
        
        return completedMatchingExercises.count
    }
    func setsForExercise(exercise: Exercise) -> Int {
    
        let allExercises = organizedExercisesGroups.flatMap { $0 }
    
        let matchingExercises = allExercises.filter { $0.name == exercise.name }
        
        return matchingExercises.count
    }
   func pauseOrplayWorkout()
    {
        if(isPaused)
        {
            isPaused = false
            poseDetectionManager.isDisabled = false
            repetitionCounter.isDisabled = false
            exerciseAnalyzer.isDisabled = false
            startTimer()
            startExerciseTimer()
            startStationaryTimer()
        }
        else{
            isPaused = true
            poseDetectionManager.isDisabled = true
            repetitionCounter.isDisabled = true
            exerciseAnalyzer.isDisabled = true
            stopTimer()
            stopExerciseTimer()
            stopStationaryTimer()
        }
    }
    func completeExercise(isFinishedPressed : Bool) {
        if(exerciseElapsedSeconds > 0 )
        {
            organizedExercisesGroups[currentGroup][currentExercise].isCompleted = true
            let currentExercise = organizedExercisesGroups[currentGroup][currentExercise]
            let performance = exerciseAnalyzer.calculatePerformancePercentage()
       
            
            
            saveCompletedExercise(name: currentExercise.name, correctness: performance, date: date, repetition: repetitionCounter.repCounter, series: currentExercise.set, elapsedExerciseTime: exerciseElapsedSeconds)
            
            
        }
        if organizedExercisesGroups.allSatisfy({ group in group.allSatisfy { $0.isCompleted } }) {
                    navigateToFinishWorkoutView = true
                }
        
        if(isFinishedPressed)
        {
            let isAnyExerciseCompleted = organizedExercisesGroups.contains { group in
                    group.contains { $0.isCompleted }
                }
            let allExerciseCompleted = organizedExercisesGroups.allSatisfy({ group in group.allSatisfy { $0.isCompleted } })
            
            if (!isAnyExerciseCompleted)
            {
                presentationMode.wrappedValue.dismiss()
            }
            else{
                navigateToFinishWorkoutView = true
            }
           

        }
        
        
        
       
            
       

      
    }


    
   

    func saveCompletedExercise(name: String, correctness: Double, date: Date, repetition: Int, series: Int, elapsedExerciseTime: Int) {
        
        guard !name.isEmpty else {
               print("Invalid exercise data. Not saving.")
               return
           }
            
            let newExercise = CompletedExercise(context: PersistenceController.shared.container.viewContext)
            newExercise.name = name
            newExercise.correctness = correctness
            newExercise.date = date
            newExercise.repetition = Int32(repetition)
            newExercise.series = Int32(series)
            newExercise.elapsedExerciseTime = Int32(elapsedExerciseTime)
            
            newWorkout.addToWorkoutToCompletedExercise(newExercise)
            
        
            do {
                try PersistenceController.shared.container.viewContext.save()
                let exerciseData = ExerciseData(name: name, elapsedTime: Int(elapsedExerciseTime), repetitions: repetition, series: series, correctness: correctness)
                savedExercises.append(exerciseData)
            } catch {
                print("Hiba történt az adatok mentésekor: \(error)")
            }
        
   
            let fetchRequest: NSFetchRequest<Workout> = Workout.fetchRequest()
            do {
                let items = try viewContext.fetch(fetchRequest)
                print(items)
            } catch {
                print("Error fetching data: \(error)")
            }
        
    }
    func speak(text: String, language: String = "hu-HU") {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = 0.5

        synthesizer.speak(utterance)
    }

}




struct InWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
      
        InWorkoutView(organizedExercisesGroups: Exercises.groupedSampleExercises)
            
            .environmentObject(NavigationCoordinator())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

