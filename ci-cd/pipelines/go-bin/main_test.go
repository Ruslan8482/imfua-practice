package main

import "testing"

func TestAdd(t *testing.T) {
	got := add(20, 22)
	if got != 42 {
		t.Fatalf("add(20, 22) = %d, want 42", got)
	}
}
