/**
 * @description Wrapper class to deserialize the JSON response from the Exchange Rate API
 * Students will implement the properties and methods to process the data
 */
public class ExchangeRateWrapper {
    
 
    
    // Add properties for base currency
    public String base_code;
    
    // Add property for time last updated
    public String time_last_update_unix;
    
    // Add property for rates (using a map)
    public Map<String, Decimal> conversion_rates;

    // Add property for external ID
    // This is an ID you will generate to uniquely identify the exchange rate record
    // This does not come from the API response
    public String externalId; 
    //baseCurrency + '_' + targetCurrency
    
    /**
     * @description Converts the wrapper data to a list of Exchange_Rate__c records
     * @return List<Exchange_Rate__c> The list of exchange rate records
     */
    public List<Exchange_Rate__c> toExchangeRates() {
        // TODO: Implement the method to convert the wrapper data to Exchange_Rate__c records
        // 1. Create a list to hold the Exchange_Rate__c records
        // 2. Iterate through the rates map
        // 3. For each rate, create an Exchange_Rate__c record
        // 4. Return the list of records

        Datetime lastUpdated = convertUnixToDatetime(time_last_update_unix);

        List<Exchange_Rate__c> records = new List<Exchange_Rate__c>();
        for (String targetCurrency : conversion_rates.keySet()) {
            Decimal rate = conversion_rates.get(targetCurrency);
            Exchange_Rate__c record = new Exchange_Rate__c();
            record.Base_Currency__c = base_code;
            record.Target_Currency__c = targetCurrency;
            record.Rate__c = rate;
            record.External_Id__c = base_code + '_' + targetCurrency;
            record.Last_Updated__c = lastUpdated;
            records.add(record);
        }

        return records;
    }

    /**
     * @description Converts a Unix timestamp string to a Datetime in GMT
     * @param unixTimeStr The Unix timestamp as a string
     * @return Datetime The converted Datetime
     */
    public static Datetime convertUnixToDatetime(String unixTimeStr) {
        Long unixTime = Long.valueOf(unixTimeStr);
        Long unixTimeMilliseconds = unixTime * 1000;
        return Datetime.newInstance(unixTimeMilliseconds);
    }

   
    
    /**
     * @description Static method to parse the JSON response into the wrapper class
     * @param jsonResponse The JSON response from the API
     * @return ExchangeRateWrapper The parsed wrapper instance
     */
    public static ExchangeRateWrapper parse(String jsonResponse) {
        // TODO: Implement the method to parse the JSON response
        // Use JSON.deserialize or JSON.deserializeStrict to parse the response
    ExchangeRateWrapper exRate = null;
    try {
        exRate = (ExchangeRateWrapper) JSON.deserialize(jsonResponse, ExchangeRateWrapper.class);
        System.debug('Parsed ExchangeRateWrapper: ' + exRate);
    } catch (Exception e) {
        System.debug('Error parsing JSON response: ' + e.getMessage());
       
    }
       return exRate;
    }
}