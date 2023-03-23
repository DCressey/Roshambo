# Roshambo
Roshambo is a game that is better known as Scissors, Rock, Paper.  It's a guessing game for children where each plyer is trying to outguess the other.  On the count of three, both players shoot one of three symbols with their hand:  siccors, Rock, or Paper.  If they both shoot the same thing, there is no score.  Rock beats scissors, scissors beats paper, and paper beats rock.  

If one player can figure out a pattern in the orther player's play,  that can give an advantage.  The Roshambo script plays the game against a human player.  the human types in a mover as S, R, or P. The play repeats after each move, until the player enters Q instead of a move.

The strategy is basically to track the player's actions for the last 50 moves,  and to wieigh each prior move as an indicator of the next move.  Exponential averaging is used to remember how often the player repeats what was done, say, 33 moves in the past.  This strategy gives a moderately good game against many players.  But It doesn't beat many players.

