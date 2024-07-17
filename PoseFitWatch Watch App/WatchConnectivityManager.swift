import Foundation
import WatchConnectivity

struct NotificationMessage: Identifiable {
    let id = UUID()
    let text: String
}

final class WatchConnectivityManager: NSObject, ObservableObject {
    
    @Published var organizedExercisesGroups: [[Exercise]] = []
    @Published var currentGroup = 0
    @Published var currentExercise = 0
    
    static let shared = WatchConnectivityManager()
    @Published var notificationMessage: NotificationMessage? = nil
    
    private override init() {
        super.init()
        
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    private let kMessageKey = "message"
    
    func send(_ message: String) {
        guard WCSession.default.activationState == .activated else {
            return
        }
        #if os(iOS)
        guard WCSession.default.isWatchAppInstalled else {
            return
        }
        #else
        guard WCSession.default.isCompanionAppInstalled else {
            return
        }
        #endif
        
        WCSession.default.sendMessage([kMessageKey: message], replyHandler: nil) { error in
            print("Cannot send message: \(String(describing: error))")
        }
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed with error: \(error.localizedDescription)")
        } else {
            print("WCSession activated with state: \(activationState.rawValue)")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        if let notificationText = message[kMessageKey] as? String {
            DispatchQueue.main.async { [weak self] in
                self?.notificationMessage = NotificationMessage(text: notificationText)
            }
        }
    }
    
    private func session(_ session: WCSession, didReceiveData data: Data) {
        do {
            if let setsData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                if let organizedExercisesGroups = setsData["organizedExercisesGroups"] as? [[Exercise]] {
                    self.organizedExercisesGroups = organizedExercisesGroups
                }
                if let currentGroup = setsData["currentGroup"] as? Int {
                    self.currentGroup = currentGroup
                }
                if let currentExercise = setsData["currentExercise"] as? Int {
                    self.currentExercise = currentExercise
                }
                print(organizedExercisesGroups)
            }
        } catch {
            print("Failed to decode sets data: \(error.localizedDescription)")
        }
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    #endif
}
