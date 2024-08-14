# <h1 align="center"> RingDAO </h1>

## Koi
```
  Delegation Wall:  0xc254EE0075aF3317b261F541Eea000261c68CEE0
  TokenVoting Plugin Setup:  0x096512bb0B02E7177e1e6CDa2c272E7773F3d812
  TokenVoting Plugin Repo:  0xbF45529032c2E21e93f4CA5b023372A0CB6088b2
  Ring DAO:  0x422c45B07D7c50Bd57697D464F6763fa510e5f2B
  Installed Plugins:
  -  0x2112ad23aBb169942418E87c95A1B3126Db4EA45
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
