"""Run the actual service tasks against stub binaries; no database is accessed."""
import json
from pathlib import Path
import subprocess
import tempfile
import unittest


class LocalMySQLTests(unittest.TestCase):
    def run_service_tasks(self, *, local=True, enabled=None, running=False):
        source = (Path(__file__).resolve().parents[1] / 'playbook.yaml').read_text()
        tasks = source.split('        - name: start local MySQL when stopped', 1)[1]
        tasks = '        - name: start local MySQL when stopped' + tasks.split('        # Local database dump', 1)[0]
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            state, calls = root / 'running', root / 'calls'
            if running:
                state.touch()
            admin, server = root / 'mysqladmin', root / 'mysql.server'
            admin.write_text(f'#!/bin/sh\ntest -f "{state}"\n')
            server.write_text(f'#!/bin/sh\necho start >> "{calls}"\ntouch "{state}"\n')
            for binary in (admin, server):
                binary.chmod(0o755)
            variables = dict(is_local_host=local, user='test', mysqladmin_binary=str(admin), mysql_server_binary=str(server))
            if enabled is not None:
                variables['start_local_mysql'] = enabled
            play = root / 'test.yaml'
            play.write_text('- hosts: localhost\n  gather_facts: false\n  vars: ' + json.dumps(variables) + '\n  tasks:\n' + tasks)
            result = subprocess.run(['ansible-playbook', '-i', 'localhost,', '-c', 'local', str(play)], cwd=root, capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            return calls.read_text() if calls.exists() else '', state.exists()

    def test_disabled_by_default(self):
        self.assertEqual(self.run_service_tasks(), ('', False))

    def test_explicitly_disabled(self):
        self.assertEqual(self.run_service_tasks(enabled=False), ('', False))

    def test_remote_host_skips_startup(self):
        self.assertEqual(self.run_service_tasks(local=False, enabled=True), ('', False))

    def test_stopped_service_starts(self):
        self.assertEqual(self.run_service_tasks(enabled=True), ('start\n', True))

    def test_running_service_is_not_restarted(self):
        self.assertEqual(self.run_service_tasks(enabled=True, running=True), ('', True))


if __name__ == '__main__':
    unittest.main()
