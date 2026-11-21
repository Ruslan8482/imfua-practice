package main

import "testing"

func TestGreeting(t *testing.T) {
	tests := []struct {
		name	string
		want	string
	}{
		{name: "", want: "Hello, Fyne!"},
		{name: "CI", want: "Hello, CI!"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := greeting(tt.name); got != tt.want {
				t.Fatalf("greeting(%q) = %q, want %q", tt.name, got, tt.want)
			}
		})
	}
}
