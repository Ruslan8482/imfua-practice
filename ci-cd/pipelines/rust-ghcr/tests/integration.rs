use rust_ghcr::greet;

#[test]
fn test_greet() {
    assert_eq!(greet("GHCR"), "Hello, GHCR!");
}
