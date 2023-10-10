public with sharing class CryptocurrencyCreationService {
    public static void CreateCryptocurrencyRecords() {
        // Obtener el JSON de CoinGeckoService
        String jsonResponse = CoinGeckoService.GetCoinGeckoService();

        // Crear los registros de Cryptocurrency__c
        if (jsonResponse != null) {
            List<Object> idCoins = (List<Object>) JSON.deserializeUntyped(jsonResponse);
            
            Integer batchSize = 200; // Define el tamaño del lote
            
            // Dividir los registros en lotes más pequeños
            List<List<Cryptocurrency__c>> recordBatches = new List<List<Cryptocurrency__c>>();
            List<Cryptocurrency__c> batch = new List<Cryptocurrency__c>();

            for (Object coinDataObj : idCoins) {
                Map<String, Object> coinData = (Map<String, Object>) coinDataObj;
                
                String id = (String) coinData.get('id');
                String name = (String) coinData.get('name');

                if (id != null && name != null) {
                    Cryptocurrency__c cryptoRecord = new Cryptocurrency__c();
                    cryptoRecord.API_ID__c = id;
                    cryptoRecord.Name = name;

                    batch.add(cryptoRecord);
                }

                // Verificar el tamaño del lote
                if (batch.size() >= batchSize) {
                    recordBatches.add(batch);
                    batch = new List<Cryptocurrency__c>();
                }
            }

            // Agregar el último lote si no se agregó anteriormente
            if (batch.size() > 0) {
                recordBatches.add(batch);
            }

            // Insertar los registros en lotes más pequeños
            for (List<Cryptocurrency__c> records : recordBatches) {
                insert records;
                System.debug('Cantidad de registros insertados: ' + records.size());
            }
        }
    }
}