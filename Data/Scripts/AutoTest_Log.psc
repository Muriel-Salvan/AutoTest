Scriptname AutoTest_Log extends ObjectReference
{
  Simple log helpers, used by other scripts.
}

; Init logs
function InitLog() global
  Debug.OpenUserLog("AutoTest")
endFunction

; Log a message, both on screen and on file
;
; Parameters::
; * *msg* (string): The message to log
function Log(string msg) global
  Debug.TraceUser("AutoTest", msg)
  Debug.Notification(msg)
endFunction
