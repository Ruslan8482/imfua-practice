package main

import "strings"

type Board struct {
	Port string
	FQBN string
	Name string
}

func ParseBoardLine(line string) (Board, bool) {
	parts := strings.Fields(line)
	if len(parts) < 3 {
		return Board{}, false
	}
	return Board{
		Port: parts[0],
		FQBN: parts[1],
		Name: strings.Join(parts[2:], " "),
	}, true
}
