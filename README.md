## Repo Details
* **Author** - Jamie McKay

## Repo Structure
There are multiple folders in this repo. Each has a **different** version of the code to build the infrastructure in **different ways**. You can just build plain servers or more complete environments. Building servers alone will not include ASGs or Load Balancers for example and should only be used for basic testing. If you are using the same account to run these scripts, it **WILL DESTROY** your infrastructure if you choose to build from a different folder.

## Overall Goals
* Learn Terraform
* Build some web servers and understand the different methods to do so.
* Understand how to create ASGs, LBs and Launch Configurations to create something closer to an Enterprise solution. 
* mySQL DB using RDS.
