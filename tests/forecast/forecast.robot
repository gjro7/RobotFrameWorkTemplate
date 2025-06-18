*** Settings ***
Library           RequestsLibrary
Library           JSONLibrary
Library           BuiltIn
Library           Collections
Resource          ../../utils/utils.resource

Suite Setup       Suite Setup
Suite Teardown    Delete All Sessions

*** Variables ***
${day}    

*** Keywords ***
5 Day of Forecast Weather
    Set Test Variable    ${day}    5day
    ${resp}=    GET On Session    default_session    url=${forecast_endpoint}/${day}/${location_key}    params=&{params}

   RETURN   ${resp.json()}

*** Test Cases ***
Get 5 Day of Forecast Weather and Return Minimum, Maximum, and Average Temperature
    ${response_5_day_of_forecast}=     5 Day Of Forecast Weather
    Calculate Minimum, Maximum and Average Temperatures     ${response_5_day_of_forecast}
