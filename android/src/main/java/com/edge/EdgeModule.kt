package com.edge

import android.util.Log
import com.example.edgelibrary.EdgeManager
import com.example.edgelibrary.connectivity.InternetConnection
import com.example.edgelibrary.callbacks.EdgeResponseCallback
import android.widget.Toast
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.Callback

class EdgeModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {
  private val edgeManager: EdgeManager = EdgeManager()

  override fun getName(): String {
    return "EdgeModule"
  }

  @ReactMethod
  fun startPayment(redirectUrl: String, callback: Callback) {
    val activity = currentActivity

    if (activity != null) {
      // Check if the internet is available
      if (InternetConnection.checkForInternet(activity)) {
        // Start the payment process with the EdgeManager
        edgeManager.startPayment(activity, redirectUrl, object : EdgeResponseCallback {

          override fun onCancelTxn(code: Int, message: String?) {
            callback.invoke("Cancel Transaction", code, message)
            Toast.makeText(reactApplicationContext, message, Toast.LENGTH_LONG).show()
          }

          override fun onErrorOccured(code: Int, message: String?) {
            callback.invoke("Error Occurred", code, message)
            Toast.makeText(reactApplicationContext, message, Toast.LENGTH_LONG).show()
          }

          override fun onInternetNotAvailable(code: Int, message: String?) {
            callback.invoke("No Internet", code, message)
            Toast.makeText(reactApplicationContext, message, Toast.LENGTH_LONG).show()
          }

          override fun onPressedBackButton(code: Int, message: String?) {
            callback.invoke("Pressed Back", code, message)
            Toast.makeText(reactApplicationContext, message, Toast.LENGTH_LONG).show()
          }

          override fun onTransactionResponse() {
            callback.invoke("Transaction successful")
            Log.e("Response here", "Transaction successful")
          }
        })
      } else {
        callback.invoke("NO_INTERNET", "No internet connection available")
      }
    } else {
      callback.invoke("NO_ACTIVITY", "No activity found")
    }
  }

  companion object {
    const val NAME = "Edge"
  }
}
