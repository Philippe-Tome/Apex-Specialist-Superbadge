@isTest
public with sharing class WarehouseCalloutServiceTest {
    @isTest
    static void testCallout() {
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());

        WarehouseCalloutService service = new WarehouseCalloutService();

        Test.startTest();
        service.execute(null);
        Test.stopTest();

        List<Product2> products = [SELECT Id FROM Product2];

        System.assertEquals(22, products.size());

    }
}