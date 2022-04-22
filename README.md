# r-place-2022

dataset -> https://placedata.reddit.com/data/canvas-history/index.html

Setup:

### Requirements

* aws-cli

1. Aws configuration

```
export AWS_ACCESS_KEY_ID="<YOUR_AWS_ACCESS_KEY_ID>"
export AWS_SECRET_ACCESS_KEY="<YOUR_AWS_SECRET_ACCESS_KEY>"
export AWS_DEFAULT_REGION="<YOUR_AWS_DEFAULT_REGION>"
```

2. Terraform setup

```
cd terraform
terraform init
terraform apply -var="bucket_name=<UNIQUE_BUCKET_NAME>"
```

Optional variables

```
terraform apply -var="bucket_name=<UNIQUE_BUCKET_NAME>" -var="region=<BUCKET_REGION>
```



