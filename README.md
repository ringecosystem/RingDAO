# <h1 align="center"> RingDAO </h1>

## Koi
```
  Delegation Wall:  0x0980Bf75a38e8367B479c363432d1E91C6414727
  TokenVoting Plugin Setup:  0x73b3B8d450a3155feD62A74622b6E9139874CD1d
  TokenVoting Plugin Repo:  0x4c0729D8eB9B36F2040B8D0aE1F51B15B0D7BdF0
  Ring DAO:  0x005493b5658e6201F06FE2adF492610635505F4C
  Installed Plugins:
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
