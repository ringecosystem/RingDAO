# <h1 align="center"> RingDAO </h1>

## Koi
```
  Delegation Wall:  0x6b55a9CB41EE6b95DAb3d9D32ECaDd1F719685AC
  TokenVoting Plugin Setup:  0x8657f640f7490A5781967D5Fd5Ae59a98F315c1A
  TokenVoting Plugin Repo:  0x3b9fd6A0BcfF420277c91ef0c396552831EC2eBE
  Ring DAO:  0x7d353d0c66Bd45abc6c36E920cb9E6cB06C4af57
  Installed Plugins:
  -  0xDff4C414062a8fB2242110af661C5407eFEd73d1
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
