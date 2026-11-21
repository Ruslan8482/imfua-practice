use hello_rust::{add, greet};

#[test]
fn test_greet() {
    assert_eq!(greet("CI"), "Hello, CI!");
}

#[test]
fn test_add() {
    assert_eq!(add(2, 3), 5);
}
