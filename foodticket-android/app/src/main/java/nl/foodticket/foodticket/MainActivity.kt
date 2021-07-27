package nl.foodticket.foodticket

import android.annotation.SuppressLint
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.lifecycle.lifecycleScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import nl.foodticket.foodticket.databinding.ActivityMainBinding
import java.io.InputStream
import java.net.URL

class MainActivity : AppCompatActivity(), JavascriptBridge.Listener {

    private lateinit var binding : ActivityMainBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)

        @SuppressLint("SetJavaScriptEnabled")
        binding.webview.settings.javaScriptEnabled = true
        binding.webview.webViewClient = object : WebViewClient() {
            override fun onPageFinished(view: WebView, url: String) {
                assets.open("foodticketWrapper.js")?.let {
                    loadContentFromInputStream(it) { source ->
                        val actual = """javascript:(function() {
                            ${source}
                            })()
                        """.trimIndent();
                        binding.webview.loadUrl(actual)
                    }
                }
            }
        }
        binding.webview.addJavascriptInterface(JavascriptBridge(this, this), "AndroidInterface")

        setContentView(binding.root)
    }

    override fun onStart() {
        super.onStart()

        loadContentFromUrl(html) { source ->
            binding.webview.loadDataWithBaseURL(null, source,"text/html; charset=utf-8", "base64", null)
        }
    }

    override fun updateValue(value: String) {
        lifecycleScope.launch(Dispatchers.Main) {
            binding.webview.evaluateJavascript("window.toggleMessageCallback(\"$value\");") {}
        }
    }

    private fun loadContentFromUrl(url: String, block: (String) -> Unit) = lifecycleScope.launch(Dispatchers.IO) {
        val connection = URL(url).openConnection()

        val stream = connection.getInputStream()
        loadContentFromInputStream(stream, block)
    }

    private fun loadContentFromInputStream(inputStream: InputStream, block: (String) -> Unit) = lifecycleScope.launch(Dispatchers.IO) {
        val source = inputStream.reader().buffered().use { it.readText() }

        withContext(Dispatchers.Main) {
            block(source)
        }
    }

    companion object {
        private const val html = "https://raw.githubusercontent.com/Luminis-Arnhem/webview-poc/master/foodticket-web/index.html"
    }
}