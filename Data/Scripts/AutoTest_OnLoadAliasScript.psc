ScriptName AutoTest_OnLoadAliasScript extends ReferenceAlias

AutoTest_OnLoadQuestScript Property QuestScript Auto
Quest Property QuestScriptsContainer Auto

Event OnPlayerLoadGame()
  QuestScript.InitializeAutoTest(QuestScriptsContainer)
EndEvent
