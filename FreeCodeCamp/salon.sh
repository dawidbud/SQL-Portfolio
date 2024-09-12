#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo -e "\n~~~ Welcome to the Salon! ~~~\n"

# Display available services
SERVICE_LIST=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

echo "$SERVICE_LIST" | while IFS="|" read SERVICE_ID SERVICE_NAME
do
  echo "$SERVICE_ID) $SERVICE_NAME"
done

# Get the service choice from the user
echo -e "\nWhich service would you like to book?"
read SERVICE_ID_SELECTED

# Check if the service exists
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

if [[ -z $SERVICE_NAME ]]
then
  # If service doesn't exist, show list again
  echo -e "\nThat service does not exist. Please choose a valid service."
  exec $0
else
  # Get the user's phone number
  echo -e "\nEnter your phone number:"
  read CUSTOMER_PHONE

  # Check if customer exists
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

  if [[ -z $CUSTOMER_NAME ]]
  then
    # If customer doesn't exist, get their name
    echo -e "\nIt looks like you're a new customer. What's your name?"
    read CUSTOMER_NAME
    # Insert new customer into the customers table
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi

  # Get the customer ID
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # Get the appointment time
  echo -e "\nWhat time would you like to schedule your $SERVICE_NAME?"
  read SERVICE_TIME

  # Insert the appointment into the appointments table
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  # Output confirmation message
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
fi

