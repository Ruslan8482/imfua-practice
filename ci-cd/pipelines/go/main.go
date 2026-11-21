package main

import "fmt"

var version = "dev"

func main() {
	fmt.Printf("Hello from Go! sum(1, 2, 3) = %d (version %s)\n", sum(1, 2, 3), version)
}
