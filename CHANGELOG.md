# Changelog

All notable changes to the Ansible MySQL Backup project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.0] - 2025-05-25

### Added
- Added configurable rolling backups with retention period
- Added `retention_days` parameter to host configuration (defaults to 7 days)
- Added support for local host connections using `ansible_connection=local`
- Added improved error handling with fallback notification methods
- Added support for passwordless MySQL connections
- Added `add_host.sh` script to simplify adding new hosts
- Added this CHANGELOG.md file

### Changed
- Improved timestamp format to use YYYY-MM-DD_HHMM format for easier sorting
- Modified backup process to optimize for local database servers
- Enhanced documentation with clearer instructions for local hosts
- Updated README.md to clarify configuration parameters

### Fixed
- Fixed handling of blank MySQL passwords
- Fixed SSH connectivity checks for local hosts
- Fixed notification system to work even when terminal-notifier is not available

## [1.0.0] - Initial Release

### Added
- Basic MySQL backup functionality
- Support for multiple hosts and databases
- Synchronization of backups to local machine
- Simple timestamp-based naming
