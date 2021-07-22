package nl.foodticket.foodticket

import android.content.Context
import android.webkit.JavascriptInterface

class JavascriptBridge(private val context: Context, private val listener: Listener) {

    @JavascriptInterface
    fun postMessage(message: String) {
        listener.updateValue(message)
    }

    interface Listener {
        fun updateValue(value: String)
    }
}