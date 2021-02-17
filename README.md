# Ansible Backup MySQL

Backup multiple MySQL databases over multiple hosts with Ansible.

## Requirements

You will need [Ansible installed](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) and shell access to your servers.

## Setup

Next setup an [Ansible inventory file](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html). Personally I use a simple `hosts` file in a project like this.

```
host1
host2
```

Each server needs a set of host variables. Setup your host variables in a `host_vars` folder like this `host_vars/host1.yaml`, `host_vars/host2.yaml`.

Here is a sample configuration file. Make sure you don’t push these files up to git since they have sensitive data.

```yaml
backup_root: ~/Backup/Databases
user: database user
pass: database password
databases:
  - db1
  - db2
```

`backup_root` is the backup root folder for backups. A subfolder will be created for each host you add like this.

```
├── host1
├── host2
```

`dump_pass` is your MySQL password for taking the backup. Its probably a good idea to create a separate backup user that has read and lock table access to your databases on each server.

`databases` is a list of databases you want to dump.

## Running the script

Run the script with a local `hosts` file like below or with your own Ansible inventory configuration.
```
ansible-playbook -i hosts backup_databases.yaml
```

This will dump each database to an sql file on the server and sync them back to your machine.
```
host1
├── db1.sql
├── db2.sql
host2
├── db3.sql
├── db4.sql
```