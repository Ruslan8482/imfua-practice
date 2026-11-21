from myapp.app import add, greet


def test_add():
    assert add(2, 3) == 5
    assert add(-1, 1) == 0


def test_greet():
    assert greet() == "Hello, world!"
    assert greet("CI") == "Hello, CI!"
