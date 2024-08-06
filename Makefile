.PHONY: all fmt clean test sync foundry

-include .env

all    :; @forge build
fmt    :; @forge fmt
clean  :; @forge clean
test   :; @forge test
deploy :; @forge script script/Deploy.s.sol:Deploy --chain ${chain-id} --broadcast --verify

sync   :; @git submodule update --recursive

foundry:; curl -L https://foundry.paradigm.xyz | bash
