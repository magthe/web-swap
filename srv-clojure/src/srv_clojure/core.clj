(ns srv-clojure.core
  (:require [compojure.core :refer :all]
            [ring.middleware.json :refer :all]
            [compojure.handler :as handler]
            [ring.util.response :refer [response]]
            [compojure.route :as route]
            [srv-clojure.token :as token]
            [srv-clojure.groups :as groups]))

(def users
  [{:name "Viveka", :pwords ["magnus", "andita"]},
   {:name "Sarah", :pwords ["maria", "chris"]}])

(def groups (atom (groups/create-groups ["Viveka"] ["Sarah"])))

(defn do-auth [msg]
  (defn verify-auth-msg []
    (and (contains? msg :name) (contains? msg :pword)))

  (defn verify [name pword]
    (let [user (filter (fn [u] (= (:name u) name)) users)]
      (if (empty? user) false
          (some (fn [p] (= pword p)) (:pwords (first user))))))

  (if-not (verify-auth-msg)
    (response {:error "Improper auth message"})
    (if-not (verify (:name msg) (:pword msg))
      (response {:error "Invalid credentials"})
      (response {:token (token/create-token (:name msg))}))))

(defn do-renew-token [msg]
  (defn verify-renew-token-msg []
    (contains? msg :token))

  (if-not (verify-renew-token-msg)
    (response {:error "Improper renew-token message"})
    (if-not (token/verify-token-with-to (:token msg) 20)
      (response {:error "Bad token"})
      (let [name (token/name-from-token (:token msg))]
        (response {:token (token/create-token name)})))))

(defn do-groups []
  (response {:groups @groups}))

(defn do-swap [msg]
  (defn verify-swap-msg []
    (contains? msg :token))

  (if-not (verify-swap-msg)
    (response {:error "Improper swap message"})
    (if-not (token/verify-token (:token msg))
      (response {:error "Bad token"})
      (let [name (token/name-from-token (:token msg))]
        (response {:groups (swap! groups groups/perform-swap name)})))))

(defroutes app-routes
  (context "/swap" []
    (POST "/auth" req (do-auth (:kw-body req)))
    (POST "/renew-token" req (do-renew-token (:kw-body req)))
    (GET "/groups" [] (do-groups))
    (POST "/swap" req (do-swap (:kw-body req))))

  (route/not-found (response {:error "Function not found"})))

(defn- wrap-log-request [handler]
  (fn [req]
    (println req)
    (handler req)))

(defn- wrap-kwjson-body [handler]
  (defn- kw-ify-json [v]
    "Turn a (json) map into a map where each key is a keyword."
    (if (map? v)
      (let [vs (map kw-ify-json (vals v))]
        (zipmap (map keyword (keys v)) vs))
      v))

  (fn [req]
    (let [kw-body (kw-ify-json (:body req))
          new-req (conj req [:kw-body (kw-ify-json (:body req))])]
      (println kw-body)
      (handler new-req))))

(defroutes app
  (-> app-routes
      wrap-log-request
      wrap-json-response
      wrap-kwjson-body
      wrap-json-body))
