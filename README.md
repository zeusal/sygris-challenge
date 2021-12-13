# Sygris
This folder contains a set of Terraform code. 

To try any example, clone this repository, set the following parameters into input.tfvars:

- management_access_key  = ""
- management_secret_key  = ""
- operational_access_key = ""
- operational_secret_key = ""
- priv_key = ""
- pub_key = ""
- hosted_zone_cert = ""
- hosted_zone_key = ""

Or run the following commands for generate input.tfvars file:

```shell
$ ./setup.sh filename-for-key operational-access-key operational-secret-key management-access-key management-secret-key
```

And run the following command from within the example's directory:

```shell
$ terraform apply -var-file="input.tfvars"
```


