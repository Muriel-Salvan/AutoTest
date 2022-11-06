Scriptname AutoTest_Suite_NPCsHead extends AutoTest_Suite_NPCs
{
  Collection of script functions testing NPCs head (using screenshots of naked actors).
  This helps in finding issues with neck seams
  Dependencies:
  * ConsoleUtil (https://www.nexusmods.com/skyrimspecialedition/mods/24858)
  * SKSE for StringUtil (https://skse.silverlock.org/)
}

float gPreviousFov = 65.0
float gPreviousScale = 1.0

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
  gPreviousScale = Game.GetPlayer().GetScale()
  ConsoleUtil.ExecuteCommand("tgm")
  ConsoleUtil.ExecuteCommand("tcai")
  ConsoleUtil.ExecuteCommand("tai")
  ConsoleUtil.ExecuteCommand("fov 20")
  ; Disable UI
  ConsoleUtil.ExecuteCommand("tm")
endFunction

; Finalize the runs of tests
; [API] This function is optional
function AfterTestsRun()
  ConsoleUtil.ExecuteCommand("fov " + gPreviousFov)
  ConsoleUtil.ExecuteCommand("player.setscale " + gPreviousScale)
  ConsoleUtil.ExecuteCommand("tai")
  ConsoleUtil.ExecuteCommand("tcai")
  ConsoleUtil.ExecuteCommand("tgm")
  ; Enable UI
  ConsoleUtil.ExecuteCommand("tm")
endFunction

; Register a screenshot test of a given BaseID
;
; Parameters:
; * *baseId* (Integer): The BaseID to clone and take screenshot
; * *espName* (String): The name of the ESP containing this base ID
function RegisterScreenshotOf(int baseId, string espName)
  RegisterNewTest(espName + "/" + baseId)
endFunction

; Customize ScreenShot function for better child handling.
function ScreenshotOf(int baseId, string espName)

  float NPCScale = 1.0
  float PlayerScale = 1.0
  float PlayerFOV = 10

  int formId = baseId + Game.GetModByName(espName) * 16777216
  Form formToSpawn = Game.GetFormFromFile(formId, espName)
  string formName = formToSpawn.GetName()
  Log("[ " + espName + "/" + baseId + " ] - [ Start ] - Take screenshot of FormID 0x" + formId + " (" + formName + ")")
  Game.GetPlayer().MoveTo(ViewPointAnchor)
  ObjectReference newRef = TeleportAnchor.PlaceAtMe(formToSpawn)
  ; TODO: Add option for clothes here
  newRef.RemoveAllItems()
  ; Wait for the 3D model to be loaded
 
  while (!newRef.Is3DLoaded())
    Utility.wait(0.2)
  endWhile
  Utility.wait(1.0)

  ; get NPC Scale
  NPCScale = newRef.GetScale()
  ; Log("NPC Scale " + NPCScale)
  ; set PC Scale
  ConsoleUtil.ExecuteCommand("player.setscale " + (NPCScale - 0.02))
  PlayerScale = Game.GetPlayer().GetScale()
  ; Log("Player Scale " + PlayerScale)
  ; Set FOV based on scale. Note: may still need tweaking
  if PlayerScale >= 0.7 
    PlayerFOV = 15
  endIf
  if PlayerScale >= 1 
    PlayerFOV = 20
  endIf
  ConsoleUtil.ExecuteCommand("fov " + PlayerFOV)
  ; ensure PC 1st party view
  Game.ForceFirstPerson()
  ; TODO: ensure PC is looking at NPC

  ; Print Screen
  ; TODO: grab PrintScreen key from Config
  Input.TapKey(183)
  ; TODO: Rename/Relocate Screenshots
  ; Remove the reference
  newRef.DisableNoWait()
  newRef.Delete()
  newRef = None
  Log("[ " + espName + "/" + baseId + " ] - [ OK ] - Take screenshot of FormID 0x" + formId + " (" + formName + ")")
endFunction
