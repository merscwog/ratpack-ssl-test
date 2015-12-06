import ratpack.ssl.SSLContexts

import static ratpack.groovy.Groovy.ratpack

ratpack {
  serverConfig {
    requireClientSslAuth true

    env()

    ssl(SSLContexts.sslContext(
	  System.getenv('RATPACK_SERVER_SSL__KEYSTORE_FILE') as File,
          System.getenv('RATPACK_SERVER_SSL__KEYSTORE_PASSWORD'),
	  System.getenv('RATPACK_SERVER_SSL__TRUSTSTORE_FILE') as File,
          System.getenv('RATPACK_SERVER_SSL__TRUSTSTORE_PASSWORD')))
  }
  handlers {
    get {
      render "Hello World!"
    }
  }
}
