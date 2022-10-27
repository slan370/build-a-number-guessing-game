#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

NEW_BEST_GAME=0
OLD_BEST_GAME=0
NUMBER_OF_GUESSES=0

echo -e "\n~~~~~ Number Guessing Game ~~~~~\n"
echo "Enter your username:"
read USERNAME

USER_INFO=$($PSQL "SELECT games_played,best_game FROM number_guess WHERE username='$USERNAME'")
# if first time
if [[ -z $USER_INFO ]]
then
  # create username
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO number_guess VALUES('$USERNAME', 0, 0)")
else
  # display user record
  echo "$USER_INFO" | while read GAMES_PLAYED BAR BEST_GAME
  do
    #Welcome back message
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi
SECRET_NUMBER=$(( $RANDOM %1000 +1 ))

MAIN() {
  NUMBER_OF_GUESSES=$(( NUMBER_OF_GUESSES + 1 ))
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  read GUESS_NUMBER
  if [[ ! $GUESS_NUMBER =~ ^[0-9]+$ ]]
  then
    # send to main menu
    MAIN "That is not an integer, guess again:"
  fi
  if [[ $GUESS_NUMBER -gt $SECRET_NUMBER ]]
  then
    MAIN "It's lower than that, guess again:"
  else
    if [[ $GUESS_NUMBER -lt $SECRET_NUMBER ]]
    then
      MAIN "It's higher than that, guess again:"
    else
      echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
      OLD_BEST_GAME=$($PSQL "SELECT best_game FROM number_guess WHERE username='$USERNAME'")
      if [[ $OLD_BEST_GAME -eq 0 ]]
      then
        NEW_BEST_GAME=$NUMBER_OF_GUESSES
      else
        if [[ $NUMBER_OF_GUESSES -le $OLD_BEST_GAME ]]
        then
          NEW_BEST_GAME=$NUMBER_OF_GUESSES
        else
          NEW_BEST_GAME=$OLD_BEST_GAME
        fi
      fi
      UPDATE_USER_RESULT=$($PSQL "UPDATE number_guess set games_played=games_played+1, best_game=$NEW_BEST_GAME WHERE username='$USERNAME'")
    fi
  fi
}

MAIN "Guess the secret number between 1 and 1000:"
