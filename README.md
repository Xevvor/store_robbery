# store_robbery

Simple store robbery script for FiveM built around `ox_lib`, `ox_target`, and `ox_inventory`.

## Features

- Configurable clerk locations
- `ox_target` interaction on each clerk
- Pistol requirement before a robbery can start
- Threatening phase and stealing phase with progress UI
- Random payout between configurable min and max values
- Per-shop cooldowns
- Basic server-side validation for start and payout checks

## Dependencies

- `ox_lib`
- `ox_target`
- `ox_inventory`
- `rpemotes-reborn`

## Installation

1. Drop the `store_robbery` folder into your server resources directory.
2. Make sure the dependencies are installed and started before this resource.
3. Add `ensure store_robbery` to your `server.cfg`.
4. Check `config.lua` and set the reward item to something that exists on your server.

## Configuration

Everything is handled in `config.lua`.

- `Config.Shops` controls where clerks spawn
- `Config.Durations` controls the threatening and stealing timers
- `Config.Rewards` controls the item and payout range
- `Config.Cooldown` controls how long each shop stays on cooldown
- `Config.Validation` controls start distance, finish leeway, and payout distance
- `Config.AllowedPistols` controls which weapons can be used
- `Config.ClerkReaction` controls the clerk animation mode

## Notes

- Default reward item is `black_money`
- Clerks are spawned by the resource and cleaned up on resource stop
- Cooldown is only applied after a successful payout

## Gif

![Store Robbery Preview](store_robbery.gif)
