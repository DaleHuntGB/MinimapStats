# MinimapStats V4.1.2 [Updated 07 - 01 - 2024]

**Clean**. **Functional**. **Minimal**.

MinimapStats, created & maintained by [Unhalted](https://github.com/DaleHuntGB), was developed to add meaningful information to the minimap without comprising on aesthetics or performance.

## Table of Contents

- [MinimapStats Elements](#minimapstats-elements)
  - [Shared Options](#shared-options-across-elements)
  - [Specific Options](#specific-options-per-element)
  - [Time Element](#time)
  - [Location Element](#location)
  - [Information Element](#information)
  - [Instance Difficulty Element](#instance-difficulty)
  - [Coordinates Element](#coordinates)
  - [Font & Colour Element](#font--colour)
- [Element Updates Explained](#element-updates-explained)
- [Installation](#installation)

### MinimapStats Elements

#### Shared Options Across Elements

- Toggle.
- Font Size.
- Anchor Positions.
- X & Y Offsets.

#### Specific Options Per Element

##### Time

- Format: 12 Hour, 24 Hour, 12 Hour Server Time, 24 Hour Server Time.
- Update Frequency in Seconds.
- Hovering over the element will display the date.

##### Location

- Display Reaction Colour.

##### Information

- Format: FPS [HomeMS], FPS [WorldMS], FPS, HomeMS [WorldMS], HomeMS, WorldMS.
- Update Frequency in Seconds.
- Hovering over the element will display some useful information in the tooltip. These include Raid / Dungeon Lockouts and Friend List information.

##### Instance Difficulty

- Test Instance Difficulty.

##### Coordinates

- Format: No Decimals [00, 00], One Decimal [00.0, 00.0], Two Decimals [00.00, 00.00]
- Update Frequency in Seconds.

### Font & Colour

- Class Colour Toggle.
- Primary Font Colour.
- Secondary Font Colour.
- Global Font.
- Global Font Outline.
- Debug Mode - Display when elements are being updated.
- Reset Defaults.

### Element Updates Explained

Elements such as **Time**, **Information** and **Coordinates** will need to be updated more frequently as they are displaying information in real-time. However, I have ensured that the minimum update is no more than once per second, this update interval can be changed by the user through the configuration in-game.

Elements such **Location** & **Instance Difficulty** are updated on events and therefore, if those events are not being fired, they will merely remain static on your screen until needed.

### Installation

1. Download the latest version of MinimapStats from the [CurseForge](https://www.curseforge.com/wow/addons/minimapstats) or [WagoAddons](https://addons.wago.io/addons/minimapstats).
2. Use the CurseForge app to install the AddOn or extract the downloaded archive to your WoW AddOns folder.
3. Reload your UI or restart the game client.
