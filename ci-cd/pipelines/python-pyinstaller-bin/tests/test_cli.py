import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "src"))

from cli import greet, main  # noqa: E402


def test_greet():
    assert greet() == "Hello, world!"
    assert greet("PyInstaller") == "Hello, PyInstaller!"


def test_main_prints_greeting(capsys):
    assert main(["CI"]) == 0
    assert capsys.readouterr().out.strip() == "Hello, CI!"
