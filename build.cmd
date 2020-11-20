@ECHO OFF

REM Build a packaged version of AutoTest, ready to be uploaded on NexusMods.

REM Uses the following environment variables:
REM * *gameDir*: Path to the game path (storing the game executables) [default: C:\Program Files (x86)\Steam\steamapps\common\Skyrim Special Edition]
REM * *papyrusUtilDir*: Path to the PapyrusUtils mod, containing scripts sources of the JsonUtil library [default: %gameDir%\Data]
REM * *consoleUtilDir*: Path to the ConsoleUtil mod, containing scripts sources [default: %gameDir%\Data]
REM * *skyUILibDir*: Path to the skyUILibDir mod, containing scripts sources [default: %gameDir%\Data]
REM * *sevenZipDir*: Path to the 7-zip utility [default: C:\Program Files\7-Zip]

REM Set default values
IF NOT DEFINED gameDir (
  set "gameDir=C:\Program Files (x86)\Steam\steamapps\common\Skyrim Special Edition"
)
IF NOT DEFINED papyrusUtilDir (
  set "papyrusUtilDir=%gameDir%\Data"
)
IF NOT DEFINED consoleUtilDir (
  set "consoleUtilDir=%gameDir%\Data"
)
IF NOT DEFINED skyUILibDir (
  set "skyUILibDir=%gameDir%\Data"
)
IF NOT DEFINED sevenZipDir (
  set "sevenZipDir=C:\Program Files\7-Zip"
)

cd .\Data\Source\Scripts
"%gameDir%\Papyrus Compiler\PapyrusCompiler.exe" . -all -output="..\..\Scripts" -flags="%gameDir%\Data\Source\Scripts\TESV_Papyrus_Flags.flg" -import="%gameDir%\Data\Source\Scripts;%papyrusUtilDir%\Source\Scripts;%consoleUtilDir%\Source\Scripts;%skyUILibDir%\Source\Scripts"
cd ..\..\..

del AutoTest.7z
"%sevenZipDir%\7z.exe" a AutoTest.7z Data\ CHANGELOG.md LICENSE README.md docs\

md_to_bbcode --input README.md --output README.bbcode
