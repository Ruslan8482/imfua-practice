package main

import "testing"

func TestSum(t *testing.T) {
	tests := []struct {
		name	string
		numbers	[]int
		want	int
	}{
		{name: "empty", numbers: nil, want: 0},
		{name: "positive", numbers: []int{1, 2, 3}, want: 6},
		{name: "negative", numbers: []int{-1, 1, 5}, want: 5},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := sum(tt.numbers...); got != tt.want {
				t.Fatalf("sum(%v) = %d, want %d", tt.numbers, got, tt.want)
			}
		})
	}
}
