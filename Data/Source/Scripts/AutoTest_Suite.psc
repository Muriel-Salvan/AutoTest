Scriptname AutoTest_Suite extends ReferenceAlias
{
  Common interface of any script implementing integration testing.
  Helpers to access the test database, stored in JSON files.
  Dependencies:
  * PapyrusUtils for JsonUtil (https://www.nexusmods.com/skyrimspecialedition/mods/13048)
}

string gTestType = "Unknown"
string gJSONRunFile = "AutoTest_Unknown_Run.json"
string gJSONStatusesFile = "AutoTest_Unknown_Statuses.json"
bool gInsideTransaction = false

; Initialize the script
; [API] This function is mandatory and has to use SetTestType
function InitTests()
  ; To be overriden
endFunction

; Register tests
; [API] This function is mandatory
function RegisterTests()
  ; To be overriden
endFunction

; Prepare the runs of tests
; [API] This function is optional
function BeforeTestsRun()
  ; To be overriden
endFunction

; Run a given registered test
; [API] This function is mandatory
;
; Parameters::
; * *testName* (string): The test name to run
function RunTest(string testName)
  ; To be overriden
endFunction

; Finalize the runs of tests
; [API] This function is optional
function AfterTestsRun()
  ; To be overriden
endFunction

; Log a message
;
; Parameters::
; * *msg* (string): Message to log
function Log(string msg)
  AutoTest_Log.Log("[ " + gTestType + " ] - " + msg)
endFunction

; Set the test type
;
; Parameters::
; * *testType* (string): The test type
function SetTestType(string testType)
  gTestType = testType
  gJSONRunFile = "AutoTest_" + gTestType + "_Run.json"
  gJSONStatusesFile = "AutoTest_" + gTestType + "_Statuses.json"
endFunction

; Get the test type
;
; Result::
; * string: The test type
string function GetTestType()
  return gTestType
endFunction

; Set a test status in the JSON db
;
; Parameters::
; * *testName* (string): The test name
; * *testStatus* (string): The test status
function SetTestStatus(string testName, string testStatus)
  JsonUtil.SetStringValue(gJSONStatusesFile, testName, testStatus)
  SaveDb()
endFunction

; Get a test status in the JSON db
;
; Parameters::
; * *testName* (string): The test name
; Result::
; * string: The test status
string function GetTestStatus(string testName)
  return JsonUtil.GetStringValue(gJSONStatusesFile, testName)
endFunction

; Get the number of registered tests
;
; Result::
; * int: The number of registered tests
int function NbrRegisteredTests()
  return JsonUtil.StringListCount(gJSONRunFile, "tests_to_run")
endFunction

; Get the test name that has been registered at a given index
;
; Parameters::
; * *testIdx* (int): The registered test index
; Result::
; * string: The test name
string function GetTestName(int testIdx)
  return JsonUtil.StringListGet(gJSONRunFile, "tests_to_run", testIdx)
endFunction

; Register a new test
;
; Parameters::
; * *testName* (string): The test name
function RegisterNewTest(string testName)
  int nbrTests = JsonUtil.StringListAdd(gJSONRunFile, "tests_to_run", testName)
  if nbrTests % 5000 == 0
    ; Small progression display
    AutoTest_Log.Log("Number of " + gTestType + " tests registered: " + nbrTests)
  endIf
endFunction

; Save the JSON Db on disk
;
; Parameters::
; * *forceSave* (bool): Do we force save? If false, then don't save if we are in a transaction [default = false]
function SaveDb(bool forceSave = false)
  if forceSave || !gInsideTransaction
    JsonUtil.Save(gJSONStatusesFile)
    JsonUtil.Save(gJSONRunFile)
  endIf
endFunction

; Start a transaction that might modify the JSON database.
function BeginDbTransaction()
  gInsideTransaction = true
endFunction

; End a transaction that might have modified the JSON database.
function EndDbTransaction()
  SaveDb(true)
  gInsideTransaction = false
endFunction

; Clear registered tests
function ClearRegisteredTests()
  JsonUtil.StringListClear(gJSONRunFile, "tests_to_run")
  SaveDb()
endFunction
