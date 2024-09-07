#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n\nWelcome to My Salon, how can I help you?\n"

DISPLAY_SERVICES() {
  echo "$1" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

SERVICES_RESULT=$($PSQL "SELECT * FROM services")

DISPLAY_SERVICES "$SERVICES_RESULT"

read SERVICE_ID_SELECTED

SERVICE_NAME_RESULT=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

while [[ -z $SERVICE_NAME_RESULT ]];
do
  echo -e "\nI could not find that service. What would you like today?"
  DISPLAY_SERVICES "$SERVICES_RESULT"
  read SERVICE_ID_SELECTED
  SERVICE_NAME_RESULT=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
done

echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

while [[ ! $CUSTOMER_PHONE =~ ^[1-9][0-9]{2}-[0-9]{3}-[0-9]{4}$ ]]
do
  echo "That is not a valid phone number. Please try again."
  read CUSTOMER_PHONE
done

CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

if [[ -z $CUSTOMER_NAME ]];
then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
fi

echo -e "\nWhat time would you like your $SERVICE_NAME_RESULT, $CUSTOMER_NAME?" | sed 's/  / /g'
read SERVICE_TIME

while [[ ! $SERVICE_TIME =~ ^([1-9]|1[0-2]):[0-5][0-9]$|^([1-9]|1[0-2])([ap]m)$ ]]
do
  echo -e "That doesn't look to be a valid time. Please try again."
  read SERVICE_TIME
done

CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
INSERT_SERVICE_TIME_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
echo -e "\nI have put you down for a $SERVICE_NAME_RESULT at $SERVICE_TIME, $CUSTOMER_NAME." | sed 's/  / /g'
