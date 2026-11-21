#!/usr/bin/env bash
set -euo pipefail

output=$(bash "$(dirname "$0")/../hello.sh")
expected="Привет, мир! Я только что запустил CI!"

if [ "$output" != "$expected" ]; then
    echo "Ожидалось: $expected"
    echo "Получено:  $output"
    exit 1
fi

echo "hello.sh: тест пройден"
