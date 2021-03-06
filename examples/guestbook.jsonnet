// Simple self-contained example to demonstrate kubecfg.
// This should not necessarily be considered a model jsonnet example
// to build upon.

// This is a simple port to jsonnet of the standard guestbook example
// https://github.com/kubernetes/kubernetes/tree/master/examples/guestbook
//
// Expects to be run with ../lib in the jsonnet search path:
// ```
// export KUBECFG_JPATH=$PWD/../lib
// kubecfg update guestbook.jsonnet
// # poke at $(minikube service --url frontend), etc
// kubecfg delete guestbook.jsonnet
// ```

local example = import "example.libsonnet";

{
  frontend_deployment: example.deployment("frontend") {
    spec+: {
      replicas: 3,
      template+: {
        spec+: {
          containers: [
            example.container(
              "php-redis", "gcr.io/google-samples/gb-frontend:v4"
            ) {
              resources: {
                requests: { cpu: "100m", memory: "100Mi" },
              },
              env_: {
                GET_HOSTS_FROM: "dns",
              },
              ports: [{containerPort: 80}],
            }]}}}},

  frontend_service: example.service("frontend") {
    targetPod_: $.frontend_deployment.spec.template,
    spec+: { type: "LoadBalancer" },
  },

  redis_master_deployment: example.deployment("redis-master") {
    spec+: {
      template+: {
        spec+: {
          containers: [
            example.container(
              "master", "gcr.io/google_containers/redis:e2e"
            ) {
              resources: {
                requests: { cpu: "100m", memory: "100Mi" },
              },
              ports: [{containerPort: 6379}],
            }]}}}},

  redis_master_service: example.service("redis-master") {
    targetPod_: $.redis_master_deployment.spec.template,
  },

  redis_slave_deployment: example.deployment("redis-slave") {
    spec+: {
      replicas: 2,
      template+: {
        spec+: {
          containers: [
            example.container(
              "slave", "gcr.io/google_samples/gb-redisslave:v1"
            ) {
              resources: {
                requests: { cpu: "100m", memory: "100Mi" },
              },
              env_: {
                GET_HOSTS_FROM: "dns",
              },
              ports: [{containerPort: 6379}],
            }]}}}},

  redis_slave_service: example.service("redis-slave") {
    targetPod_: $.redis_slave_deployment.spec.template,
  },
}
