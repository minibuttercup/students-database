#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi
# Clear existing data in tables
echo $($PSQL "TRUNCATE TABLE games, teams RESTART IDENTITY")

# Read the CSV file and insert data
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Skip the header line
  if [[ $YEAR != "year" ]]
  then
    # Insert teams into the teams table if not already present
    for TEAM in "$WINNER" "$OPPONENT"
    do
      TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$TEAM'")
      
      # If the team is not found
      if [[ -z $TEAM_ID ]]
      then
        # Insert the team
        INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$TEAM')")
        if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
        then
          echo "Inserted into teams: $TEAM"
        fi
        # Get the new team ID
        TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$TEAM'")
      fi
    done

    # Get the team IDs for the winner and opponent
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # Insert the game into the games table
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
    then
      echo "Inserted into games: $YEAR $ROUND $WINNER vs $OPPONENT"
    fi
  fi
done
# Do not change code above this line. Use the PSQL variable above to query your database.
