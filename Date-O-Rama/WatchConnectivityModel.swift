import Foundation
import WatchConnectivity
import Combine

final class WatchConnectivityModel: NSObject, ObservableObject {
    @Published var isPaired: Bool = false

    private var session: WCSession?

    override init() {
        super.init()
        if WCSession.isSupported() {
            let s = WCSession.default
            session = s
            s.delegate = self
            s.activate()
            // Initial snapshot
            isPaired = s.isPaired
        } else {
            isPaired = false
        }
    }
}

extension WatchConnectivityModel: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            self?.isPaired = session.isPaired
        }
    }

    func sessionWatchStateDidChange(_ session: WCSession) {
        DispatchQueue.main.async { [weak self] in
            self?.isPaired = session.isPaired
        }
    }

    // iOS only delegate requirement
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    #endif
}
