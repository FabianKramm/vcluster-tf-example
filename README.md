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
kubectl create secret generic aws-credentials -n vcluster-platform \
  --from-literal=AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
  --from-literal=AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
  --from-literal=AWS_SESSION_TOKEN="$AWS_SESSION_TOKEN"
```

Label the aws secret
```
kubectl label secret aws-credentials -n vcluster-platform "terraform.vcluster.com/provider=aws-example" --overwrite
```

## Create the vCluster

```
vcluster platform create vcluster my-vcluster --values https://raw.githubusercontent.com/FabianKramm/vcluster-tf-example/refs/heads/main/vcluster.yaml --chart-version 0.28.0-next.7
```
