import sys


def greet(name="world"):
    return f"Hello, {name}!"


def main(argv=None):
    argv = sys.argv[1:] if argv is None else argv
    name = argv[0] if argv else "world"
    print(greet(name))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
