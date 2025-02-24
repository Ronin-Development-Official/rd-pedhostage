# QB Rob & Hostage System

A comprehensive system for FiveM servers using QBCore that allows players to rob NPCs and take them hostage. This script provides realistic interactions with NPCs including robberies and hostage situations, complete with animations, item rewards, and police dispatch integration.

## Features

- Rob NPCs at gunpoint for random items and cash
- Take NPCs hostage with realistic animations
- Integrated police dispatch system
- Configurable cooldowns for actions
- Customizable rewards and weapon requirements
- Support for both QB-Inventory and QS-Inventory
- Police count requirements for actions
- Blacklist system for specific NPC models
- Realistic animations for all actions
- Easy-to-use targeting system

## Dependencies

- QBCore Framework
- QB-Target
- PS-Dispatch
- ox_lib

## Installation

1. Download the resource
2. Place it in your resources folder
3. Add the following to your server.cfg:
```lua
ensure qb-core
ensure qb-target
ensure ps-dispatch
ensure ox_lib
ensure rd-robhostage
```

## Configuration

The script is highly configurable through the `config.lua` file:

### Cooldowns
```lua
Config.Cooldowns = {
    Rob = 10,      -- Minutes between robberies
    Hostage = 5    -- Minutes between taking hostages
}
```

### Police Requirements
```lua
Config.RequiredCops = {
    Rob = 0,      -- Required cops for robbing NPCs
    Hostage = 0   -- Required cops for taking hostages
}
```

### Inventory System
```lua
Config.UseQSInventory = true -- Set to false to use qb-inventory
```

### Robbable Items
Configure possible items that can be obtained from robbing NPCs:
```lua
Config.RobbableItems = {
    {item = "lighter", label = "Lighter"},
    {item = "goldchain", label = "Gold Chain"},
    {item = "cash", label = "Cash", minAmount = 100, maxAmount = 500},
    -- Add more items as needed
}
```

## Usage

### Robbing NPCs

1. Approach an NPC
2. Equip a compatible weapon (configured in Config.RequiredWeapons)
3. Use QB-Target to select "Rob Person"
4. Wait for the robbery animation to complete
5. Receive random items from the configured loot table

### Taking Hostages

1. Approach an NPC
2. Equip a compatible weapon
3. Use QB-Target to select "Take Hostage"
4. Control your hostage:
   - Press [G] to release the hostage
   - Press [H] to kill the hostage

### Police Integration

- Robberies and hostage situations will automatically alert police through PS-Dispatch
- Configure dispatch codes and messages in Config.Dispatch
- Set minimum police requirements for actions in Config.RequiredCops

## Blacklisting NPCs

Add NPC models to the blacklist to prevent them from being robbed or taken hostage:

```lua
Config.BlacklistedPeds = {
    "s_m_y_cop_01",
    "s_m_y_sheriff_01",
    -- Add more ped models as needed
}
```

## Animations

The script includes custom animations for:
- Robbery interactions
- Hostage taking
- Hostage release
- Hostage elimination

Configure animation dictionaries and names in Config.Animations.

## Troubleshooting

Common issues and solutions:

1. **Animations not working:**
   - Ensure all animation dictionaries are correct in config.lua
   - Check if the animations are available in your GTA V version

2. **Items not receiving:**
   - Verify inventory system setting (QS or QB)
   - Check if items exist in your shared items list
   - Ensure item names match exactly in config

3. **Targeting not working:**
   - Verify QB-Target is properly installed
   - Check distance settings in Config.MaxDistance
   - Ensure target options are properly registered

## Support

For support, please:
1. Check the configuration file first
2. Verify all dependencies are up to date
3. Test with default configuration
4. Report issues with detailed information

## Credits

Created by RoninDevelopment
Version: 1.0.0

## License

This project is licensed under the MIT License - see the LICENSE file for details.