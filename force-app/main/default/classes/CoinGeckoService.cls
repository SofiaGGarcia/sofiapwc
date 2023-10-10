public with sharing class CoinGeckoService {
    @AuraEnabled
    public Static String GetCoinGeckoService() {
        HttpRequest req = new HttpRequest();
    req.setEndpoint('callout:CoinGeckoApiNamed/api/v3/coins/list');
    req.setMethod('GET');

    Http http = new Http();
    HTTPResponse res = http.send(req);
    return res.getBody();

    }
}