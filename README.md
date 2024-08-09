# <h1 align="center"> RingDAO </h1>

## Koi
```
  Delegation Wall:  0xA1f68f22830fF74D617d9021C0fFf1cB4dcE3855
  TokenVoting Plugin Setup:  0x0860B316305D7f3F0460057d4608447B1d47FB3c
  TokenVoting Plugin Repo:  0x81cC3d1915af283491F2B34160893d773C03eb5a
  Ring DAO:  0xAA3B8e182b6E9Ee46F5A68e31171EC6444F76DCF
  Installed Plugins:
  -  0x0394Fdc83232B85c03F7d2c4184619768c92bbC1
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
