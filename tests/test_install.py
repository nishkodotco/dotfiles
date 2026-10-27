import importlib.util
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]

class InstallerTest(unittest.TestCase):
    def run_install(self, home, platform, *extra):
        env = dict(os.environ)
        env.pop('CODESPACES', None)
        env.pop('XDG_CONFIG_HOME', None)
        return subprocess.run([sys.executable, str(ROOT / 'scripts/install.py'),
            '--home', str(home), '--platform', platform, *extra],
            env=env, text=True, capture_output=True)

    def test_platform_install_is_idempotent_and_preserves_original(self):
        for platform, config in [('Darwin', 'Library/Application Support/nushell'), ('Linux', '.config/nushell')]:
            with self.subTest(platform=platform), tempfile.TemporaryDirectory() as directory:
                home = Path(directory)
                original = home / config / 'config.nu'
                original.parent.mkdir(parents=True)
                original.write_text('# previous configuration')
                result = self.run_install(home, platform)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertTrue(original.is_symlink())
                self.assertEqual(original.resolve(), ROOT / '.config/nushell/config.nu')
                backups = list((home / '.local/state/dotfiles/backups').rglob('config.nu'))
                self.assertEqual(len(backups), 1)
                self.assertEqual(backups[0].read_text(), '# previous configuration')
                self.assertEqual(self.run_install(home, platform).returncode, 0)
                self.assertEqual(len(list((home / '.local/state/dotfiles/backups').rglob('config.nu'))), 1)
                self.assertEqual(self.run_install(home, platform, '--check').returncode, 0)

    def test_check_detects_drift_without_overwriting_it(self):
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            self.assertEqual(self.run_install(home, 'Linux').returncode, 0)
            target = home / '.config/nushell/config.nu'
            target.unlink()
            target.write_text('# unmanaged edit')
            self.assertEqual(self.run_install(home, 'Linux', '--check').returncode, 1)
            self.assertEqual(target.read_text(), '# unmanaged edit')

if __name__ == '__main__':
    unittest.main()
