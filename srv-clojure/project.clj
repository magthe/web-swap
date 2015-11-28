(defproject srv-clojure "0.1.0-SNAPSHOT"
  :description "Server for swap, wirtten in Clojure."
  :url "http://example.com/FIXME"
  :license {:name "Eclipse Public License"
            :url "http://www.eclipse.org/legal/epl-v10.html"}
  :plugins [[lein-ring "0.9.7"]]
  :dependencies [[org.clojure/clojure "1.7.0"]
                 [ring/ring-core "1.4.0"]
                 [ring/ring-jetty-adapter "1.4.0"]
                 [ring/ring-json "0.4.0"]
                 [ring-cors "0.1.7"]
                 [compojure "1.4.0"]]
  :ring {:handler srv-clojure.core/app
         :nrepl {:start? true
                 :port 9998}}
  :profiles {:dev {:dependencies [[javax.servlet/servlet-api "2.5"]
                                  [ring-mock "0.1.5"]]}})
