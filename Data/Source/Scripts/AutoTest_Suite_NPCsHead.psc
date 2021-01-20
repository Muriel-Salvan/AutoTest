Scriptname AutoTest_Suite_NPCsHead extends AutoTest_Suite_NPCs
{
  Collection of script functions testing NPCs head (using screenshots of naked actors).
  This helps in finding issues with neck seams
  Dependencies:
  * ConsoleUtil (https://www.nexusmods.com/skyrimspecialedition/mods/24858)
  * SKSE for StringUtil (https://skse.silverlock.org/)
}

float gPreviousFov = 65.0

; Initialize the script
; [API] This function is mandatory and has to use SetTestType
function InitTests()
  SetTestType("NPCsHead")
endFunction

; Prepare the runs of tests
; [API] This function is optional
function BeforeTestsRun()
  ; Get the fov value so that we can reset it at the end of the tests run
  gPreviousFov = Utility.GetINIFloat("fDefault1stPersonFOV:Display")
  ConsoleUtil.ExecuteCommand("tgm")
  ConsoleUtil.ExecuteCommand("tcai")
  ConsoleUtil.ExecuteCommand("tai")
  ConsoleUtil.ExecuteCommand("fov 20")
endFunction

; Finalize the runs of tests
; [API] This function is optional
function AfterTestsRun()
  ConsoleUtil.ExecuteCommand("fov " + gPreviousFov)
  ConsoleUtil.ExecuteCommand("tai")
  ConsoleUtil.ExecuteCommand("tcai")
  ConsoleUtil.ExecuteCommand("tgm")
endFunction

; Register a screenshot test of a given BaseID
;
; Parameters:
; * *baseId* (Integer): The BaseID to clone and take screenshot
; * *espName* (String): The name of the ESP containing this base ID
function RegisterScreenshotOf(int baseId, string espName)
  RegisterNewTest(espName + "/" + baseId)
endFunction
