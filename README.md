
# Project Maya

This is a repo of the following Maya Missions:

- Mission1 folder - all tf infrastructure

`fully tested to deploy in aws`

`my-key-pair.pem included,it has no use to anyone`



- Mission2 folder - Kubernetes resource in 1 unified.yaml file

`tested to create all resource in local Kubernetes lab`


- Mission 3 - Published code in GH (https://github.com/misua/maya)


- Mission 4 - not completely done and tested as it was tagged as `(optional)`


### Build and Tag the Docker image
```bash 
docker build -t localhost/simple-webapp:latest .
```

```bash 
docker tag simple-webapp:latest <aws_account_id>.dkr.ecr.<region>.amazonaws.com/simple-webapp:latest
```

### Push the Docker image to ECR
```bash
docker push <aws_account_id>.dkr.ecr.<region>.amazonaws.com/simple-webapp:latest
```

---

TODO:
 - load balancer still lacking permissions to write to created s3 bucket for storing load balancer access logs.( trying to find out why)


<img src="https://github.com/misua/maya/aws.png?raw=true">
<img src="https://github.com/misua/maya/s.png?raw=true">

## Authors

- [@misua](https://www.github.com/misua)



`Badges`


[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://choosealicense.com/licenses/mit/)
[![GPLv3 License](https://img.shields.io/badge/License-GPL%20v3-yellow.svg)](https://opensource.org/licenses/)
[![AGPL License](https://img.shields.io/badge/license-AGPL-blue.svg)](http://www.gnu.org/licenses/agpl-3.0)

![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![Static Badge](https://img.shields.io/badge/Charles-Pogi-blue)



