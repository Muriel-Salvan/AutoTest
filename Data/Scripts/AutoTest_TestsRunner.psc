Scriptname AutoTest_TestsRunner
{
  Global script running the whole tests framework.
  Dependencies:
  * SKSE for SaveGame
  * PapyrusUtils for JsonUtil (https://www.nexusmods.com/skyrimspecialedition/mods/13048)
  * ConsoleUtil (https://www.nexusmods.com/skyrimspecialedition/mods/24858)
}

; To add a new test type, with its own database:
; * Create a new test script inheriting AutoTest_Suite
; * Implement all the mandatory [API] functions
; * In the CK, edit the AutoTest_ScriptsQuest and add a new ReferenceAlias on Player, with the new script attached (and any Property it might need)

; Start a new tests session
; This will mark saves so that when a load game is done tests continue automatically
function StartTestsSession() global
  AutoTest_Log.Log("Start a new tests session")
  ; Set the context that we are running tests
  string jsonFileName = "AutoTest_Config.json"
  JsonUtil.SetStringValue(jsonFileName, "tests_execution", "run")
  JsonUtil.Save(jsonFileName)
  ; Don't use ConsoleUtil to save: it results in the game hanging
  ; ConsoleUtil.ExecuteCommand("save auto_test")
  Game.SaveGame("auto_test")
endFunction

; End the tests session
function EndTestsSession() global
  ; Set the context that we are running tests
  string jsonFileName = "AutoTest_Config.json"
  JsonUtil.SetStringValue(jsonFileName, "tests_execution", "end")
  JsonUtil.SetStringValue(jsonFileName, "on_start", "nothing")
  JsonUtil.Save(jsonFileName)
  AutoTest_Log.Log("End the tests session")
  ; In case we are supposed to exit at the end of the tests session, do it.
  if JsonUtil.GetStringValue(jsonFileName, "on_stop") == "exit"
    AutoTest_Log.Log("Quit game as required at the end of the tests session")
    ConsoleUtil.ExecuteCommand("qqq")
  endIf
endFunction

; Are we in a tests session?
;
; Result::
; * bool: Are we in a tests session?
bool function InTestsSession() global
  return (JsonUtil.GetStringValue("AutoTest_Config.json", "tests_execution") == "run")
endFunction

; Initialize tests that are attached to a given quest script, as Reference Aliases
;
; Parameters::
; * *questScript* (Quest): The quest containing test scripts as ReferenceVariables
function InitTests(Quest questScript) global
  AutoTest_Log.Log("Initialize tests from quest " + questScript.GetName())
  int nbrTestTypes = questScript.GetNumAliases()
  int idxTestType = 0
  while idxTestType < nbrTestTypes
    (questScript.GetNthAlias(idxTestType) as AutoTest_Suite).InitTests()
    idxTestType += 1
  endWhile
endFunction

; Register tests that are attached to a given quest script, as Reference Aliases
; Prerequisites:
; * InitTests must have been called before calling this function.
;
; Parameters::
; * *questScript* (Quest): The quest containing test scripts as ReferenceVariables
function RegisterTests(Quest questScript) global
  AutoTest_Log.Log("Register tests from quest " + questScript.GetName())
  int nbrTestTypes = questScript.GetNumAliases()
  int idxTestType = 0
  while idxTestType < nbrTestTypes
    AutoTest_Suite scriptTest = questScript.GetNthAlias(idxTestType) as AutoTest_Suite
    string testType = scriptTest.GetTestType()
    AutoTest_Log.Log("Register " + testType + " tests...")
    scriptTest.BeginDbTransaction()
    scriptTest.ClearRegisteredTests()
    scriptTest.RegisterTests()
    scriptTest.EndDbTransaction()
    AutoTest_Log.Log("" + scriptTest.NbrRegisteredTests() + testType + " tests registered.")
    idxTestType += 1
  endWhile
endFunction

; Clear registered tests statuses.
; Prerequisites:
; * InitTests must have been called before calling this function.
;
; Parameters::
; * *questScript* (Quest): The quest containing test scripts as ReferenceVariables
function ClearTestsStatuses(Quest questScript) global
  AutoTest_Log.Log("Clear test statuses from quest " + questScript.GetName())
  int nbrTestTypes = questScript.GetNumAliases()
  int idxTestType = 0
  while idxTestType < nbrTestTypes
    AutoTest_Suite scriptTest = questScript.GetNthAlias(idxTestType) as AutoTest_Suite
    string testType = scriptTest.GetTestType()
    AutoTest_Log.Log("Clear statuses for " + testType + " tests...")
    scriptTest.BeginDbTransaction()
    int nbrTests = scriptTest.NbrRegisteredTests()
    int idxTest = 0
    while idxTest < nbrTests
      scriptTest.SetTestStatus(scriptTest.GetTestName(idxTest), "pending")
      idxTest += 1
    endWhile
    scriptTest.EndDbTransaction()
    AutoTest_Log.Log("All " + testType + " test statuses cleared.")
    idxTestType += 1
  endWhile
endFunction

; Run tests that are attached to a given quest script, as Reference Aliases.
; Prerequisites:
; * InitTests must have been called before calling this function.
;
; Parameters::
; * *questScript* (Quest): The quest containing test scripts as ReferenceVariables
function RunTests(Quest questScript) global
  AutoTest_Log.Log("Run tests from quest " + questScript.GetName())
  int nbrTestTypes = questScript.GetNumAliases()
  int idxTestType = 0
  while idxTestType < nbrTestTypes && InTestsSession()
    AutoTest_Suite scriptTest = questScript.GetNthAlias(idxTestType) as AutoTest_Suite
    string testType = scriptTest.GetTestType()
    AutoTest_Log.Log("Start running " + testType + " tests...")
    scriptTest.BeforeTestsRun()
    int nbrTests = scriptTest.NbrRegisteredTests()
    int idxTest = 0
    while idxTest < nbrTests && InTestsSession()
      string testName = scriptTest.GetTestName(idxTest)
      string testStatus = scriptTest.GetTestStatus(testName)
      if testStatus == "" || testStatus == "started"
        AutoTest_Log.Log("[ " + testType + " / " + testName + " (" + testStatus + ") ] - Start test")
        scriptTest.SetTestStatus(testName, "started")
        scriptTest.RunTest(testName)
        AutoTest_Log.Log("[ " + testType + " / " + testName + " (" + scriptTest.GetTestStatus(testName) + ") ] - Test end")
      endIf
      idxTest += 1
    endWhile
    scriptTest.AfterTestsRun()
    AutoTest_Log.Log("All " + testType + " tests run.")
    idxTestType += 1
  endWhile
  EndTestsSession()
endFunction
