#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE teams, games")

cat games.csv | while IFS="," read -r year round winner opponent winner_goals opponent_goals
do
  # Skip either "winner" or "opponent"
  if [[ "$winner" != "winner" && "$opponent" != "opponent" ]]
  then
  # Add the team names and if they're the same do nothing so we don't have duplicates
  $PSQL "INSERT INTO teams(name) VALUES('$winner'), ('$opponent') ON CONFLICT (name) DO NOTHING;"
  fi
done

# Function to get the team ID from the teams table based on the team name
get_team_id() {
    team_name="$1"
    $PSQL "SELECT team_id FROM teams WHERE name = '$team_name';"  
}

cat games.csv | while IFS="," read -r year round winner opponent winner_goals opponent_goals
do
  winner_id=$(get_team_id "$winner")
  opponent_id=$(get_team_id "$opponent")
  # Skip the header
  if [[ "$year" != "year" && "$round" != "round" && "$winner" != "winner" && "$opponent" != "opponent" && "$winner_goals" != "winner_goals" && "$opponent_goals" != "opponent_goals" ]]
  then
  # Add the values into the games table
  $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($year, '$round', $winner_id, $opponent_id, $winner_goals, $opponent_goals);"
  fi
done
