#!/bin/bash

UA_BROWSER="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36"
UA_SEC_CH_UA='"Google Chrome";v="125", "Chromium";v="125", "Not.A/Brand";v="24"'

color_print() {
    Font_Red="\033[31m"
    Font_Green="\033[32m"
    Font_Yellow="\033[33m"
    Font_Suffix="\033[0m"
}

WebTest_OpenAI() {
    local proxy="$1"
    local curl_opts=""

    if [ -n "$proxy" ]; then
        curl_opts="--proxy $proxy"
    fi

    local tmpresult1=$(curl -s $curl_opts 'https://api.openai.com/compliance/cookie_requirements' -H 'authority: api.openai.com' -H 'accept: */*' -H 'accept-language: en-US,en;q=0.9' -H 'authorization: Bearer null' -H 'content-type: application/json' -H 'origin: https://platform.openai.com' -H 'referer: https://platform.openai.com/' -H "sec-ch-ua: ${UA_SEC_CH_UA}" -H 'sec-ch-ua-mobile: ?0' -H 'sec-ch-ua-platform: "Windows"' -H 'sec-fetch-dest: empty' -H 'sec-fetch-mode: cors' -H 'sec-fetch-site: same-site' --user-agent "${UA_BROWSER}")
    local tmpresult2=$(curl -s $curl_opts 'https://ios.chat.openai.com/' -H 'authority: ios.chat.openai.com' -H 'accept: */*;q=0.8,application/signed-exchange;v=b3;q=0.7' -H 'accept-language: en-US,en;q=0.9' -H "sec-ch-ua: ${UA_SEC_CH_UA}" -H 'sec-ch-ua-mobile: ?0' -H 'sec-ch-ua-platform: "Windows"' -H 'sec-fetch-dest: document' -H 'sec-fetch-mode: navigate' -H 'sec-fetch-site: none' -H 'sec-fetch-user: ?1' -H 'upgrade-insecure-requests: 1' --user-agent "${UA_BROWSER}")

    if [ -z "$tmpresult1" ]; then
        echo -e "ChatGPT:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}"
        return
    fi
    if [ -z "$tmpresult2" ]; then
        echo -e "ChatGPT:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}"
        return
    fi

    local result1=$(echo "$tmpresult1" | grep -i 'unsupported_country')
    local result2=$(echo "$tmpresult2" | grep -i 'VPN')
    if [ -z "$result2" ] && [ -z "$result1" ]; then
        echo -e "ChatGPT:\t\t\t\t${Font_Green}Yes${Font_Suffix}"
        return
    fi
    if [ -n "$result2" ] && [ -n "$result1" ]; then
        echo -e "ChatGPT:\t\t\t\t${Font_Red}No${Font_Suffix}"
        return
    fi
    if [ -z "$result1" ] && [ -n "$result2" ]; then
        echo -e "ChatGPT:\t\t\t\t${Font_Yellow}No (Only Available with Web Browser)${Font_Suffix}"
        return
    fi
    if [ -n "$result1" ] && [ -z "$result2" ]; then
        echo -e "ChatGPT:\t\t\t\t${Font_Yellow}No (Only Available with Mobile APP)${Font_Suffix}"
        return
    fi

    echo -e "ChatGPT:\t\t\t\t${Font_Red}Failed (Error: Unknown)${Font_Suffix}"
}

process() {
    local proxy=""
    while [ $# -gt 0 ]; do
        case "$1" in
        --proxy)
            proxy="$2"
            shift
            ;;
        *)
            echo -e "${Font_Red}Unknown option: $1${Font_Suffix}"
            exit 1
            ;;
        esac
        shift
    done

    WebTest_OpenAI "$proxy"
}

color_print
process "$@"