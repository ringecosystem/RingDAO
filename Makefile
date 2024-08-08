.PHONY: all fmt clean test sync foundry

-include .env

all    :; @forge build
fmt    :; @forge fmt
clean  :; @forge clean
test   :; @forge test
deploy :; @forge script script/Deploy.s.sol:Deploy --rpc-url "https://koi-rpc.darwinia.network" --broadcast
dry-run:; @forge script script/Deploy.s.sol:Deploy --rpc-url "https://koi-rpc.darwinia.network"

sync   :; @git submodule update --recursive

foundry:; curl -L https://foundry.paradigm.xyz | bash
