(ns srv-clojure.token
  (:require [clojure.string :as string]
            [clj-time.core :as t]
            [clj-time.coerce :as tc]
            [srv-clojure.crypto :as crypto]))

(import (javax.crypto Cipher KeyGenerator SecretKey)
        (javax.crypto.spec SecretKeySpec)
        (java.security SecureRandom)
        (org.apache.commons.codec.binary Base64))

(def token-key "foobar42")

(defn create-token [name]
  (let [ct-token (str name ":" (tc/to-long (t/now)))]
    (crypto/encrypt ct-token token-key)))

(defn- decrypt-token [token]
  (try (crypto/decrypt token token-key)
       (catch Exception e "NoName:42")))

(defn verify-token-with-to [token minutes]
  (let [ct-token (decrypt-token token)
        [n, time-str] (string/split ct-token #":")
        time (tc/from-long (Long/valueOf time-str))
        exp-time (t/plus time (t/minutes minutes))
        cur-time (t/now)]
    (prn n)
    (prn cur-time)
    (prn exp-time)
    (t/after? exp-time cur-time)))

(defn verify-token [token]
  (verify-token-with-to token 10))

(defn name-from-token [token]
  (let [ct-token (decrypt-token token)
        [name, _] (string/split ct-token #":")]
    name))
