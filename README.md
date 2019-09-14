# Istio 1.3 Tour

This talk explores new features for [Istio 1.3](https://istio.io/about/notes/1.3/), and "hidden" Istio features you might not know about.

- [Istio 1.3 Tour](#istio-13-tour)
  - [Install Istio 1.3 on GKE](#install-istio-13-on-gke)
  - [What's running in the mesh?](#whats-running-in-the-mesh)
  - [Service Health + Metrics](#service-health--metrics)
  - [(new!) Port Protocol Detection](#new-port-protocol-detection)
  - [(new!) Inspect Istio config for a pod](#new-inspect-istio-config-for-a-pod)
  - [(new!) Pilot Dashboard Improvements](#new-pilot-dashboard-improvements)
  - [Add Response Headers](#add-response-headers)
  - [(new!) Envoy-native telemetry - experimental](#new-envoy-native-telemetry---experimental)

## Install Istio 1.3 on GKE

Installs Istio 1.3 on a GKE cluster, along with a sample application accessible through the IngressGateway.

```
./install-istio.sh
```

## What's running in the mesh?

```
istioctl dashboard kiali
```

## Service Health + Metrics

![](images/svc-metrics.png)

![](images/connections.png)


## (new!) Port Protocol Detection

Istio 1.3 adds support for detecting port protocols for HTTP and HTTP2 traffic (without having to name the port `http`).
(still have to name grpc ports.)

(Show frontend service YAML, then Kiali protocol - HTTP)

## (new!) Inspect Istio config for a pod

```
$ istioctl experimental describe pod paymentservice-65bcb767c6-lmtnk

Pod: paymentservice-65bcb767c6-lmtnk
   Pod Ports: 50051 (server), 15090 (istio-proxy)
Suggestion: add 'version' label to pod for Istio telemetry.
--------------------
Service: paymentservice
   Port: grpc 50051/GRPC
Pilot reports that pod is PERMISSIVE (enforces HTTP/mTLS) and clients speak HTTP
```

## (new!) Pilot Dashboard Improvements

```
istioctl dashboard grafana
```

![](images/pilot.png)


## [Add Response Headers](https://istio.io/docs/reference/config/networking/v1alpha3/virtual-service/#Headers)

Use case -- you're using a CDN and you want to tell the CDN *not* to cache certain requests. The CDN uses a "Cache:False" header to do this. We can use Istio to add that header for all requests to the frontend:

```
kubectl apply -f add-header.yaml
```

Then:

```
$ curl -I 34.73.15.141

HTTP/1.1 200 OK
set-cookie: shop_session-id=ce6a520d-58cb-4b14-ade3-8a2695e1bd01; Max-Age=172800
date: Sat, 14 Sep 2019 19:18:46 GMT
content-type: text/html; charset=utf-8
x-envoy-upstream-service-time: 53
cache: false
hello: newyork
server: istio-envoy
transfer-encoding: chunked
```

## (new!) [Envoy-native telemetry](https://istio.io/docs/ops/telemetry/in-proxy-service-telemetry/) - experimental

Use case -- you aren't getting ideal performance results (added latency) when using Istio's mixer for telemetry. (ie. Envoy forwards metrics up to the control plane, then on to Prometheus.)

Now you can use Envoy to generate metrics on throughput, request duration, and request size.
(In the future, Envoy-native telemetry should have parity with Mixer / report latency, error rate.)

Disable Mixer telemetry / enable custom Envoy filters:

```
./disable-mixer.yaml
```

Delete the istio telemetry deployment.

Return to grafana dashboard for a service -- see metrics flowing in directly from Envoy. 🎊

![](./images/nomixer.png)

To re-enable Mixer telemetry:

```
./enable-mixer.yaml
```