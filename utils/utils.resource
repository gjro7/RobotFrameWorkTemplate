*** Settings ***
Library    RequestsLibrary
Library    JSONLibrary
Resource    ./endpoints.resource
Resource    ../configuration/configuration.resource

*** Keywords ***
Suite Setup
    Set Global Variable    ${default_url}
    
    &{params_dict}=    Create Dictionary    apikey=${api_key}
    Set Global Variable    &{params}    &{params_dict}
    
    Create Session    alias=default_session    url=${default_url}
    Location Key Generator

Location Key Generator
    ${random_number}=    Evaluate    random.sample(range(1, 150), 1)    random
    Choose random city    ${random_number}
    
Choose random city
    [Arguments]    ${random_number}
    ${random_city_resp}=    GET On Session    alias=default_session    url=${topcities_endpoint}/150     params=&{params}

    ${random_city_name}    Get Value From Json    ${random_city_resp.json()}    $${random_number}.LocalizedName
    Set Suite Variable    ${city}    ${random_city_name}[0]
    
    ${random_city_location}    Get Value From Json    ${random_city_resp.json()}    $${random_number}.Key
    Set Suite Variable    ${location_key}    ${random_city_location}[0]

Calculate Minimum, Maximum and Average Temperatures
    [Arguments]    ${response_body}

    @{min_list}=    Get Value From Json    ${response_body}    $.DailyForecasts.[*].Temperature.Minimum.Value
    @{max_list}     Get Value From Json    ${response_body}    $.DailyForecasts.[*].Temperature.Maximum.Value
    ${minimum_value_from_list}=    Get Minimum Value From List    @{min_list}
    ${maximum_value_from_list}=    Get Maximum Value From List    @{max_list}
    ${avg}=     Calculate Average Temperature    ${minimum_value_from_list}    ${maximum_value_from_list}

    Log To Console         ${EMPTY}
    Log To Console        This is the Forecast for the next ${day}s for the city: ${city}
    Log To Console        Minimum temperature: ${minimum_value_from_list} °F
    Log To Console        Maximum temperature: ${maximum_value_from_list} °F
    Log To Console        Average minimum temperature: ${avg} °F

Get Minimum Value From List
    [Arguments]    @{minimum_list}

    ${min}    Evaluate    min(${minimum_list})
    ${number_min}    Convert To Number    ${min}
    ${rounded_min}    Evaluate    "%.0f" % ${min}

    RETURN    ${number_min}

Get Maximum Value From List
    [Arguments]    @{maximum_list}

    ${max}    Evaluate    max(@{maximum_list})
    ${number_max}    Convert To Number  ${max}
    ${rounded_max}    Evaluate    "%.0f" % ${number_max}

    RETURN    ${number_max}

Calculate Average Temperature
    [Arguments]    ${min}    ${max}
    ${average_temperature}    Evaluate    sum([${min}, ${max}])/2

    RETURN    ${average_temperature}