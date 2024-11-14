import UIKit
import Network
import Foundation
import React
import IOS_SDK_V2  // Assuming IOS_SDK_V2 contains EdgeControler and related classes

@objc(EdgeModule)
class EdgeModule: UIViewController {

    private let edgeControler = EdgeControler()  // Updated to use EdgeControler instead of EdgeModule
    
    @objc
    func startPayment(_ redirectUrl: String, callback: @escaping RCTResponseSenderBlock) {
        print("Redirect URL 1: \(redirectUrl)")

        DispatchQueue.main.async {
            // Get the rootViewController using modern iOS APIs
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = windowScene.windows.first?.rootViewController else {
                callback(["NO_ACTIVITY", "No root view controller found"])
                return
            }

            // Check for internet connectivity
            self.checkForInternet { isConnected in
                if isConnected {
                    let paymentCallbackHandler = PaymentCallbackHandler(callback: callback) // ResponseCallback handler
                    print("Initiating payment with URL: \(redirectUrl)") // Log the URL being used

                    // Ensure this is called on the main thread
                    DispatchQueue.main.async {
                        self.edgeControler.startPayment(from: rootViewController, withURL: redirectUrl, callBack: paymentCallbackHandler)
                    }
                } else {
                    callback(["NO_INTERNET", "No internet connection available"])
                    self.showToast("No internet connection available")
                }
            }
        }
    }

    // Function to check for internet availability using the Network framework
    func checkForInternet(completion: @escaping (Bool) -> Void) {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkMonitor")
        
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                completion(true)
            } else {
                completion(false)
            }
            monitor.cancel()  // Stop monitoring after checking once
        }

        monitor.start(queue: queue)
    }

    // Helper function to display toast-like messages in iOS
    private func showToast(_ message: String) {
        DispatchQueue.main.async {
            if let rootViewController = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootView = rootViewController.windows.first?.rootViewController {
                let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                rootView.present(alert, animated: true)
                
                // Duration for the "toast"
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    alert.dismiss(animated: true, completion: nil)
                }
            }
        }
    }

    @objc
    static func requiresMainQueueSetup() -> Bool {
        return true  // This ensures that the module is initialized on the main thread.
    }
}

// Conform to the ResponseCallback protocol as defined in IOS_SDK_V2
class PaymentCallbackHandler: NSObject, ResponseCallback {
    let callback: RCTResponseSenderBlock

    init(callback: @escaping RCTResponseSenderBlock) {
        self.callback = callback
    }

    // Implement all required methods from the ResponseCallback protocol
    func onCancelTxn(code: Int, message: String?) {
        callback(["Cancel Transaction", code, message ?? ""])
        showToast(message ?? "Transaction canceled")
    }

    func onErrorOccured(code: Int, message: String?) {
        callback(["Error Occurred", code, message ?? ""])
        showToast(message ?? "Error occurred")
    }

    func internetNotAvailable(code: Int, message: String?) {
        callback(["No Internet", code, message ?? ""])
        showToast(message ?? "No internet connection")
    }

    func onPressedBackButton(code: Int, message: String?) {
        callback(["Pressed Back", code, message ?? ""])
        showToast(message ?? "Back button pressed")
    }

    func onTransactionResponse() {
        callback(["Transaction successful"])
        print("Transaction successful")
    }

    // Helper function to display toast-like messages in iOS
    private func showToast(_ message: String) {
        DispatchQueue.main.async {
            if let rootViewController = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootView = rootViewController.windows.first?.rootViewController {
                let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                rootView.present(alert, animated: true)
                
                // Duration for the "toast"
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    alert.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}
