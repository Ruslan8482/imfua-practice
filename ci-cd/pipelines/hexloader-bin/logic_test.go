package main

import "testing"

func TestParseIntelHex(t *testing.T) {
	record, err := ParseIntelHex(":0300000001020304F7")
	if err != nil {
		t.Fatal(err)
	}
	if record.ByteCount != 3 {
		t.Fatalf("ByteCount = %d, want 3", record.ByteCount)
	}
	if len(record.Data) != 3 || record.Data[0] != 1 || record.Data[2] != 3 {
		t.Fatalf("unexpected data: %v", record.Data)
	}
}

func TestParseIntelHexBadChecksum(t *testing.T) {
	if _, err := ParseIntelHex(":030000000102030400"); err == nil {
		t.Fatal("expected checksum error")
	}
}
