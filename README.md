# Movable Do Fingering

[English](./README.md) | [繁體中文（台灣）](./README.zh-TW.md)

<img align="right" src="./MovableDoFingering.png" width="220" />

Movable Do Fingering is a [MuseScore](https://musescore.org/) plugin based on [nozomu-y/MovableDo](https://github.com/nozomu-y/MovableDo).  
It adds movable-do note names as **fingering texts** (not staff text), so you can quickly annotate scores with Do/Re/Mi (or other notation styles) by tonality.

> ⚠️ **This branch supports MuseScore 4.4 and above only.**  
> If you use MuseScore 4.3 or earlier, use the `main` branch.

## Features

- Adds movable-do names as fingering text.
- Supports four notation styles:
  - `Letters-vowel` (`Do -> d`, `♯Do -> di`, `♭Ti -> ta`)
  - `Letters` (`Do -> d`, `♯Do -> ♯d`, `♭Ti -> ♭t`)
  - `Numeric` (`Do -> 1`, `Re -> 2`, accidentals preserved)
  - `Solfege (Do Re Mi)` (`Do`, `Re`, `Mi`, ...)
- Supports placement above or below staff.
- Supports display mode:
  - `All Notes`
  - `Unison Only` (only labels notes that are in unison with other staves, and appends part names in parentheses)
- Automatically suggests tonality from current key signature when opening the dialog.
- Remembers notation, placement, and display mode preferences.

![Example score using the plugin](readme-assets/example-score.png)

## Installation

1. Download this repository as ZIP (or clone it).
2. Place the files in your MuseScore user `Plugins` folder.
3. Restart MuseScore.
4. Open **Plugins Manager** and enable **Movable Do Fingering**.

## Usage

Run from **Plugins → Composing/Arranging Tools → Movable Do Fingering**.

<img alt="Dialog" src="readme-assets/dialog.png" width="300" />

1. Choose **Tonality**, **Notation**, **Placement**, and **Display Mode**.
2. Click **OK** to insert labels.

Behavior notes:

- If you select a **range**, only that range is processed.
- Without a range selection, the plugin processes the whole score.
- Existing fingering labels are not removed automatically.

## Changes compared to nozomu-y/MovableDo

- Updated for MuseScore 4.4+ dialog/plugin metadata.
- UI text translated and refined in English.
- Added `Letters`, `Numeric`, and `Solfege` notation styles.
- Reorganized tonality menu for readability.
- Added key-signature-based tonality suggestion.
- Added persistent dialog settings.
- Uses **fingering text** output instead of staff text.
- Added unison detection mode with part-name suffixes.
