package main

func greeting(name string) string {
	if name == "" {
		return "Hello, Fyne!"
	}
	return "Hello, " + name + "!"
}
