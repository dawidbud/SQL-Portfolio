#!/bin/bash

# Set PSQL variable
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Generate secret number between 1 and 1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

# Prompt for username
echo "Enter your username:"
read USERNAME
USERNAME=${USERNAME:0:22}

# Check if user exists
USER_INFO=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME'")

if [[ -n $USER_INFO ]]; then
  IFS='|' read GAMES_PLAYED BEST_GAME <<< "$USER_INFO"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
else
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  # Insert new user into the database
  $PSQL "INSERT INTO users(username) VALUES('$USERNAME')" >/dev/null 2>&1
fi

# Prompt to guess the secret number
echo "Guess the secret number between 1 and 1000:"
read GUESS
NUMBER_OF_GUESSES=1

# Loop until the user guesses the secret number
while [[ $GUESS != $SECRET_NUMBER ]]; do
  if ! [[ $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -gt $SECRET_NUMBER ]]; then
    echo "It's lower than that, guess again:"
  elif [[ $GUESS -lt $SECRET_NUMBER ]]; then
    echo "It's higher than that, guess again:"
  fi
  read GUESS
  ((NUMBER_OF_GUESSES++))
done

# Congratulate the user
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

# Update user statistics in the database without producing output
if [[ -n $USER_INFO ]]; then
  # Update games_played
  ((GAMES_PLAYED++))
  $PSQL "UPDATE users SET games_played=$GAMES_PLAYED WHERE username='$USERNAME'" >/dev/null 2>&1

  # Update best_game if necessary
  if [[ -z $BEST_GAME || $NUMBER_OF_GUESSES -lt $BEST_GAME ]]; then
    $PSQL "UPDATE users SET best_game=$NUMBER_OF_GUESSES WHERE username='$USERNAME'" >/dev/null 2>&1
  fi
else
  # First-time user
  $PSQL "UPDATE users SET games_played=1, best_game=$NUMBER_OF_GUESSES WHERE username='$USERNAME'" >/dev/null 2>&1
fi

# Script finishes running here without any extra output
