#!/bin/bash
# Get and parse RATP APIv3 -- https://github.com/pgrimaud/horaires-ratp-api
# Parsing/filtering output with https://stedolan.github.io/jq/
# Live test at https://jqplay.org/

# E.g.
#curl https://api-ratp.pierre-grimaud.fr/v3/schedules/bus/47/convention+++fontainebleau/R 2>/dev/null
#{
#    "result": {
#        "schedules": [
#            {
#                "message": "22 mn",
#                "destination": "Gare de l'Est"
#            },
#            {
#                "message": "42 mn",
#                "destination": "Gare de l'Est"
#            }
#        ]
#    },
#    "_metadata": {
#        "call": "GET /schedules/bus/47/convention+++fontainebleau/R",
#        "date": "2018-03-24T22:37:57+01:00",
#        "version": 3
#    }

#curl https://api-ratp.pierre-grimaud.fr/v3/schedules/bus/47/convention+++fontainebleau/R 2>/dev/null | jq '.result.schedules[0:2]  | .[0].message,.[0].destination,.[1].message,.[1].destination'
#"29 mn"
#"Gare de l'Est"
#"49 mn"
#"Gare de l'Est"


function get_and_parse()
{
        curl "$1" 2> /dev/null | jq '.result.schedules[0:2]  | .[0].message,.[0].destination,.[1].message,.[1].destination'
}

## Bus line 47
echo "Bus 47 - Station Convention Fontainebleau"
get_and_parse "https://api-ratp.pierre-grimaud.fr/v3/schedules/bus/47/convention+++fontainebleau/R"
#date
#echo ""

## Metro line 7
echo "Metro 7 - Station Kremlin-Bicetre"
get_and_parse "https://api-ratp.pierre-grimaud.fr/v3/schedules/metros/7/le+kremlin+bicetre/R"
#date
echo ""
date

sleep 10

