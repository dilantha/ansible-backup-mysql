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
pass: database password  # Leave empty if no password is required
retention_days: 7  # Number of days to keep backups
is_local: false    # Set to true for local databases
databases:
  - db1
  - db2
```

`backup_root` is the backup root folder for backups. A subfolder will be created for each host you add like this.

```
├── host1
├── host2
```

`user` is your MySQL username for taking the backup.

`pass` is your MySQL password for taking the backup. If left empty or set to an empty string (`""`), no password will be used. This is useful for MySQL configurations that use socket authentication or other passwordless methods. Set to your password when authentication is required.

`databases` is a list of databases you want to dump.

`retention_days` is the number of days to keep backups before they are automatically removed. If not specified, defaults to 7 days.

`is_local` should be set to true if the MySQL server is running on your local machine. This parameter is retained for backward compatibility, but the recommended approach is to use `ansible_connection=local` in the hosts file.

### Local Hosts Configuration

For hosts that represent your local machine, add them to the `hosts` file with the `ansible_connection=local` parameter:

```
localhost ansible_connection=local
mylocalmachine ansible_connection=local
```

This tells Ansible to use a local connection instead of trying to connect via SSH. This is the preferred way to handle local hosts.

## Running the script

Run the script with a local `hosts` file like below or with your own Ansible inventory configuration.
```
ansible-playbook -i hosts playbook.yaml
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