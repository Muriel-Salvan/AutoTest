Scriptname AutoTest_InGameMenu extends ObjectReference
{
  Small script adding some testing UI to an activator.
  Useless for the automatic tests run.
  Dependencies:
  * SkyUILib for the menu interface (https://www.nexusmods.com/skyrim/mods/57308)
}

; Quest containing all ReferenceAlias for each test script
Quest Property QuestScriptsContainer Auto

Event OnActivate(ObjectReference akActionRef)
  String[] sOptions = new String[4]
  sOptions[0] = "Register tests"
  sOptions[1] = "Run tests"
  sOptions[2] = "Clear tests statuses"
  sOptions[3] = "Exit"
  int iInput = ((Self as Form) as UILIB_1).ShowList("Integration testing", sOptions, 0, 0)
  if iInput == 0
    AutoTest_TestsRunner.InitTests(QuestScriptsContainer)
    AutoTest_TestsRunner.RegisterTests(QuestScriptsContainer)
  elseif iInput == 1
    AutoTest_TestsRunner.StartTestsSession()
    AutoTest_TestsRunner.InitTests(QuestScriptsContainer)
    AutoTest_TestsRunner.RunTests(QuestScriptsContainer)
  elseif iInput == 2
    AutoTest_TestsRunner.InitTests(QuestScriptsContainer)
    AutoTest_TestsRunner.ClearTestsStatuses(QuestScriptsContainer)
  endIf
endEvent
