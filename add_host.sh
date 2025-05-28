#!/bin/bash

# Script to add a new host to MySQL backup configuration
# It will add the host to the hosts file and create a corresponding host_vars file

echo "MySQL Backup Host Configuration Script"
echo "======================================"

# Check if host_vars directory exists, create if not
if [ ! -d "host_vars" ]; then
  mkdir -p host_vars
  echo "Created host_vars directory"
fi

# Get the hostname
echo -n "Enter hostname: "
read hostname

if [ -z "$hostname" ]; then
  echo "Error: Hostname cannot be empty"
  exit 1
fi

# Check if host already exists in hosts file
if [ -f "hosts" ] && grep -q "^$hostname$" hosts; then
  echo "Warning: Host $hostname already exists in hosts file"
  read -q "REPLY?Do you want to update its configuration anyway? (y/n) "
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation cancelled"
    exit 0
  fi
fi

# Get backup configuration
echo -n "Enter backup root directory (default: ~/Backup/Databases): "
read backup_root
backup_root=${backup_root:-"~/Backup/Databases"}

echo -n "Enter MySQL username: "
read mysql_user

echo -n "Enter MySQL password (leave blank if no password is required): "
read -s mysql_pass
echo ""
# Explicitly set to an empty string if blank
if [ -z "$mysql_pass" ]; then
  mysql_pass='""'
fi

echo -n "Enter backup retention period in days (default: 7): "
read retention_days
retention_days=${retention_days:-7}

echo -n "Is this a local host? (y/n) (default: n): "
read is_local
is_local=${is_local:-n}
if [[ $is_local =~ ^[Yy]$ ]]; then
  is_local_value="true"
else
  is_local_value="false"
fi

# Get databases
echo "Enter database names (one per line, empty line to finish):"
databases=()
while true; do
  echo -n "> "
  read db_name
  if [ -z "$db_name" ]; then
    break
  fi
  databases+=("$db_name")
done

if [ ${#databases[@]} -eq 0 ]; then
  echo "Warning: No databases specified"
  read -q "REPLY?Continue anyway? (y/n) "
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation cancelled"
    exit 0
  fi
fi

# Add to hosts file if doesn't exist
if ! grep -q "^$hostname" hosts 2>/dev/null; then
  if [[ $is_local =~ ^[Yy]$ ]]; then
    echo "$hostname ansible_connection=local" >> hosts
    echo "Added $hostname as a local connection to hosts file"
  else
    echo "$hostname" >> hosts
    echo "Added $hostname to hosts file"
  fi
else
  if [[ $is_local =~ ^[Yy]$ ]] && ! grep -q "^$hostname ansible_connection=local" hosts 2>/dev/null; then
    sed -i '' "s/^$hostname$/$hostname ansible_connection=local/" hosts
    echo "Updated $hostname in hosts file to use local connection"
  elif [[ ! $is_local =~ ^[Yy]$ ]] && grep -q "^$hostname ansible_connection=local" hosts 2>/dev/null; then
    sed -i '' "s/^$hostname ansible_connection=local/$hostname/" hosts
    echo "Updated $hostname in hosts file to use default connection"
  else
    echo "Host $hostname already exists in hosts file with correct connection type"
  fi
fi

# Create host_vars file
cat > "host_vars/$hostname.yaml" << EOF
backup_root: $backup_root
user: $mysql_user
pass: $mysql_pass
retention_days: $retention_days
is_local: $is_local_value
databases:
EOF

# Add databases to the host_vars file
for db in "${databases[@]}"; do
  echo "  - $db" >> "host_vars/$hostname.yaml"
done

echo "Created configuration file: host_vars/$hostname.yaml"
echo "Host $hostname has been successfully configured"
echo ""
echo "IMPORTANT: Make sure not to commit your host_vars directory to version control"
echo "as it contains sensitive database credentials."
echo ""
echo "To run the backup, use: ./backup_databases.sh"
