use hello_rust_1::{greet, multiply};

#[test]
fn test_greet() {
    assert_eq!(greet("CI"), "Hello, CI!");
}

#[test]
fn test_multiply() {
    assert_eq!(multiply(6, 7), 42);
}
