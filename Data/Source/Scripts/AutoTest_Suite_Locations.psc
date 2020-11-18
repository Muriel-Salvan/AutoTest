Scriptname AutoTest_Suite_Locations extends AutoTest_Suite
{
  Collection of script functions testing locations (using cow, coc...) and making some camera run around the player.
  This helps in finding CTDs that can occur when visiting some places.
  Dependencies:
  * ConsoleUtil (https://www.nexusmods.com/skyrimspecialedition/mods/24858)
  * SKSE for StringUtil (https://skse.silverlock.org/)
}


; Declare some global variables to this script

; Current test index.
; This will be increased after every location test done.
int gIdxTest = 0

; Number of location tests to be passed before issuing a pcb (memory clear) command.
int gPCBInterval = 5


; Initialize the script
; [API] This function is mandatory and has to use SetTestType
function InitTests()
  SetTestType("Locations")
endFunction

; Register tests
; [API] This function is mandatory
function RegisterTests()
  RegisterTamrielCitiesCow()
  ; Those are max coordinates
  ; RegisterSurfaceCow("tamriel", 10, -57, 61, -43, 50)
  ; Use coordinates that are closer to the game area
  RegisterSurfaceCow("tamriel", 4000, -43, 44, -25, 25)
endFunction

; Prepare the runs of tests
; [API] This function is optional
function BeforeTestsRun()
  ConsoleUtil.ExecuteCommand("tgm")
  ConsoleUtil.ExecuteCommand("setini \"fAutoVanityIncrement:Camera\" 0.05")
  ConsoleUtil.ExecuteCommand("setini \"fDefaultAutoVanityZoom:Camera\" 5000")
  ConsoleUtil.ExecuteCommand("setini \"bForceAutoVanityMode:Camera\" 1")
endFunction

; Run a given registered test
; [API] This function is mandatory
;
; Parameters::
; * *testName* (string): The test name to run
function RunTest(string testName)
  string[] fields = StringUtil.Split(testName, "/")
  if fields.Length == 3
    ; This is an exterior cell
    TestCow(fields[0], fields[1] as int, fields[2] as int, 5.0)
  else
    ; This is an interior cell
    TestCoc(fields[0], 5.0)
  endIf
  SetTestStatus(testName, "ok")
endFunction

; Finalize the runs of tests
; [API] This function is optional
function AfterTestsRun()
  ConsoleUtil.ExecuteCommand("setini \"bForceAutoVanityMode:Camera\" 0")
  ConsoleUtil.ExecuteCommand("setini \"fDefaultAutoVanityZoom:Camera\" 300")
  ConsoleUtil.ExecuteCommand("setini \"fAutoVanityIncrement:Camera\" 0.01")
  ConsoleUtil.ExecuteCommand("tgm")
endFunction

; Register a new test for a single cell coordinate
;
; Parameters::
; * *world* (string): The name of the worldspace
; * *cellX* (int): The X cell coordinate
; * *cellY* (int): The Y cell coordinate
function RegisterTestCow(string world, int cellX, int cellY)
  RegisterNewTest(world + "/" + cellX + "/" + cellY)
endFunction

; Test a single cell coordinate
;
; Parameters::
; * *world* (string): The name of the worldspace
; * *cellX* (int): The X cell coordinate
; * *cellY* (int): The Y cell coordinate
; * *waitSecsPerTest* (float): The number of seconds to wait per each cow
function TestCow(string world, int cellX, int cellY, float waitSecsPerTest)
  string locationId = world + " " + cellX + ", " + cellY
  Log("[ Start ] - Testing location " + locationId)
  ConsoleUtil.ExecuteCommand("cow " + locationId)
  Utility.Wait(waitSecsPerTest)
  ; Try PCB to avoid CTDs after several cocs/cows
  if (gIdxTest % gPCBInterval) == 0
    Log("Clean memory with PCB")
    ConsoleUtil.ExecuteCommand("pcb")
  endIf
  Log("[ OK ] - Testing location " + locationId)
  gIdxTest += 1
endFunction

; Test an internal cell
;
; Parameters::
; * *cellName* (string): The name of the cell
; * *waitSecsPerTest* (float): The number of seconds to wait per each cow
function TestCoc(string cellName, float waitSecsPerTest)
  Log("[ Start ] - Testing cell " + cellName)
  ConsoleUtil.ExecuteCommand("coc " + cellName)
  Utility.Wait(waitSecsPerTest)
  ; Try PCB to avoid CTDs after several cocs/cows
  if (gIdxTest % gPCBInterval) == 0
    Log("Clean memory with PCB")
    ConsoleUtil.ExecuteCommand("pcb")
  endIf
  Log("[ OK ] - Testing cell " + cellName)
  gIdxTest += 1
endFunction

; Register Center-On-World tests on every cell doing a rectangle in a sorted way, with cells being spaced by a given multiplier.
; Always start from the first cell right of the the top-right cell, and follow a clock-wise direction until ending on the top-right cell.
; Make sure we don't test cells outside of the allowed range
; For example, here is the sequence (indicated with #nn) of cow commands executed for:
; * A distance of 2 from the center
; * Multipliers X, Y being 2, 2
; (-4,-4)#15 (-3,-4)    (-2,-4)#00 (-1,-4)    ( 0,-4)#01 ( 1,-4)    ( 2,-4)#02 ( 3,-4)    ( 4,-4)#03
; (-4,-3)    (-3,-3)    (-2,-3)    (-1,-3)    ( 0,-3)    ( 1,-3)    ( 2,-3)    ( 3,-3)    ( 4,-3)
; (-4,-2)#14 (-3,-2)    (-2,-2)    (-1,-2)    ( 0,-2)    ( 1,-2)    ( 2,-2)    ( 3,-2)    ( 4,-2)#04
; (-4,-1)    (-3,-1)    (-2,-1)    (-1,-1)    ( 0,-1)    ( 1,-1)    ( 2,-1)    ( 3,-1)    ( 4,-1)
; (-4, 0)#13 (-3, 0)    (-2, 0)    (-1, 0)    ( 0, 0)    ( 1, 0)    ( 2, 0)    ( 3, 0)    ( 4, 0)#05
; (-4, 1)    (-3, 1)    (-2, 1)    (-1, 1)    ( 0, 1)    ( 1, 1)    ( 2, 1)    ( 3, 1)    ( 4, 1)
; (-4, 2)#12 (-3, 2)    (-2, 2)    (-1, 2)    ( 0, 2)    ( 1, 2)    ( 2, 2)    ( 3, 2)    ( 4, 2)#06
; (-4, 3)    (-3, 3)    (-2, 3)    (-1, 3)    ( 0, 3)    ( 1, 3)    ( 2, 3)    ( 3, 3)    ( 4, 3)
; (-4, 4)#11 (-3, 4)    (-2, 4)#10 (-1, 4)    ( 0, 4)#09 ( 1, 4)    ( 2, 4)#08 ( 3, 4)    ( 4, 4)#07
; We see the distance between each selected cell is 2, and also the distance from the center (0, 0) is 2x2 = 4 cells.
;
; Parameters:
; * *world* (string): The name of the worldspace
; * *distanceFromCenter* (int): The distance from center
; * *multiplierX* (int): The X multiplier
; * *multiplierY* (int): The Y multiplier
; * *minX* (int): Minimum X cell
; * *maxX* (int): Maximum X cell
; * *minY* (int): Minimum Y cell
; * *maxY* (int): Maximum Y cell
function RegisterRectangleCow(string world, int distanceFromCenter, int multiplierX, int multiplierY, int minX, int maxX, int minY, int maxY)
  int nbrCellsPerEdge = distanceFromCenter * 2
  ; To not use arrays (as they are limited to 128 items), use 4 loops, 1 per edge

  ; 1 - Top edge
  int cellY = -distanceFromCenter * multiplierY
  if cellY >= minY && cellY <= maxY
    int idxCell = 0
    while idxCell < nbrCellsPerEdge
      int cellX = (idxCell - distanceFromCenter + 1) * multiplierX
      if cellX >= minX && cellX <= maxX
        RegisterTestCow(world, cellX, cellY)
      endIf
      idxCell += 1
    endWhile
  endIf

  ; 2 - Right edge
  int cellX = distanceFromCenter * multiplierX
  if cellX >= minX && cellX <= maxX
    int idxCell = 0
    while idxCell < nbrCellsPerEdge
      cellY = (idxCell - distanceFromCenter + 1) * multiplierY
      if cellY >= minY && cellY <= maxY
        RegisterTestCow(world, cellX, cellY)
      endIf
      idxCell += 1
    endWhile
  endIf

  ; 3 - Bottom edge
  cellY = distanceFromCenter * multiplierY
  if cellY >= minY && cellY <= maxY
    int idxCell = 0
    while idxCell < nbrCellsPerEdge
      cellX = (distanceFromCenter - idxCell - 1) * multiplierX
      if cellX >= minX && cellX <= maxX
        RegisterTestCow(world, cellX, cellY)
      endIf
      idxCell += 1
    endWhile
  endIf

  ; 4 - Left edge
  cellX = -distanceFromCenter * multiplierX
  if cellX >= minX && cellX <= maxX
    int idxCell = 0
    while idxCell < nbrCellsPerEdge
      cellY = (distanceFromCenter - idxCell - 1) * multiplierY
      if cellY >= minY && cellY <= maxY
        RegisterTestCow(world, cellX, cellY)
      endIf
      idxCell += 1
    endWhile
  endIf

endFunction

; Register Center-On-World tests on every cell inside a sqaure in a sorted way, starting from the center and making a spiral.
; Make sure the number of tested cells is maximum but under a given limit.
; As an illustration, here is the order that should be done to minimize loading times for a map of 5x5 locations (order given as #nn)
; (-2,-2)#24 (-1,-2)#09 ( 0,-2)#10 ( 1,-2)#11 ( 2,-2)#12
; (-2,-1)#23 (-1,-1)#08 ( 0,-1)#01 ( 1,-1)#02 ( 2,-1)#13
; (-2, 0)#22 (-1, 0)#07 ( 0, 0)#00 ( 1, 0)#03 ( 2, 0)#14
; (-2, 1)#21 (-1, 1)#06 ( 0, 1)#05 ( 1, 1)#04 ( 2, 1)#15
; (-2, 2)#20 (-1, 2)#19 ( 0, 2)#18 ( 1, 2)#17 ( 2, 2)#16
;
; Parameters:
; * *world* (string): The name of the worldspace
; * *nbrTestsMax* (int): Number of test cells maximum
; * *minX* (int): Minimum X cell
; * *maxX* (int): Maximum X cell
; * *minY* (int): Minimum Y cell
; * *maxY* (int): Maximum Y cell
function RegisterSurfaceCow(string world, int nbrTestsMax, int minX, int maxX, int minY, int maxY)
  ; Compute the resolution by using a multiplier: 1 means every cell, 2 means every 2 cells, etc...
  ; The resolution is computed to match the heighest value it can have, but making sure that the total number of tests stay below nbrTestsMax
  ; The cells are tested starting from the center (0, 0)
  ; Count the number of X that would be tested starting from 0
  int multiplierX = 1
  int multiplierY = 1
  while (Math.Ceiling((maxY + 1) / (multiplierY as float)) + Math.Ceiling((-minY + 1) / (multiplierY as float)) - 1) * (Math.Ceiling((maxX + 1) / (multiplierX as float)) + Math.Ceiling((-minX + 1) / (multiplierX as float)) - 1) > nbrTestsMax
    multiplierY += 1
    multiplierX += 1
  endWhile
  ; As uGridsToLoad is 5, there is no point in having multipliers smaller than 5: grids will always be loaded around
  ; TODO: Find a way to get the real value instead of hardcoding 5.
  if multiplierX < 5
    multiplierX = 5
  endIf
  if multiplierY < 5
    multiplierY = 5
  endIf
  Log("[ SurfaceCow ] - Resolution multiplier X: " + multiplierX)
  Log("[ SurfaceCow ] - Resolution multiplier Y: " + multiplierY)
  int nbrTestsTotal = (Math.Ceiling((maxY + 1) / (multiplierY as float)) + Math.Ceiling((-minY + 1) / (multiplierY as float)) - 1) * (Math.Ceiling((maxX + 1) / (multiplierX as float)) + Math.Ceiling((-minX + 1) / (multiplierX as float)) - 1)
  Log("[ SurfaceCow ] - Total number of tests: " + nbrTestsTotal)

  RegisterTestCow(world, 0, 0)
  int distanceFromCenter = 1
  while distanceFromCenter * multiplierX <= maxX || -distanceFromCenter * multiplierX >= minX || distanceFromCenter * multiplierY <= maxY || -distanceFromCenter * multiplierY >= minY
    RegisterRectangleCow(world, distanceFromCenter, multiplierX, multiplierY, minX, maxX, minY, maxY)
    distanceFromCenter += 1
  endWhile
endFunction

; Register Center-On-World tests on every Tamriel's city
function RegisterTamrielCitiesCow()
  ; Whiterun
  RegisterTestCow("tamriel", 4, -4)
  ; Dawnstar
  RegisterTestCow("tamriel", 8, 25)
  ; Solitude
  RegisterTestCow("tamriel", -15, 25)
  ; Markarth
  RegisterTestCow("tamriel", -42, 0)
  ; Morthal
  RegisterTestCow("tamriel", -10, 15)
  ; Falkreath
  RegisterTestCow("tamriel", -7, -21)
  ; Winterhold
  RegisterTestCow("tamriel", 27, 24)
  ; Windhelm
  RegisterTestCow("tamriel", 33, 7)
  ; Riften
  RegisterTestCow("tamriel", 42, -23)
  ; High Hrothgar
  RegisterTestCow("tamriel", 10, -10)
endFunction
