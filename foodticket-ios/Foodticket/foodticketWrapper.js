class NativeAPI {
    checkBoxCallback;
    
    appLoaded(checkBoxCallback) {
        this.checkBoxCallback = checkBoxCallback
    }
    
    checkBoxToggle(toggled) {
        var executor = window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.toggleMessageHandler
            ? window.webkit.messageHandlers.toggleMessageHandler : AndroidInterface;

        if (executor != undefined) {
            // This should be a primitive value (e.g. JSON converted to a string is possible)
            executor.postMessage(toggled);
        }
    }
}

window.nativeAPI = new NativeAPI()
