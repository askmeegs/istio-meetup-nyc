#!/bin/bash

WORKDIR="/Users/mokeefe"
ISTIO_VERSION=1.3.0

helm template ${WORKDIR}/istio-${ISTIO_VERSION}/install/kubernetes/helm/istio --name istio --namespace istio-system \
--set prometheus.enabled=true \
--set tracing.enabled=true \
--set kiali.enabled=true --set kiali.createDemoSecret=true \
--set "kiali.dashboard.jaegerURL=http://jaeger-query:16686" \
--set "kiali.dashboard.grafanaURL=http://grafana:3000" \
--set grafana.enabled=true \
--set global.proxy.accessLogFile="/dev/stdout" \
--set mixer.telemetry.enabled=true \
--set sidecarInjectorWebhook.enabled=true > istio.yaml

kubectl apply -f istio.yaml

kubectl -n istio-system delete -f https://raw.githubusercontent.com/istio/proxy/master/extensions/stats/testdata/istio/metadata-exchange_filter.yaml
kubectl -n istio-system delete -f https://raw.githubusercontent.com/istio/proxy/master/extensions/stats/testdata/istio/stats_filter.yaml