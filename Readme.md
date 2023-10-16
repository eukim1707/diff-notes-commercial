# Diff notes for codefactory-gc-workstation3

## code:
- git clone https://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@github.com/Deloitte/AICOE-Platform-Infrastructure.git -b dev

## diff notes:
- changes in AWS-Commercial-New instance that deployed successfully were compared with original dev branch code
- *note - comparison was done using this VSCode extension in order to enable comparing folders: https://marketplace.visualstudio.com/items?itemName=moshfeu.compare-folders&ssr=false#qna
![](readme1.png)

## instructions:
- please go to AWS-Commercial-New, highlight the two folders (**AICOE-Platform-Infrastructure-old** and **aicoe-tap-infrastructure**), right-click, and select "[Compare folders]..." 
  - *Note: or you can compare the two folders present in this repository

## changes tracked in this repo:
1. DIFFERENCES:
   1. **ansible/**
      1. **files/**
         1. **argocd-server-vs.yaml** and **grafana-vs.yaml**
            1. changed apiVersion from v1beta1 to v1alpha3
            2. gateway changed from kubeflow/kubeflow-gateway to istio-system/istio-ingressgateway
         2. **grafana-vs.yaml**
            1. host changed to prometheus-grafana.grafana.svc.cluster.local
      2. **group_vars/**
         1. removed line 26 (platform_metadata_bucket_name)
         2. removed rest of file starting from line 39
      3. **templates/**
         1. **argocd_token.yaml**
            1. repository names adjusted
         2. **cluster-autoscaler-autodiscovery.yaml**
            1. registry image version changed from v1.26.4 to v1.22.2
      4. **alb_controller.yaml**
         1. aws command on line 24 changed from "role/internal-elb..." to "role/elb..."
      5. **argocd.yaml**
         1. ansible jobs removed, including minio ones, moved around, or adjusted (see file)
      6. **autoscaler.yaml**
         1. "wait for cluster to be available" ansible job added
      7. **bastion_eks_config.yaml**
         1. "jq" removed from "Install yum utils"
         2. "openshift" removed from "install python dependencies"
         3. "get kustomize and install" ansible job adjusted (see file)
      8. **cleanup.yaml**
         1. **remove_ingress.yaml** playbook added (to delete ALB and destroy route53 records)
      9. **cluster_terraform.yaml**
         1.  outputs moved from separate file and put into file directly
     1.  **destroy_iam_s3.yaml**
         1.  some rearranging and "force: yes" added to "delete existing S3 bucket"
     2.  **minio.yaml**
         1.  some jobs from argocd.yaml seemed to be moved here
         2.  other various changes (see file)
     3.  **profile_onboarding.yaml**
         1.  bucket name on line 6 removed
         2.  other various changes (see file)

## helpful CL commands:
#### Workstation
- ```ansible-playbook init.yaml --extra-vars include_iam_s3=false  --skip-tags kubeconfig,helm,cni,eni,alb,autoscaler```
#### Bastion
- ArgoCD admin password
  - ```kubectl -n argocd get secret argocd-initial-admin-secret  -o jsonpath="{.data.password}" | base64 -d```

## contacts
1. DCS Global
   - Ahammed, Shaik Ejaz <sahammed@deloitte.com>
   - Padmaja, Nistala <npadmaja@deloitte.com>
2. Technical Account Managers for AWS
   - AWS TAM for Deloitte at <aws-tam-deloitte@amazon.com>
     - Robenalt, John <jrobenal@amazon.com> - Sales
     - Govindankutty, Sunil <govisun@amazon.com> - Prod Support
     - Manoj Rajan <mrmanoj@amazon.com> - Prod Support
     - Paolo Barone <paobar@amazon.com>
