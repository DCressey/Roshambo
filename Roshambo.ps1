<#	Script: Roshambo    Rev: 2.1
	Author: DGC         Date: 3-15-17

This script plays scissors, rock, and paper.  It guesses
the player's next move based on history, and an adaptive 
strategy known as exponential averaging.  The last 50 moves
are kept , and an exponential average (between -1 and 1)
is kept about how often this historical move has predicted
the next move.

This version has worked out the mechanics of running the game,
and has a very primitive strategy. 
#>


#  Announcement

@' 

      Welcome to Scissors, Rock, and Paper!
Do you want to play the game?

'@
if (Ask-User "Enter Yes or No") {"OK"} else {Exit}

@'

   When you are asked to enter your move,
   enter S, R, P, or Q
   Q indicates that you want to quit, and is not a move.

'@


#   Set up global variables here

$SCISSORS = 0
$ROCK     = 1
$PAPER    = 2
$QUIT     = 3
$CHAR = @("SCISSORS", "ROCK    ", "PAPER   ")

$beats = @(0) * 3
$beats[$SCISSORS] = $ROCK
$beats[$ROCK]     = $PAPER
$beats[$PAPER]    = $SCISSORS

$LOSS = 0
$TIE  = 1
$WIN  = 2
$Upshot = @("You Lost.", "We Tied", "You won")

$wins = 0
$ties = 0
$losses = 0
$games = 0

$ALPHA = 0.1     # This is the learning rate  closer to 1 is faster

$history = @(0) * 50
0..49 |  % {$history[$_] = $SCISSORS, $ROCK, $PAPER | Get-Random}
$cred = @(0.01)  * 50


# Determine which of two moves wins

function CompareMoves ($move, $othermove)  {
    if ($move -eq $beats[$othermove]) {$WIN}
    elseif ($move -eq $othermove) {$TIE}
    else {$LOSS}
}


#  Use history to predict opponent's move

function GetComputerMove ()  {
#    return $SCISSORS, $ROCK, $PAPER | Get-Random
# The preceeding is a dummy, until the adaptive move selection is debugged
    
    $pred = @(0.0) * 3
    0..49 | % {$pred[$history[$_]] +=  $cred[$_]}
    if (($pred[$SCISSORS] -gt $pred[$ROCK]) -and 
        ($pred[$SCISSORS] -gt $pred[$PAPER]))  {$beats[$SCISSORS]}
    elseif ($pred[$ROCK] -gt $pred[$PAPER]) {$beats[$ROCK]}
    else {$beats[$PAPER]}
}

#  Interact with user to get user move

function GetUserMove () {
    $ANSWER = Read-Host "Your Move"
    if ($ANSWER -match "S") {$SCISSORS}
    elseif ($ANSWER -match "R") {$ROCK}
    elseif ($ANSWER -match "P") {$PAPER}
    elseif ($ANSWER -match "Q") {$QUIT}
    else {GetUserMove}
}


#  Here is where the adaptation processing is done.  
#  The adaptation is a variant of exponential averaging.
#  $cred ranges from -1 to 1.  -1 means the value always leads to
#  a loss and 1 means always leads to a win.  Ties don't affect cred.

function Learn ($actual) {
    0..49 |  % {
        $val = (CompareMoves  $beats[$history[$_]]  $actual) - 1
        if ($_ -ge $games)  { $val = 0}    # don't learn from prehistory
        $cred[$_] += $ALPHA * $val * ( 1 - $val*$cred[$_])
        }
    48..0 | % { $history[$_ + 1] = $history[$_]}
    $history[0] = $actual
    }



#  Main processing loop starts here.


do {
$ComputerMove = GetComputerMove
$UserMove = GetUserMove
if ($Usermove -eq $QUIT) { $playing = $false}
    else {
        $playing = $true
        $outcome =  CompareMoves $UserMove $computerMove
        "                    " +
            "You:  " + $CHAR[$UserMove] + 
            "  Me:   " + $CHAR[$ComputerMove] +
            "      " + $upshot[$outcome]
        Learn $UserMove

        $x =Switch ($Outcome) {
            $LOSS  {$losses++}
            $TIE   {$ties++}
            $WIN   {$wins++}
            }
        $games++
        }
    
} while ($playing)


@"

                    Final Tally.

                    Wins:  $wins   Losses: $losses
                    Ties:  $ties   Games:  $games

"@

$history | ft > history.txt
$cred | ft > cred.txt






    

