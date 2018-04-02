#!/bin/bash
# Get and parse RATP APIv3 -- https://github.com/pgrimaud/horaires-ratp-api
# Parsing/filtering output with https://stedolan.github.io/jq/
# Live test at https://jqplay.org/


function printTable(){
    local -r delimiter="${1}"
    local -r data="$(removeEmptyLines "${2}")"

    if [[ "${delimiter}" != '' && "$(isEmptyString "${data}")" = 'false' ]]
    then
        local -r numberOfLines="$(wc -l <<< "${data}")"

        if [[ "${numberOfLines}" -gt '0' ]]
        then
            local table=''
            local i=1

            for ((i = 1; i <= "${numberOfLines}"; i = i + 1))
            do
                local line=''
                line="$(sed "${i}q;d" <<< "${data}")"

                local numberOfColumns='0'
                numberOfColumns="$(awk -F "${delimiter}" '{print NF}' <<< "${line}")"

                # Add Line Delimiter

                if [[ "${i}" -eq '1' ]]
                then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi

                # Add Header Or Body

                table="${table}\n"

                local j=1

                for ((j = 1; j <= "${numberOfColumns}"; j = j + 1))
                do
                    table="${table}$(printf '#| %s' "$(cut -d "${delimiter}" -f "${j}" <<< "${line}")")"
                done

                table="${table}#|\n"

                # Add Line Delimiter

                if [[ "${i}" -eq '1' ]] || [[ "${numberOfLines}" -gt '1' && "${i}" -eq "${numberOfLines}" ]]
                then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi
            done

            # Add the '-' symbols
            if [[ "$(isEmptyString "${table}")" = 'false' ]]
            then
                echo -e "${table}" | column -s '#' -t | sed -r -e '/\ *\+.*/s/\ /-/g' -e 's/^[^\+]*\+/\ \ \+/'
            fi
        fi
    fi
}

function removeEmptyLines(){
    local -r content="${1}"

    echo -e "${content}" | sed '/^\s*$/d'
}

function repeatString(){
    local -r string="${1}"
    local -r numberToRepeat="${2}"

    if [[ "${string}" != '' && "${numberToRepeat}" =~ ^[1-9][0-9]*$ ]]
    then
        local -r result="$(printf "%${numberToRepeat}s")"
        echo -e "${result// /${string}}"
    fi
}

function isEmptyString(){
    local -r string="${1}"

    if [[ "$(trimString "${string}")" = '' ]]
    then
        echo 'true' && return 0
    fi

    echo 'false' && return 1
}

function trimString(){
    local -r string="${1}"

    sed 's,^[[:blank:]]*,,' <<< "${string}" | sed 's,[[:blank:]]*$,,'
}

function get_json()
{
    curl "$1" 2> /dev/null | jq '.result.schedules[0:2]'
}

function get_timecolumn(){
    local data_metro=$(get_json $url_metro)
    local data_bus=$(get_json $url_bus)

    
    title_bus="Bus 47 - Convention Fontainebleau"
    title_metro="Metro 7 - Kremlin-Bicetre"
    times_first=$(echo $data_metro $data_bus|jq '.[0].message'|tr -d '"'|tr '\n' ','|sed -r 's/(,[^,]*),$/\1/')
    times_second=$(echo $data_metro $data_bus|jq '.[1].message'|tr -d '"'|tr '\n' ','|sed -r 's/(,[^,]*),$/\1/')

    data_table="${title_metro},${title_bus}\n"
    data_table="${data_table}${times_first}\n${times_second}"

    printTable ',' "$data_table"
}

function get_and_parse()
{
    curl "$1" 2> /dev/null | jq '.result.schedules[0:2]  | .[0].message,.[0].destination,.[1].message,.[1].destination'
}

url_bus="https://api-ratp.pierre-grimaud.fr/v3/schedules/bus/47/convention+fontainebleau/R"
title_bus="Bus 47 - Convention Fontainebleau"
title_bus_italie="Bus 47 - Place d'Italie"

url_metro="https://api-ratp.pierre-grimaud.fr/v3/schedules/metros/7/le+kremlin+bicetre/R"
title_metro="Metro 7 - Kremlin-Bicetre"

## Bus line 47
data_bus=$(get_json $url_bus)
## Metro line 7
data_metro=$(get_json $url_metro)
#date
echo ""
echo "  "$(date)

get_timecolumn

sleep 10

