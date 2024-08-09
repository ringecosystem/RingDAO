# <h1 align="center"> RingDAO </h1>

## Koi
```
  TokenVoting Plugin Setup:  0xDd571cd0E2b3Ee0f27D6C5C4D991Aefd6AFE10bC
  TokenVoting Plugin Repo:  0x1576A49553E4a57515688392b88489DAa0271e9c
  Ring DAO:  0x5791F849b27cf3d3794eAA2aDECa00f475508d20
  Installed Plugins:
  -  0xbD7837d84C5028B81b0CDFEc699f53F5C9594422
```

## Token Voting plugin

This plugin is an adapted version of Aragon's [Token Voting plugin](https://github.com/aragon/osx/tree/v1.3.0/packages/contracts/src/plugins/governance/majority-voting/token). 

Only community members(who owns enough tokens or has enough voting power from being a delegatee) can create proposals. 

Proposals can only be executed when the support threshold and minimum participation have been reached after a minimum period of time.

The governance settings need to be defined when the plugin is installed but the DAO can update them at any time.

### Permissions

- Only community members can create proposals on the plugin
- The plugin can execute actions on the DAO
- The DAO can update the plugin settings
- The DAO can upgrade the plugin

## DO's and DONT's

- Never grant `ROOT_PERMISSION` unless you are just trying things out
- Never uninstall all plugins, as this would brick your DAO
- Ensure that there is at least always one plugin with `EXECUTE_PERMISSION` on the DAO
- Ensure that the DAO is ROOT on itself
- Use the `_gap[]` variable for upgradeable plugins, as a way to reserve storage slots for future plugin implementations
  - Decrement the `_gap` number for every new variable (slot) you add in the future
