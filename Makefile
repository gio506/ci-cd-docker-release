SHELL := /usr/bin/env bash

.PHONY: up seed smoke down clean

up:
	./scripts/up.sh

seed:
	./scripts/seed.sh

smoke:
	./scripts/smoke.sh

down:
	./scripts/down.sh

clean:
	./scripts/down.sh --purge
