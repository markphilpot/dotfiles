import importlib.machinery
import importlib.util
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parent.parent / "bin" / "brew-sync"
loader = importlib.machinery.SourceFileLoader("brew_sync", str(SCRIPT))
spec = importlib.util.spec_from_loader("brew_sync", loader)
brew_sync = importlib.util.module_from_spec(spec)
loader.exec_module(brew_sync)

CASKS = [
    {"token": "audio-hijack", "auto_updates": True,
     "artifacts": [{"app": ["Audio Hijack.app"], "target": "/Applications/Audio Hijack.app"}]},
    {"token": "helium", "artifacts": [{"app": ["Helium.app"]}]},
    {"token": "helium-browser", "artifacts": [{"app": ["Helium.app"]}]},
    {"token": "firefox", "artifacts": [{"app": ["Firefox.app"]}]},
    {"token": "firefox@beta", "artifacts": [{"app": ["Firefox.app"]}]},
    {"token": "appflowy",
     "artifacts": [{"app": ["AppFlowy-arm64.app", {"target": "AppFlowy.app"}]}]},
    {"token": "zoom", "artifacts": [{"pkg": ["zoomusInstallerFull.pkg"]}]},
    {"token": "wezterm", "artifacts": [{"app": ["WezTerm.app"]}]},
    {"token": "obsidian", "artifacts": [{"app": ["Obsidian.app"]}]},
    {"token": "freeze", "artifacts": [{"app": ["Freeze.app"]}]},
]


class Fixture(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        root = Path(self.tmp.name)
        self.apps = root / "Applications"
        self.brew = root / "brew"
        self.brew.mkdir()
        self.store_ids = {}
        (self.brew / "core.rb").write_text('brew "fish"\ncask "wezterm"\ncask "obsidian"\n')

    def make_app(self, name, app_store=False, store_id=None):
        contents = self.apps / name / "Contents"
        contents.mkdir(parents=True)
        if app_store:
            (contents / "_MASReceipt").mkdir()
            self.store_ids[name] = store_id

    def classify(self, installed_casks=(), installed_formulae=()):
        return brew_sync.classify(
            brew_sync.scan_apps([str(self.apps)], store_id=lambda app: self.store_ids[app.name]),
            brew_sync.build_index(CASKS),
            brew_sync.read_profiles(self.brew),
            brew_sync.read_ignored(self.brew),
            set(installed_casks),
            set(installed_formulae),
        )


class IndexTest(unittest.TestCase):
    def test_uses_the_renamed_app_name(self):
        index = brew_sync.build_index(CASKS)
        self.assertEqual(index["AppFlowy.app"], ["appflowy"])
        self.assertNotIn("AppFlowy-arm64.app", index)

    def test_installer_casks_have_no_app_name(self):
        self.assertEqual(brew_sync.app_names(CASKS[6]), [])


class ClassifyTest(Fixture):
    def test_hand_installed_app_with_one_cask(self):
        self.make_app("Audio Hijack.app")
        self.assertEqual(self.classify()["unrecorded"], [("Audio Hijack.app", ["audio-hijack"])])

    def test_ambiguous_app_lists_every_cask(self):
        self.make_app("Helium.app")
        self.assertEqual(self.classify()["unrecorded"], [("Helium.app", ["helium", "helium-browser"])])

    def test_beta_variants_are_dropped_when_a_stable_cask_exists(self):
        self.make_app("Firefox.app")
        self.assertEqual(self.classify()["unrecorded"], [("Firefox.app", ["firefox"])])

    def test_installed_variant_wins(self):
        self.make_app("Firefox.app")
        report = self.classify(installed_casks=["firefox@beta"])
        self.assertEqual(report["unrecorded"], [("Firefox.app", ["firefox@beta"])])
        self.assertEqual(report["casks"], [])

    def test_app_store_app_is_reported_separately(self):
        self.make_app("Freeze.app", app_store=True, store_id="1046095491")
        report = self.classify()
        self.assertEqual(report["app_store"], [("Freeze.app", "1046095491")])
        self.assertEqual(report["unrecorded"], [])

    def test_app_store_app_recorded_by_id_is_not_reported(self):
        self.make_app("Bear.app", app_store=True, store_id="1091189122")
        (self.brew / "mas.rb").write_text('mas "Bear Notes", id: 1091189122\n')
        self.assertFalse(any(self.classify().values()))

    def test_app_store_app_without_an_id_is_still_reported(self):
        self.make_app("Bear.app", app_store=True, store_id=None)
        (self.brew / "mas.rb").write_text('mas "Bear", id: 1091189122\n')
        self.assertEqual(self.classify()["app_store"], [("Bear.app", None)])

    def test_app_without_a_cask_is_unmatched(self):
        self.make_app("zoom.us.app")
        self.assertEqual(self.classify()["unmatched"], ["zoom.us.app"])

    def test_recorded_and_managed_app_is_not_reported(self):
        self.make_app("WezTerm.app")
        report = self.classify(installed_casks=["wezterm"])
        self.assertFalse(any(report.values()))

    def test_recorded_but_hand_installed_app_needs_adopting(self):
        self.make_app("Obsidian.app")
        self.assertEqual(self.classify()["needs_adopt"], [("Obsidian.app", "obsidian")])

    def test_ignored_by_app_name_or_cask(self):
        self.make_app("Audio Hijack.app")
        self.make_app("zoom.us.app")
        (self.brew / "ignore.txt").write_text("# comment\naudio-hijack\nzoom.us.app  # trailing\n")
        report = self.classify(installed_formulae=["pyenv"])
        self.assertEqual(report["unrecorded"], [])
        self.assertEqual(report["unmatched"], [])
        self.assertEqual(report["formulae"], ["pyenv"])

    def test_unrecorded_brew_packages(self):
        report = self.classify(installed_casks=["wezterm", "ghostty"],
                               installed_formulae=["fish", "ripgrep"])
        self.assertEqual(report["casks"], ["ghostty"])
        self.assertEqual(report["formulae"], ["ripgrep"])


class WriteTest(Fixture):
    def test_add_appends_once(self):
        self.assertTrue(brew_sync.add_entry(self.brew, "core", "cask", "audio-hijack"))
        self.assertFalse(brew_sync.add_entry(self.brew, "core", "cask", "audio-hijack"))
        text = (self.brew / "core.rb").read_text()
        self.assertEqual(text.count('cask "audio-hijack"'), 1)
        self.assertTrue(text.endswith('cask "audio-hijack"\n'))

    def test_add_refuses_a_cask_recorded_in_another_profile(self):
        self.assertFalse(brew_sync.add_entry(self.brew, "audio", "cask", "obsidian"))
        self.assertFalse((self.brew / "audio.rb").exists())

    def test_add_creates_a_new_profile(self):
        self.assertTrue(brew_sync.add_entry(self.brew, "audio", "cask", "audio-hijack"))
        self.assertIn('cask "audio-hijack"\n', (self.brew / "audio.rb").read_text())
        self.assertIn("audio-hijack", brew_sync.read_profiles(self.brew)["audio"]["cask"])

    def test_add_mas_appends_once_by_id(self):
        self.assertTrue(brew_sync.add_mas_entry(self.brew, "mas", "Logic Pro.app", "634148309"))
        self.assertFalse(brew_sync.add_mas_entry(self.brew, "mas", "Logic Pro X.app", "634148309"))
        text = (self.brew / "mas.rb").read_text()
        self.assertTrue(text.endswith('mas "Logic Pro", id: 634148309\n'))
        self.assertEqual(brew_sync.read_profiles(self.brew)["mas"]["mas"], {"634148309"})

    def test_ignore_appends_once(self):
        self.assertTrue(brew_sync.add_ignored(self.brew, "Safari.app"))
        self.assertFalse(brew_sync.add_ignored(self.brew, "Safari.app"))
        self.assertEqual(brew_sync.read_ignored(self.brew), {"Safari.app"})


if __name__ == "__main__":
    unittest.main()
