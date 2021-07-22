var _selector = document.querySelector('input[name=myCheckbox]');
_selector.addEventListener('change', function(event) {
    var message = (_selector.checked) ? "Toggle Switch is on" : "Toggle Switch is off";

    var executor = window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.toggleMessageHandler
        ? window.webkit.messageHandlers.toggleMessageHandler : AndroidInterface;

    if (executor != undefined) {
        // This should be a primitive value (e.g. JSON converted to a string is possible)
        executor.postMessage(message);
    }
});
