package main

import "fmt"

var version = "dev"

func add(a, b int) int {
	return a + b
}

func main() {
	fmt.Printf("go-bin %s: 20 + 22 = %d\n", version, add(20, 22))
}
