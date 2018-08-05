(defproject srv-clojure "0.1.0-SNAPSHOT"
  :description "Server for swap, written in Clojure."
  :license {:name "2-Clause BSD"
            :url "https://opensource.org/licenses/BSD-2-Clause"}
  :plugins [[lein-ring "0.9.7"]]
  :dependencies [[org.clojure/clojure "1.9.0"]
                 [ring/ring-core "1.6.3"]
                 [ring/ring-jetty-adapter "1.6.3"]
                 [ring/ring-json "0.4.0"]
                 [fuck-cors "0.1.7"]
                 [compojure "1.6.1"]]
  :ring {:handler srv-clojure.core/app
         :nrepl {:start? true
                 :port 9998}}
  :profiles {:dev {:dependencies [[javax.servlet/servlet-api "2.5"]
                                  [ring-mock "0.1.5"]]}})
