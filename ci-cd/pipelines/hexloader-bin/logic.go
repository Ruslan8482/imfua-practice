package main

import (
	"encoding/hex"
	"fmt"
	"strings"
)

type IntelHexRecord struct {
	ByteCount	int
	Address		int
	Type		int
	Data		[]byte
	Checksum	int
}

func ParseIntelHex(line string) (IntelHexRecord, error) {
	line = strings.TrimSpace(strings.TrimPrefix(line, ":"))
	raw, err := hex.DecodeString(line)
	if err != nil {
		return IntelHexRecord{}, err
	}
	if len(raw) < 5 {
		return IntelHexRecord{}, fmt.Errorf("record too short")
	}

	sum := 0
	for _, b := range raw {
		sum += int(b)
	}
	if sum&0xff != 0 {
		return IntelHexRecord{}, fmt.Errorf("invalid checksum")
	}

	record := IntelHexRecord{
		ByteCount:	int(raw[0]),
		Address:	int(raw[1])<<8 | int(raw[2]),
		Type:		int(raw[3]),
		Data:		raw[4 : len(raw)-1],
		Checksum:	int(raw[len(raw)-1]),
	}
	return record, nil
}
