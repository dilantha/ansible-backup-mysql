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

# Binary paths (optional) - customize these based on your system
# mysqldump_binary: /opt/homebrew/bin/mysqldump  # Default for Homebrew on macOS
# gzip_binary: gzip                              # Default system gzip  
# cp_binary: cp                                  # Default system cp

databases:
  - db1
  - db2
```

## Configuration Variables

### Required Variables
- `backup_root`: The backup root folder for backups. A subfolder will be created for each host.
- `user`: Your MySQL username for taking the backup.
- `databases`: A list of databases you want to dump.

### Optional Variables
- `pass`: Your MySQL password for taking the backup. If left empty or set to an empty string (`""`), no password will be used. This is useful for MySQL configurations that use socket authentication or other passwordless methods.
- `retention_days`: The number of days to keep backups before they are automatically removed. Defaults to 7 days if not specified.
- `is_local`: Should be set to true if the MySQL server is running on your local machine. This parameter is retained for backward compatibility, but the recommended approach is to use `ansible_connection=local` in the hosts file.

### Binary Path Variables
You can customize the paths to system binaries by setting these variables in your host_vars or group_vars:

- `mysqldump_binary`: Path to the mysqldump command. Defaults to `/opt/homebrew/bin/mysqldump` (Homebrew on macOS).
- `gzip_binary`: Path to the gzip command. Defaults to `gzip`.
- `cp_binary`: Path to the cp command. Defaults to `cp`.

#### Examples for Different Systems:

**macOS with Homebrew:**
```yaml
mysqldump_binary: /opt/homebrew/bin/mysqldump
gzip_binary: /opt/homebrew/bin/gzip
cp_binary: /bin/cp
```

**Linux (Ubuntu/Debian/CentOS):**
```yaml
mysqldump_binary: /usr/bin/mysqldump
gzip_binary: /bin/gzip
cp_binary: /bin/cp
```

**Custom MySQL Installation:**
```yaml
mysqldump_binary: /usr/local/mysql/bin/mysqldump
```

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

## Setting Up Scheduled Backups

You can set up a cronjob to run the playbook automatically on a schedule. This ensures your MySQL databases are backed up regularly without manual intervention.

### Example: Daily Backup at 12 PM

To schedule the playbook to run every day at 12 PM (noon), add the following to your crontab:

1. Open your crontab for editing:
```
crontab -e
```

2. Add the following line (adjust the path to match your actual playbook location):
```
0 12 * * * cd /path/to/ansible-backup-mysql && ansible-playbook -i hosts playbook.yaml >> /path/to/ansible-backup-mysql/backup.log 2>&1
```

This will:
- Run the playbook every day at 12:00 PM
- Change to the playbook directory before execution
- Log both standard output and errors to a backup.log file

### Crontab Reference

For more information about crontab format and options, refer to the [Crontab Quick Reference](https://crontab.guru/) or the [Crontab Manual](https://man7.org/linux/man-pages/man5/crontab.5.html).

You can adjust the schedule as needed. For example, to run at 3 AM every Monday, you would use:
```
0 3 * * 1 cd /path/to/ansible-backup-mysql && ansible-playbook -i hosts playbook.yaml >> /path/to/ansible-backup-mysql/backup.log 2>&1
```