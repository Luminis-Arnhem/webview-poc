# webview-poc
Proof of concept of communication between a webapplication and a native app.

# How does it work?

## Webapplication
The 'webapplication' at the moment is no more than a single HTML page with some inline Javascript. 
In a more production like setup this could be a full webapplication with multiple files, however as this application is not actually loaded anywhere but loaded into
the native applications as a file, it was far easier to stick to a single file.

In the window.onload the application registers an eventlistener on the checkbox, when the checkbox is altered this listener goes off and calls window.checkBoxToggle.
This function in window comes from a Javascript wrapper loaded as part of the native applications meaning that calling this function allows the webapplication to communication to the native application. 
Into the function the application passes a callback which is called by native application as a means to communicate back. When the callback is indeed called, it takes the message it receives and displays it in the H2 element.

## iOS application
In the viewDidLoad of the ViewController the iOS application does a few things:
- It registers itself as a handle for 'toggleMessageHandler'.
- It loads 'foodticketWrapper.js' which is the Javascript wrapper around the webapplication into the webview.
- It opens the webapplication.

By doing the three things above, the iOS application can receive the calls to window.checkBoxToggle in the 'WKScriptMessageHandler' from the webapplication.

In this handler it then asks the webview to execute window.toggleMessageCallback which is the
callback given by the webapplication and put onto window by the wrapper. This way the iOS application can send information back to the webapplication.

## Android application
The Android application loads the webapplication in the onStart method of the MainActivity.

In the onCreate of the same activity it registers a listener for onPageFinished. When this is called when the page loads, it loads 'foodticketWrapper.js' which is once again the wrapper around the webapplication.

Also in the onCreate it registers a JavascriptInterface with the webview calld JavascriptBridge, located in the Kotlin file with the same name. This allows it to receive the calls to window.checkBoxToggle from the webapplication. 

Receiving the call from the webapplication results in a call to updateValue() on the MainActivity. In this method it then asks the webview to execute window.toggleMessageCallback which is the
callback given by the webapplication and put onto window by the wrapper. This way the Android application can send information back to the webapplication.
