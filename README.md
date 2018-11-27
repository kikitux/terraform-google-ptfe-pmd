# terraform-google-ptfe-pmd

Terraform module to deploy one intance to host PTFE in mounted disk.

## How to use

Please check the [example/](example/) folder.

## How to deploy tfe

```
terraform init
terraform plan
terraform apply
```

Check output

Connect to the instance

```
ssh hostname
```

Become root
```
sudo su -
```

In `/root` will be 2 helper files:
```
certbot.sh
ptfe.sh
```

`certbot.sh` is a script that download certbot / let's encrypt bot.

Follow the instructions, and you will end with 2 certificates.

`ptfe.sh` is a scrip that will install private terraform

## Configuring PTFE.

- Configure as prod instance
- Choose external mounted disk
- Use `/media/mount` for external mounted disk


## Sample output

```
compute_instance_address = fqdn
compute_instance_ip = nn.nn.nn.nn
stackdriver_compute = https://app.google.stackdriver.com/instances/id?project=project
```

alvaro@kikitux.net


