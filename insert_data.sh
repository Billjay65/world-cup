#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database. 
echo $($PSQL "TRUNCATE games, teams")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # skip header
  if [[ $YEAR != year ]]
  then
    echo "Selected: $WINNER VS $OPPONENT"
    # get team_id of winner followed by opponent
    TEAM_ID_WINNER=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    TEAM_ID_OPPONENT=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # insert winner team
    # if not found
    if [[ -z $TEAM_ID_WINNER ]]
    then
      # insert winner
      INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")

      if [[ $INSERT_WINNER_RESULT == 'INSERT 0 1' ]]
      then
        echo "Inserted into teams, $WINNER"
      fi
    fi

    # insert opponent team
    # if not found
    if [[ -z $TEAM_ID_OPPONENT ]]
    then
      # insert winner
      INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")

      if [[ $INSERT_OPPONENT_RESULT == 'INSERT 0 1' ]]
      then
        echo "Inserted into teams, $OPPONENT"
      fi
    fi

    # insert games into game table
    # select winner_id from teams table
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    # select opponent_id from teams table
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    # insert game record
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")

    if [[ $INSERT_GAME_RESULT == 'INSERT 0 1' ]]
      then
        echo "Inserted into games, $YEAR , $WINNER, $OPPONENT"
    fi
  fi
done