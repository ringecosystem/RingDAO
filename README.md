# <h1 align="center"> RingDAO </h1>

## Koi
```
  Delegation Wall:  0x03001EeE0B9de7B724EEd34755E297D839F4d733
  TokenVoting Plugin Setup:  0xF446C5cb56B656Ab36A7841283d0F14627881663
  TokenVoting Plugin Repo:  0x1674298c7161f0468BC7caDff994466197F28908
  Ring DAO:  0x039084F9b1f4e6dBC7B2b57d6832B1f68aC92597
  Installed Plugins:
  -  0x728f6D3377fF8C6668b4d0a957dD8FA258AD7e2B
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
