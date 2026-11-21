package main

import "testing"

func TestParseBoardLine(t *testing.T) {
	board, ok := ParseBoardLine("/dev/ttyACM0 arduino:avr:uno Arduino Uno")
	if !ok {
		t.Fatal("expected board to be parsed")
	}
	if board.Port != "/dev/ttyACM0" {
		t.Fatalf("Port = %q", board.Port)
	}
	if board.FQBN != "arduino:avr:uno" {
		t.Fatalf("FQBN = %q", board.FQBN)
	}
	if board.Name != "Arduino Uno" {
		t.Fatalf("Name = %q", board.Name)
	}
}

func TestParseBoardLineInvalid(t *testing.T) {
	if _, ok := ParseBoardLine("garbage"); ok {
		t.Fatal("expected invalid line")
	}
}
