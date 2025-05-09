public with sharing class WarehouseCalloutService implements Queueable {

    @future(callout=true)
    public static void warehouseEquipmentSync() {
        final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();

        req.setEndpoint(WAREHOUSE_URL);
        req.setMethod('GET');
        HttpResponse res = http.send(req);

        List<Product2> products = new List<Product2>();

        if(res.getStatusCode() == 200) {
            List<Object> responses = (List<Object>) JSON.deserializeUntyped(res.getBody());

            for (Object response : responses) {
                Map<String, Object> equipment = (Map<String, Object>) response;
                Product2 newProduct = new Product2(
                    Replacement_Part__c = true,
                    Cost__c = (Integer) equipment.get('cost'),
                    Lifespan_Months__c = (Integer) equipment.get('lifespan'),
                    Maintenance_Cycle__c = (Integer) equipment.get('maintenanceperiod'),
                    Warehouse_SKU__c = (String) equipment.get('sku'),
                    Name = (String) equipment.get('name'),
                    ProductCode = (String) equipment.get('_id')
                );

                products.add(newProduct);
            }

            if(products.size() > 0) {
                upsert products Warehouse_SKU__c;
            }
        }
    }

    public static void execute(QueueableContext context) {
        warehouseEquipmentSync();
    }

}