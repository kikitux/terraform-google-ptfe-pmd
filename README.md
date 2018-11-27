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

## Disk layout

TODO: this

```
root@ptfe-pmd:~# df -Ph
Filesystem      Size  Used Avail Use% Mounted on
..
/dev/sdb        197G   60M  187G   1% /var/lib/replicated/snapshots
/dev/sdc        197G   60M  187G   1% /media/mount
root@ptfe-pmd:~#
```

## Performance

TODO: this
```
root@ptfe-pmd:~# hdparm -t /dev/sda /dev/sdb /dev/sdc /dev/nvme0n1

/dev/sda:
 Timing buffered disk reads: 736 MB in  3.01 seconds = 244.80 MB/sec

/dev/sdb:
 Timing buffered disk reads: 742 MB in  3.01 seconds = 246.74 MB/sec

/dev/sdc:
 Timing buffered disk reads: 742 MB in  3.01 seconds = 246.72 MB/sec

/dev/nvme0n1:
 Timing buffered disk reads: 2114 MB in  3.00 seconds = 704.39 MB/sec
root@ptfe-pmd:~#
```

alvaro@kikitux.net


