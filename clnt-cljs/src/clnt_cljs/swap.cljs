(ns clnt-cljs.swap
  (:require [clnt-cljs.state :refer [update-groups update-token]]
            [ajax.core :refer [GET POST]]))

(def swap-url "http://localhost:3000/swap/")

(defn get-groups [s]
  (GET (str swap-url "groups")
    :response-format :json
    :keywords? true
    :handler (fn [r]
               ;; (println (str "Groups: " r))
               (swap! s update-groups (:groups r)))
    ;; error-handler ??
    ))

(defn login [s auth]
  (POST (str swap-url "auth")
    :format :json
    :response-format :json
    :keywords? true
    :params auth
    :handler (fn [r]
               ;; (println (str "Auth: " r))
               (swap! s update-token (:token r)))
    ;; error-handler ??
    ))

(defn renew-token [s token]
  (POST (str swap-url "renew-token")
    :format :json
    :response-format :json
    :keywords? true
    :params {:token token}
    :handler (fn [r]
               (println (str "Renew-token: " r))
               (swap! s update-token (:token r)))
    :error-handler (fn [e] (println e)
                     (swap! s update-token nil))))

(defn swap [s token]
  (POST (str swap-url "swap")
    :format :json
    :response-format :json
    :keywords? true
    :params {:token token}
    :handler (fn [r]
               (println (str "Swap: " r))
               (swap! s update-groups (:groups r))
               )
    :error-handler (fn [e] (println e)
                     (renew-token s token))))
