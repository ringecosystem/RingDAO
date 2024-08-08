# <h1 align="center"> RingDAO </h1>

## Koi
```
  Multisig Plugin Setup:  0xC93c3931a2045FCb9C2280f710717900F9C14fBc
  TokenVoting Plugin Setup:  0x91943aa31Db7c43761318F0191156044c0f86021
  OptimisticTokenVoting Plugin Setup:  0x71111E17BC5597595d80b2fEc787fAbAD69a98e2
  Multisig Plugin Repo:  0xee93c838B32b70680f36f43652b643712e4ED28f
  TokenVoting Plugin Repo:  0x1149E11017DE9C0D1943B7B764134dB4640DC7b3
  OptimisticTokenVoting Plugin Repo:  0x733b9C8d6762d3FAC6C2Ee61F55971492644C0D7
  Ring DAO:  0x638A95b929977bFe720290e12C71B3901d310afE
  Installed Plugins:
  -  0x005D4B92F66dB792b375c274550b11BE41BD93eB
  -  0x875D59D1058425F0c945e9193B29638c5622e657
  -  0xE4615D1F35B5A589c65a5A1720E1b65A3965aB18
```

## Optimistic Token Voting plugin

This plugin is an adapted version of Aragon's [Optimistic Token Voting plugin](https://github.com/aragon/optimistic-token-voting-plugin). 

Only addresses that have been granted `PROPOSER_PERMISSION_ID` on the plugin can create proposals. These adresses belong to the multisig's governed by the Security Council. 

Proposals can only be executed when the veto threshold hasn't been reached after a minimum period of time.

The governance settings need to be defined when the plugin is installed but the DAO can update them at any time.

### Permissions

- Only proposers can create proposals on the plugin
- The plugin can execute actions on the DAO
- The DAO can update the plugin settings
- The DAO can upgrade the plugin

## Standard Multisig

It allows the Security Council members to create and approve proposals. After a certain minimum of approvals is met, proposals can be relayed to the [Optimistic Token Voting plugin](#optimistic-token-voting-plugin) only.

![Standard proposal flow](./img/std-proposal-flow.png)

### Permissions

- Only members can create proposals
- Only members can approve
- The plugin can only create proposals on the [Optimistic Token Voting plugin](#optimistic-token-voting-plugin) provided that the `duration` is equal or greater than the minimum defined
- The DAO can update the plugin settings

## Emergency Multisig

Like before, this plugin allows Security Council members to create and approve proposals. If a super majority approves, proposals can be executed immediately.

### Permissions

- Only members can create proposals
- Only members can approve
- The plugin can execute actions on the DAO immediately
- The DAO can update the plugin settings

## DO's and DONT's

- Never grant `ROOT_PERMISSION` unless you are just trying things out
- Never uninstall all plugins, as this would brick your DAO
- Ensure that there is at least always one plugin with `EXECUTE_PERMISSION` on the DAO
- Ensure that the DAO is ROOT on itself
- Use the `_gap[]` variable for upgradeable plugins, as a way to reserve storage slots for future plugin implementations
  - Decrement the `_gap` number for every new variable (slot) you add in the future
