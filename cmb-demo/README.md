


# 部署 litmus

```
oc apply -f litmus-operator-v1.12.0.yaml
```

# 导入experiment 

```
oc apply -f experiments.yaml
```

# 创建SA 并添加权限 
```
oc apply -f rbac.yaml
```


# 手工 执行 pod-delete 试验 并 查看结果


# 通过API 调用 执行 pod-delete 并 查看结果

```
oc config view -o jsonpath='{"Cluster name\tServer\n"}{range .clusters[*]}{.name}{"\t"}{.cluster.server}{"\n"}{end}'

export CLUSTER_NAME="console-ocp3-ocp-zz:8443"


APISERVER=$(oc config view -o jsonpath="{.clusters[?(@.name==\"$CLUSTER_NAME\")].cluster.server}")

TOKEN=$(oc -n litmus get secret litmus-admin-token-mfmbm -o jsonpath='{.data.token}' | base64 -d)

curl -s -o /dev/null -k \
    -X POST \
    -d @- \
    -H "Authorization: Bearer $TOKEN" \
    -H 'Accept: application/json' \
    -H 'Content-Type: application/json' \
 $APISERVER/apis/litmuschaos.io/v1alpha1/namespaces/litmus/chaosengines/demo1 <<EOF
{
  "apiVersion": "litmuschaos.io/v1alpha1",
  "kind": "ChaosEngine",
  "metadata": {
    "name": "demo1",
    "namespace": "litmus"
  },
  "spec": {
    "appinfo": {
      "appns": "nginx",
      "applabel": "app=nginx",
      "appkind": "deployment"
    },
    "annotationCheck": "false",
    "engineState": "active",
    "chaosServiceAccount": "litmus-admin",
    "monitoring": false,
    "jobCleanUpPolicy": "delete",
    "experiments": [
      {
        "name": "pod-delete",
        "spec": {
          "components": {
            "env": [
              {
                "name": "TOTAL_CHAOS_DURATION",
                "value": "30"
              },
              {
                "name": "CHAOS_INTERVAL",
                "value": "10"
              },
              {
                "name": "FORCE",
                "value": "false"
              }
            ]
          }
        }
      }
    ]
  }
}
EOF


curl -s $APISERVER/apis/litmuschaos.io/v1alpha1/namespaces/litmus/chaosengines/nginx-chaos --header "Authorization: Bearer $TOKEN" --insecure
```

# 删除 chaosengines 

```
curl -s -o /dev/null -k \
    -X DELETE \
    -H "Authorization: Bearer $TOKEN" \
 $APISERVER/apis/litmuschaos.io/v1alpha1/namespaces/litmus/chaosengines/nginx-chaos | jq
```

# 获取chaoseresult信息

```
curl -s -k \
    -H "Authorization: Bearer $TOKEN" \
 $APISERVER/apis/litmuschaos.io/v1alpha1/namespaces/litmus/chaosresults/nginx-chaos-pod-delete | jq
```

# 解除rolebinding 并删除SA




