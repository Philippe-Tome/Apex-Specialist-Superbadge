@isTest
public without sharing class MaintenanceRequestHelperTest {

    @testSetup
    public static void makeData() {
        List<Case> testCases = new List<Case>();

        for (Integer i = 0; i < 300; i++) {
            Case newCase = new Case();
            newCase.Status = 'New';
            newCase.Origin = 'Web';
            newCase.Type = 'Repair';
            newCase.Subject = 'testCases #' + i;
            newCase.Date_Due__c = Date.today();
            newCase.Date_Reported__c = Date.today();
            newCase.Vehicle__c = 'a02WU00000DJzwOYAT';
            testCases.add(newCase);
        }
        
        insert testCases;

        // Creates Equipment records and attach them to the new cases
        List<Equipment_Maintenance_Item__c> items = new List<Equipment_Maintenance_Item__c>();

        for (Case testCase : testCases) {
            Equipment_Maintenance_Item__c item = new Equipment_Maintenance_Item__c();
            item.Maintenance_Request__c = testCase.Id;
            item.Equipment__c = '01tWU00000GpKoNYAV';
            item.Quantity__c = 1;

            items.add(item);
        }

        insert items;

        // Close the cases
        for (Case cs : testCases) {
            cs.Status = 'Closed';
        }

        update testCases;
    }

    @isTest
    public static void testMaintenanceRequestPositive() {
        List<Case> closedTestCases = [SELECT Id, Type, Status, Vehicle__c, Subject, Date_Reported__c, Date_Due__c, (SELECT Id FROM Equipment_Maintenance_Items__r) FROM Case WHERE Status = 'Closed'];

        List<Equipment_Maintenance_Item__c> closedMaintenanceEquipment = new List<Equipment_Maintenance_Item__c>();
        for (Case cs : closedTestCases) {
            closedMaintenanceEquipment.add(cs.Equipment_Maintenance_Items__r);
        }

        List<Case> newTestCases = [SELECT Id, Type, Status, Vehicle__c, Subject, Date_Reported__c, Date_Due__c, (SELECT Id FROM Equipment_Maintenance_Items__r) FROM Case WHERE Status = 'New'];

        List<Equipment_Maintenance_Item__c> newMaintenanceEquipment = new List<Equipment_Maintenance_Item__c>();
        for (Case newCs : newTestCases) {
            newMaintenanceEquipment.add(newCs.Equipment_Maintenance_Items__r);
        
        }

        System.Assert.areEqual(300, closedTestCases.size());
        System.Assert.areEqual(300, closedMaintenanceEquipment.size());
        System.Assert.areEqual(300, newTestCases.size());
        System.Assert.areEqual(300, newMaintenanceEquipment.size());

    }

    @isTest
    public static void testMaintenanceRequestNegative() {
        Case newRoutineMaintenanceCase = new Case(
            Status = 'New',
            Origin = 'Web',
            Type = 'Mechanical',
            Subject = 'New Routine Mechanical Maintenance Request For ...',
            Date_Due__c = Date.today(),
            Date_Reported__c = Date.today(),
            Vehicle__c = 'a02WU00000DJzwOYAT'
        );

        insert newRoutineMaintenanceCase;

        newRoutineMaintenanceCase.Status = 'Closed';

        update newRoutineMaintenanceCase;

        List<Case> cases = [SELECT Id, Type FROM Case WHERE Status = 'New' AND Type = 'Mechanical'];
        
        System.Assert.areEqual(0, cases.size());

    }

}