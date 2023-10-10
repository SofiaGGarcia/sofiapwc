trigger CoinTrigger on Transaction__c (after insert, after update) {

    List<Transaction__c> updatedRecords = new List<Transaction__c>();
    
    for (Transaction__c myTransaction : Trigger.new) {

        Transaction__c previousTransaction = Trigger.oldMap.get(myTransaction.Id);
        if (previousTransaction == null ||
            myTransaction.Currency_Quantity__c != previousTransaction.Currency_Quantity__c ||
            myTransaction.Transaction_Type__c != previousTransaction.Transaction_Type__c) {
            updatedRecords.add(myTransaction);
        }
    }

    if (!updatedRecords.isEmpty()) {

        Map<String, String> cryptoApiIds = new Map<String, String>();


        for (Transaction__c myTransaction : updatedRecords) {
            cryptoApiIds.put(myTransaction.Id, myTransaction.Related_Cryptocurrency__c);
        }


        String apiIds = String.join(new List<String>(cryptoApiIds.values()), ',');

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.coingecko.com/api/v3/simple/price?ids=' + apiIds + '&vs_currencies=usd');
        request.setMethod('GET');
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            String responseBody = response.getBody();
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(responseBody);


            for (Transaction__c myTransaction : updatedRecords) {
                String apiId = cryptoApiIds.get(myTransaction.Id);
                if (results.containsKey(apiId)) {
                    Decimal valueInDollars = Decimal.valueOf(String.valueOf(results.get(apiId)));

                    
                    if (myTransaction.Transaction_Type__c == 'Buying') {
                        myTransaction.Dollar_value__c = myTransaction.Currency_Quantity__c * valueInDollars;
                    } else if (myTransaction.Transaction_Type__c == 'Selling') {

                    }
                }
            }

        
            update updatedRecords;
        } else {
            
            String errorMessage = 'Error al llamar a la API de CoinGecko. Código de estado: ' + response.getStatusCode();
            System.debug(errorMessage);
            
            
        }
    }
}