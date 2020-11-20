# AutoTest

**In-game automatic testing framework for Bethesda games**

When modding a Bethesda game (Skyrim, Fallout...) there comes a time when the game becomes unstable.
This unstability comes from the complex interactions different mods can have, and the difficulty in integrating those interactions, in terms of game objects' properties, scripting, files priorities.
A lot of tools in the modding communities already tackle this issue by providing a lot of checks between mods and their files.
Other tools also offer automatic patches to make mods integration easier.

However some issues are too complex to be diagnosed only by looking at the esp files or the load orders.
For such problems **the gamer has to test in-game**: load different locations, fly around a little bit, check NPCs interactions, etc...
All those in-game tests are really time consuming, and some of those tests could be automated.

The purpose of AutoTest is to **provide a simple in-game testing framework that can execute some of those tests automatically**.
This can save hours of manual testing to have a better confidence in a game's stability.

The list of games that are eligible to this tool (non-exhaustive list):
* Skyrim Special Edition - Tested successfully.
* Skyrim - Not tested yet - Feedback welcome!
* Fallout 4 - Not tested yet - Feedback welcome!

## Requirements

1 tool and 3 mods are needed for AutoTest to work:
* [SKSE](https://skse.silverlock.org/) to support a lot of scripting. - You have to install on your Bethesda game.
* [PapyrusUtils](https://www.nexusmods.com/skyrimspecialedition/mods/13048) to interact with external JSON files for tests run and statuses.
* [SkyUILib](https://www.nexusmods.com/skyrim/mods/57308) to provide a nice menu interface. - This can be installed for both Skyrim and SkyrimSE.
* [ConsoleUtil](https://www.nexusmods.com/skyrimspecialedition/mods/24858) to execute some commands that are not accessible in Papyrus.

## Installation

**AutoTest packages are downloadable from [Nexus Mods](https://www.nexusmods.com/skyrimspecialedition/mods/42520).**

Once requirements are installed, you can use AutoTest either by copying its package content to your Bethesda game's Data folder, or by using its packaged content with a mod manager like [ModOrganizer](https://www.nexusmods.com/skyrimspecialedition/mods/6194).

## Usage

AutoTest is a tool for gamers that want to test the game stability, using in-game testing. Therefore it has to deal with CTDs and must rely on a configuration that is the least intrusive to the game.
For this purpose, the main way to use AutoTest is by using JSON files to pilot the tests to be run and check the tests statuses later.
Alternatively, an in-game menu in a test cell can also be used to configure those JSON files and run tests.
Command consoles can also pilot the tests execution.
The [Modsvaskr](https://www.nexusmods.com/skyrimspecialedition/mods/42521) is a tool that can also use AutoTest based on your mods and provide you with much more potential - highly recommended.

AutoTest is organized around tests suites: each tests suite represents a given type of test to perform. For example the tests suite `NPCs` will be able to test various NPCs from the game, thus realizing several tests.
Test suites are like plugins for AutoTest: they are handled as Papyrus scripts named `AutoTest_Suite_*.psc` and can easily be completed with new ones to implement new kinds of tests. **Contributors more than welcome to provide new test suites that will benefit the whole community!** - Please create a PR on this repo or your fork or contact me if you want to share: I'll be very happy to add your contribution and credit in this project!

### JSON files

AutoTest uses JSON files stored in your game's Data folder, following the pattern `SKSE\Plugins\StorageUtilData\AutoTest_*.json`, and only this pattern.

By default those files do not exist (they are optional), and they can be either created by hand, or by the in-game menu if needed.

#### The main configuration file: `AutoTest_Config.json`

This file configures AutoTest behaviour.

Here is an example of its content:
```json
{
    "string": {
        "on_start": "run",
        "on_stop": "exit",
        "tests_execution": "end"
    }
}
```

Here is an explanation of each one of its properties:
* **on_start**: Gives an action to perform once a game is being loaded. If absent it does nothing. If set to `run` then tests execution will start as soon as the game is loaded.
* **on_stop**: Gives an action to perform once tests have finished executing. If absent it does nothing. If set to `exit` then the game will exit to desktop.
* **tests_execution**: The value is set by AutoTest in-game testing. `run` indicates that a tests session is being executed. `end` indicates that the tests execution has ended.

#### The tests suites' Run files: `AutoTest_*_Run.json`

Each test suite has a JSON file storing the list of test names to be run.
This file is being updated when registering tests to be run.

Here is an example of its content:
```json
{
    "stringList": {
        "tests_to_run": [
            "test_name_1",
            "test_name_2",
            "test_name_3"
        ]
    }
}
```

Here is an explanation of each one of its properties:
* **tests_to_run**: A list of test names to be run when the tests session will start. By default, no test is to be run.

Please refer to the different tests suites sections below to know which test names can be used for each tests suite.

#### The tests suites' Statuses files: `AutoTest_*_Statuses.json`

Each test suite has a JSON file storing the statuses of tests.
This file is being updated when executing tests.

Here is an example of its content:
```json
{
    "string": {
        "test_name_1": "ok",
        "test_name_2": "failed"
    }
}
```

For each test name, the corresponding status is indicated. By default, the status is considered as not run.
Please be aware that statuses should be considered case-insensitive (meaning that `failed` and `Failed` refer to the same status, and you can encounter both cases in the same file, due to a [strange Papyrus bug](https://github.com/xanderdunn/skaar/wiki/Common-Tasks)).
Statuses can vary depending on the test being performed, except for the status `ok` that should be the only one used to indicate a successful test.

Please refer to the different tests suites sections below to know which test names can be used for each tests suite.

When AutoTest starts a tests session, it will run all the tests defined in a Run list, and skip the tests that already have a status `ok`.

### The tests suites

Different tests suites allow for different kind of tests.
The following sections enumerate the different tests suites that can be used in AutoTest.

#### NPCs

The `NPCs` tests suite will take screenshots of NPCs without any inventory.
This is useful to later look at the screenshots to detect black faces, neck gaps, missing meshes, missing textures etc...
Screenshots are taken in the usual game directory, the same way they are taken with the `PrintScreen` key.

The test names used by this suite have the following format: `esp_name/decimal_form_id`.
For example: `skyrim.esm/78433` for the NPC named Beirand in Skyrim Special Edition.

A test run will:
1. Teleport the player to the test cell `AutoTest_TestHall`
2. Summon a copy of the NPC to be tested in front of him, without any inventory,
3. Take a screenshot.

Example of Run file for this test, in `SKSE\Plugins\StorageUtilData\AutoTest_NPCs_Run.json`:
```json
{
    "stringList": {
        "tests_to_run": [
            "skyrim.esm/78433",
            "skyrim.esm/78434"
        ]
    }
}
```

![Example of NPCs test](https://raw.githubusercontent.com/Muriel-Salvan/AutoTest/master/docs/npcs_example.jpg)

#### Locations

The `Locations` tests suite will teleport the player to a given location and make a small camera circle around.
This is useful to make sure that visiting this location does not result in a CTD.

The test names used by this suite have the following formats:
* `worldspace/x/y`. For example: `tamriel/10/6` to test the cell of coordinates (10, 6) in the `tamriel` worldspace.
* `cellname`. For example: `alftand01` to test the interior cell named `alftand01`.

A test run will:
1. Put the player in god mode (as teleporting can put the player in dangerous situations).
2. Teleport the player to the cell to be tested (using a `cow` or `coc` console command).
3. Set the camera in third-person view far away.
4. Make the camera perform a circle around the player for a few seconds.

Example of Run file for this test, in `SKSE\Plugins\StorageUtilData\AutoTest_Locations_Run.json`:
```json
{
    "stringList": {
        "tests_to_run": [
            "Tamriel/17/20",
            "DLC01SoulCairnOrigin",
            "Tamriel/10/0",
            "SolitudeBardsCollege"
        ]
    }
}
```

![Example of Locations test](https://raw.githubusercontent.com/Muriel-Salvan/AutoTest/master/docs/locations_example.gif)

### The in-game menu

A small menu is accessible from a test cell, to register some pre-defined tests and run them.
To access this menu, you have to open the console with the `~` key and teleport to the test cell: `coc AutoTest_TestHall`. Once in the test cell you'll find a stone named `Locked Sarcophagus`. Activate it and the menu will appear.

![In-game menu](https://raw.githubusercontent.com/Muriel-Salvan/AutoTest/master/docs/in_game_menu.jpg)

### The console commands

Some console commands are available to pilot tests run:

* **`start_tests`**: Start the tests session. This will immediately trigger the run of all tests defined in Run lists that do not have yet the status `ok`.
* **`stop_tests`**: Stop the tests session. This will end the current test and stop the tests session.

### Running a tests session

When starting a tests session (either automatically on game load, or using console or the in-game menu), AutoTest will:
1. Mark the session as running in the main JSON config file (`"tests_execution": "run"`).
2. Create a save game named `auto_test`. This is useful to later get back to testing immediately using this save game.
3. Loop over all tests suites, and for each one get its list of tests to execute from the Run list JSON file.
4. Execute all tests that do not have an `ok` status, in the order of the Run list.
5. Mark the session as finished in the main JSON config file (`"tests_execution": "end"`).
6. Exit to desktop if the config file has `"on_stop": "exit"`.

The JSON files are being updated in real-time, so that an external process can use their information while the tests are being executed.

## Compatibility

This mod is compatible with all mods without conflict.

## Troubleshooting

Logs of execution are stored as Papyrus logs in files named `My Games/Skyrim Special Edition/Logs/Script/User/AutoTest.*.log`.
Here is an example of execution logs:

```
[11/18/2020 - 02:25:10PM] AutoTest log opened (PC)
[11/18/2020 - 02:25:10PM] Initialize tests from quest Quest used to attach scripts using Reference Aliases
[11/18/2020 - 02:25:10PM] Run tests from quest Quest used to attach scripts using Reference Aliases
[11/18/2020 - 02:25:10PM] Start running NPCs tests...
[11/18/2020 - 02:25:10PM] [ NPCs / skyrim.esm/78433 () ] - Start test
[11/18/2020 - 02:25:10PM] [ NPCs ] - [ Skyrim.esm/78433 ] - [ Start ] - Take screenshot of FormID 0x78433 (Beirand)
[11/18/2020 - 02:25:12PM] [ NPCs ] - [ Skyrim.esm/78433 ] - [ OK ] - Take screenshot of FormID 0x78433 (Beirand)
[11/18/2020 - 02:25:12PM] [ NPCs / skyrim.esm/78433 (OK) ] - Test end
[11/18/2020 - 02:25:12PM] [ NPCs / skyrim.esm/78434 () ] - Start test
[11/18/2020 - 02:25:13PM] [ NPCs ] - [ Skyrim.esm/78434 ] - [ Start ] - Take screenshot of FormID 0x78434 (Bjartur)
[11/18/2020 - 02:25:14PM] [ NPCs ] - [ Skyrim.esm/78434 ] - [ OK ] - Take screenshot of FormID 0x78434 (Bjartur)
[11/18/2020 - 02:25:15PM] [ NPCs / skyrim.esm/78434 (OK) ] - Test end
[11/18/2020 - 02:25:15PM] All NPCs tests run.
[11/18/2020 - 02:25:15PM] Start running Locations tests...
[11/18/2020 - 02:25:15PM] [ Locations / DLC2ApocryphaWorld/-2/6 () ] - Start test
[11/18/2020 - 02:25:15PM] [ Locations ] - [ Start ] - Testing location DLC2ApocryphaWorld -2, 6
[11/18/2020 - 02:25:22PM] [ Locations ] - Clean memory with PCB
[11/18/2020 - 02:25:22PM] [ Locations ] - [ OK ] - Testing location DLC2ApocryphaWorld -2, 6
[11/18/2020 - 02:25:22PM] [ Locations / DLC2ApocryphaWorld/-2/6 (OK) ] - Test end
[11/18/2020 - 02:25:22PM] [ Locations / Alftand01 () ] - Start test
[11/18/2020 - 02:25:22PM] [ Locations ] - [ Start ] - Testing cell Alftand01
[11/18/2020 - 02:25:38PM] [ Locations ] - [ OK ] - Testing cell Alftand01
[11/18/2020 - 02:25:38PM] [ Locations / Alftand01 (OK) ] - Test end
[11/18/2020 - 02:25:38PM] All Locations tests run.
[11/18/2020 - 02:25:39PM] End the tests session
[11/18/2020 - 02:25:39PM] Quit game as required at the end of the tests session
[11/18/2020 - 02:25:40PM] Log closed
```
Every log also appears in-game on the upper-left corner.

The ESP plugin defines:
* A new start quest and a new reference alias to be able to start tests upon game load.
* A new quest that references all the tests suites that are available, as attached scripts to a reference alias.
* A test cell named `AutoTest_TestHall` with some markers and an activator to run tests.

## Developers corner

### Build a packaged version of AutoTest from the source

This can be achieved using the `build.cmd` tool, from a command-line session:

1. If The game directory is not the default one (standard Skyrim SSE installed via Steam), then set the `gameDir` variable to the game path.
  Example:
  ```bat
  set "gameDir=C:\My Games\Skyrim"
  ```
  
2. If PapyrusUtils is installed in another location than the game data path, set the `papyrusUtilDir` variable to its path.
  Example:
  ```bat
  set "PapyrusUtils=C:\My Mods\PapyrusUtils"
  ```
  
3. If ConsoleUtil is installed in another location than the game data path, set the `consoleUtilDir` variable to its path.
  Example:
  ```bat
  set "consoleUtilDir=C:\My Mods\ConsoleUtil"
  ```
  
4. If SkyUILib is installed in another location than the game data path, set the `skyUILibDir` variable to its path.
  Example:
  ```bat
  set "skyUILibDir=C:\My Mods\SkyUILib"
  ```
  Please note that you may have to move the script sources of SkyUILib from `Scripts\Source` to `Source\Scripts` as their default location changed between Skyrim and Skyrim Special Edition.
  
5. You'll need [7-zip](https://www.7-zip.org/) to package AutoTest. If 7-zip is installed to a non-standard location, specify the path to 7-zip using the `sevenZipDir` variable.
  Example:
  ```bat
  set "sevenZipDir=C:\Programs\7zip"
  ```
  
6. Launch the `build.cmd` command from the root of the repository:
  ```bat
  build.cmd
  ```

This will compile the Papyrus scripts and generate a packaged version of AutoTest in the file `AutoTest.7z`.

## Contributions

Don't hesitate to fork the [Github repository](https://github.com/Muriel-Salvan/AutoTest) and contribute with Pull Requests.
