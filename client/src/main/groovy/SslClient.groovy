import groovyx.net.http.HTTPBuilder
import javax.net.ssl.SSLContext
import org.apache.http.conn.ssl.SSLSocketFactory
import org.apache.http.conn.scheme.Scheme

class SslClient {
  static void main(String[] ars) {
    def httpBuilder = new HTTPBuilder('https://localhost:5050')
    SSLContext sc = SSLContext.getDefault()
    SSLSocketFactory sf = new SSLSocketFactory(sc)
    sf.hostnameVerifier=SSLSocketFactory.ALLOW_ALL_HOSTNAME_VERIFIER

    httpBuilder.client.connectionManager.schemeRegistry.register(new Scheme('https', sf, 5050))
    def result = httpBuilder.get(path: '/')

    println '************************************'
    println '************************************'
    println '************************************'
    println result.text
    println '************************************'
    println '************************************'
    println '************************************'
  }
}
