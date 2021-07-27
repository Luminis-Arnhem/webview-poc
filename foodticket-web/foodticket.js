window.onload = function() {
    var _selector = document.querySelector('input[name=myCheckbox]');
    _selector.addEventListener('change', function(event) {
        window.checkBoxToggle(_selector.checked, function(message) {
            document.getElementById('value').innerText = message;
        });
    });
}