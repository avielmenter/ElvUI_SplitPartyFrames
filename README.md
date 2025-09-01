# ElvUI Split Party Frames

An ElvUI plugin that allows you to position party frames individually, using a distinct mover for each party frame. This overrides ElvUI's default positioning options, which only allow you to stack party frames vertically or horizontally with equal spacing.

## Features
- Adds a **"Enable Split Party Frames"** checkbox to the **UnitFrames → Group Units → Party → General → Size and Positions** options panel. This checkbox is enabled by default.  
- When enabled:
  - Party frames are split into separate movable frames.
  - Positioning and sorting options in ElvUI's config are disabled to avoid conflicts.

## Installation
1. Download or clone this repository into your `World of Warcraft/_retail_/Interface/AddOns` folder.  
   The folder should be named **`ElvUI_SplitPartyFrames`**.
2. Restart WoW or reload your UI with `/reload`.
3. Ensure that both **ElvUI** and **ElvUI_SplitPartyFrames** are enabled in the AddOns menu.

## Configuration
The plugin should be enabled by default after installation, but you can toggle it in the ElvUI config UI.
- Open the ElvUI configuration (`/ec`).
- Navigate to **UnitFrames → Group Units → Party → General → Size and Positions**.
- Toggle the **"Enable Split Party Frames"** option.  

## Usage
- Click **Movers** at the top of the ElvUI Config window, and position the movers for each party frame individually.

## Notes
- This plugin only affects **party frames**. Raid frames remain unchanged.
- Because party frames are re-anchored, some of ElvUI’s built-in grouping and positioning options are disabled while the feature is active.
- Safe to use alongside other ElvUI plugins.
