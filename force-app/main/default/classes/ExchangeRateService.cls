/**
 * @description Service class that handles API callouts to the Exchange Rate API
 * Students will implement the methods to make callouts and process responses
 */
public class ExchangeRateService {
    
    // The named credential to use for the callout
    private static final String NAMED_CREDENTIAL = 'ExchangeRate_API';
    
    // The base currency to use for exchange rates
    private static final String BASE_CURRENCY = 'USD';
    
    /**
     * @description Makes a callout to the Exchange Rate API to get the latest exchange rates
     * @return ExchangeRateWrapper containing the response data
     */
    public static  ExchangeRateWrapper getLatestRates() {
        // TODO: Implement the method to make a callout to the Exchange Rate API

        ExchangeRateWrapper rateData = new ExchangeRateWrapper();
        String response = '';
        try{
            // Make the callout using the named credential
            // Use the sendRequest helper method to make the callout
            // Parse the response and populate the ExchangeRateWrapper
              response = sendRequest('callout:' + NAMED_CREDENTIAL + '/latest/' + BASE_CURRENCY, 'GET', null);      
      
             
            if (response != 'null' && response != '') {
                rateData = ExchangeRateWrapper.parse(response);
            } else {
                System.debug('Error response from Exchange Rate API: ' + response);
            }

              } catch (Exception e) {
              System.debug('Exception during callout: ' + e.getMessage());
                throw new CalloutException('Error during callout: ' + e.getMessage());          
           
        }
       
        return rateData;       
    }


    // Helper method to send HTTP requests  
    /**
     * @description Sends an HTTP request and returns the response body
     * @param endpoint The endpoint URL
     * @param method The HTTP method (GET, POST, etc.)
     * @param body The request body (for POST requests)
     * @return the response body as a string, or null if there was an error
     */
    private static String sendRequest(
        String endpoint,
        String method,
        String body
    )  {

        try{

        Http http = new Http();
        HttpRequest request = new HttpRequest();

        request.setEndpoint(endpoint);
        request.setMethod(method);
                   
        if (body != null) request.setBody(body);   

         HttpResponse response;


		try {
				response = http.send(request);
				} catch (CalloutException e) {
				// Handle any exceptions that occur during the callout.
				System.debug('Callout error: ' + e.getMessage());
				return '';
			}

		if (response.getStatusCode() < 200 || response.getStatusCode() >= 300) {
			// Handle non-successful HTTP response codes.
			System.debug('Callout failed with status code: ' + response.getStatusCode());
			System.debug('Callout failed with status : ' + response.getStatus());
			return '';
		}
			
		
		// Return the response body.
       return response.getBody();

    }	catch(Exception e){
		System.debug('Error in sendRequest: ' + e.getMessage());
		return '';

    }


	}


    
    /**
     * @description Processes the exchange rate data and creates or updates records
     * @param rateData The wrapper containing exchange rate data
     * @return List<Exchange_Rate__c> The list of records created or updated
     */
    public static List<Exchange_Rate__c> processRates(ExchangeRateWrapper rateData) {
        // TODO: Implement the method to process rates and create/update records
        List<Exchange_Rate__c> records = new List<Exchange_Rate__c>();
            if (rateData != null) {
                records = rateData.toExchangeRates();
                System.debug('Prepared ' + records.size() + ' exchange rate records for upsert.');
                if (!records.isEmpty()) {
                    try {
                        upsert records External_Id__c;
                    } catch (DmlException e) {
                        System.debug('Error upserting records: ' + e.getMessage());
                    }
                } else {
                    System.debug('No exchange rate records to upsert.');
                }
            }

        return records;
    }
    
    /**
     * @description Combines getting and processing rates into a single operation
     * @return List<Exchange_Rate__c> The list of records created or updated
     */
    public static List<Exchange_Rate__c> updateExchangeRates() {
        // TODO: Implement the method to get and process rates
        // 1. Call getLatestRates to retrieve the data
        // 2. Call processRates to create/update records
        // 3. Return the processed records
    List<Exchange_Rate__c> records = new List<Exchange_Rate__c>();
        ExchangeRateWrapper rateData = getLatestRates();
        if (rateData != null) {
            List<Exchange_Rate__c> existingRecord = [SELECT Id, External_Id__c, Last_Updated__c FROM Exchange_Rate__c  LIMIT 1];
            if (existingRecord.size() > 0) {
              if (existingRecord[0].Last_Updated__c != null && rateData.time_last_update_unix != null) {
                 Datetime rateDataLastUpdated = ExchangeRateWrapper.convertUnixToDatetime(rateData.time_last_update_unix);           
                 if (rateDataLastUpdated <= existingRecord[0].Last_Updated__c) {
                    System.debug('No new updates available. Existing data is up-to-date.');
                    return records; // Return empty list as no updates are needed
                }
              } 
            }
           records = processRates(rateData);
            System.debug('Processed ' + records.size());
        } else {
            System.debug('No rate data to process.');
        }
       
        return records;
    }





}