Any files placed in this folder will be applied to the cluster using `kubectl apply -f .`

This will be installed if you enable the following in the [values.yaml](../user/values.yaml)


```
# apply configuration files in kubernetes folder
kubernetes:
  # should the kubernetes application be installed
  enabled: true

  # URL to this git repo so it can find the kubernetes yaml files
  url: https://git.example.com/clusters/software.git

  # use a specific version to be checked out
  # version: HEAD

  # path of the kubernetes yaml files
  # path: kubernetes
```

