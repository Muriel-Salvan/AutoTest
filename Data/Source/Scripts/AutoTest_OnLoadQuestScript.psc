ScriptName AutoTest_OnLoadQuestScript extends Quest
{
  Note: Big thanks to milzschnitte who posted the technique to call Papyrus scripts from the console: https://www.loverslab.com/topic/58600-skyrim-custom-console-commands-using-papyrus/
}

; Quest containing all ReferenceAlias for each test script
Quest Property QuestScriptsContainer Auto

; OnPlayerLoadGame will not fire the first time
Event OnInit()
  InitializeAutoTest(QuestScriptsContainer)
EndEvent

; Initialize AutoTest.
; This is called on game load.
; Handle continuity in testing after a CTD.
;
; Parameters::
; * *questScript* (Quest): The quest containing test scripts
Function InitializeAutoTest(Quest questScript)
  AutoTest_Log.InitLog()
  UnregisterForMenu("Console")
  RegisterForMenu("Console")
  ; If we are in a tests session, resume it.
  if AutoTest_TestsRunner.InTestsSession()
    AutoTest_Log.Log("Resuming previous tests session")
    ; Automatically resume tests.
    ; The session was already started.
    AutoTest_TestsRunner.InitTests(questScript)
    AutoTest_TestsRunner.RunTests(questScript)
  elseif JsonUtil.GetStringValue("AutoTest_Config.json", "on_start") == "run"
    AutoTest_Log.Log("Starting tests session from the game load")
    ; We have to start testing
    AutoTest_TestsRunner.StartTestsSession()
    AutoTest_TestsRunner.InitTests(questScript)
    AutoTest_TestsRunner.RunTests(questScript)
  endIf
EndFunction

Event OnMenuOpen(string menuName)
  if menuName=="Console"
    RegisterForKey(28)
    RegisterForKey(156)
  endif
endEvent

Event OnMenuClose(string menuName)
  if menuName=="Console"
    UnregisterForKey(28)
    UnregisterForKey(156)
  endif
endEvent

Event OnKeyDown(int keyCode)
  if keyCode == 28 || keyCode == 156
    int cmdCount = UI.GetInt("Console", "_global.Console.ConsoleInstance.Commands.length")
    if cmdCount > 0
      cmdCount -= 1
      string cmdLine = UI.GetString("Console", "_global.Console.ConsoleInstance.Commands." + cmdCount)
      if cmdLine != ""
        bool bSuccess = false
        actor a = Game.GetCurrentConsoleRef() as actor
        if a == None
          a = Game.GetPlayer()
        endif
        string[] cmd = StringUtil.Split(cmdLine, " ")
        ; Handle all possible commands we want to use
        if cmd[0] == "start_tests"
          AutoTest_Log.Log("User issued start_tests")
          AutoTest_TestsRunner.StartTestsSession()
          AutoTest_TestsRunner.InitTests(QuestScriptsContainer)
          AutoTest_TestsRunner.RunTests(QuestScriptsContainer)
          bSuccess = true
        elseif cmd[0] == "stop_tests"
          AutoTest_Log.Log("User issued stop_tests")
          JsonUtil.SetStringValue("AutoTest_Config.json", "stopped_by", "user")
          AutoTest_TestsRunner.EndTestsSession()
          bSuccess = true
        endif
        ; Remove error messages if we handled the command
        if bSuccess == true
          ; Remove last line (error line)
          Utility.WaitMenuMode(0.1)
          string history = UI.GetString("Console", "_global.Console.ConsoleInstance.CommandHistory.text")
          int iHistory = StringUtil.GetLength(history) - 1
          bool bRunning = true
          while iHistory > 0 && bRunning
            if StringUtil.AsOrd(StringUtil.GetNthChar(history, iHistory - 1)) == 13
              bRunning = false
            else
              iHistory -= 1
            endif
          endWhile
          UI.SetString("Console", "_global.Console.ConsoleInstance.CommandHistory.text", StringUtil.Substring(history,0,iHistory))
        endif
      endif
    endif
  endif
endEvent
