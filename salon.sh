#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --csv -t -A -c "

MAIN_MENU(){

if [[ $1 ]]
then
  echo -e "\n$1"
else
  echo -e "\n~~~~~ MY SALON ~~~~~\n"
  echo -e "Welcome to My Salon, how can I help you?\n"
fi

SERVICES_INFO=$($PSQL "SELECT service_id, name FROM services")
echo "$SERVICES_INFO" | while read SERVICE_ID_NAME
do
  echo $SERVICE_ID_NAME | sed 's/\([^|]*\)|\([^|]*\)/\1) \2/'
done

read SERVICE_ID_SELECTED

if [[ -z $SERVICE_ID_SELECTED || ! $SERVICE_ID_SELECTED =~ ^[0-5]+$ ]]
then
  MAIN_MENU "I could not find that service. What would you like today?"
else
  echo "What's your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    CREATE_CUSTOMER=$($PSQL "INSERT INTO customers(phone,name) VALUES ('$CUSTOMER_PHONE','$CUSTOMER_NAME')")

  fi

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name = '$CUSTOMER_NAME'")
  CREATE_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES ($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")

  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."

fi
}

MAIN_MENU