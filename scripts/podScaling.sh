cat << EOF
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: ${1}
  namespace: ${2}
  labels:
    deploymentName: bff
spec:
  cooldownPeriod: 120
  minReplicaCount: ${3}
  maxReplicaCount: ${4}
  scaleTargetRef:
    name: bff
  triggers:
    - type: prometheus
      metadata:
        serverAddress: http://prometheus-service.monitoring.svc.cluster.local:8080
        metricName: system_load_average_1m
        threshold: '1'
        query: sum(system_load_average_1m{app='bff',kubernetes_namespace='prod'})
    - type: cpu
      metadata:
        type: Utilization
        value: '70'

EOF