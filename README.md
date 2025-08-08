# vCluster Terraform AWS Example
Example TF Script to use with vCluster Platform to provision EC2 nodes

## Login to the platform

```
vcluster login XXX.loft.host
```

## Apply the terraform provider

```
kubectl apply -f https://raw.githubusercontent.com/FabianKramm/vcluster-tf-example/refs/heads/main/provider.yaml
```

## Create a secret with AWS credentials

Make sure AWS credentials are part of your environment
```
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...
AWS_SESSION_TOKEN=...
```

Create the aws secret
```
kubectl create secret generic aws-credentials \
  --from-literal=AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
  --from-literal=AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
  --from-literal=AWS_SESSION_TOKEN="$AWS_SESSION_TOKEN"
```

Label the aws secret
```
kubectl label secret aws-credentials "terraform.vcluster.com/provider=aws-example" --overwrite
```

## Create the vCluster

Create `vcluster.yaml`:
```
privateNodes:
  enabled: true
  tunnel:
    enabled: true
    nodeToNode:
      enabled: true
  nodePools:
    dynamic:
    - name: aws
      requirements:
      - property: vcluster.com/node-provider
        value: aws-example
      - property: region
        value: eu-west-1

controlPlane:
  distro:
    k8s:
      version: v1.32.7
```

Create:
```
vcluster platform create vcluster my-vcluster -n my-vcluster --values vcluster.yaml --chart-version 0.28.0-next.9
```
