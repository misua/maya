
# Project Maya

This is a repo of the ff Missions:

- Mission1 folder - all tf infrastructure

`tested to deploy all needed infrastructure`


- Mission2 folder - Kubernetes resource in 1 unified.yaml file

`tested to create all resource in local Kubernetes lab`


- Mission 3 - Published code in GH (https://github.com/misua/maya)


- Mission 4 - not completely done and tested as it was tagged as `(optional)`


### Build and Tag the Docker image
``docker build -t localhost/simple-webapp:latest .``

`docker tag simple-webapp:latest <aws_account_id>.dkr.ecr.<region>.amazonaws.com/simple-webapp:latest`

### Push the Docker image to ECR
`docker push <aws_account_id>.dkr.ecr.<region>.amazonaws.com/simple-webapp:latest`

---

## Authors

- [@misua](https://www.github.com/misua)



`Badges`


[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://choosealicense.com/licenses/mit/)
[![GPLv3 License](https://img.shields.io/badge/License-GPL%20v3-yellow.svg)](https://opensource.org/licenses/)
[![AGPL License](https://img.shields.io/badge/license-AGPL-blue.svg)](http://www.gnu.org/licenses/agpl-3.0)

![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![Static Badge](https://img.shields.io/badge/Charles-Pogi-blue)
## Installation


