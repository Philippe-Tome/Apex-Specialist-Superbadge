public without sharing class MaintenanceRequestHelper {

    public static void createNewMaintenanceRequest(Set<Id> caseIds) {

        List<Case> cases = ([
            SELECT 
                Id, Type, Date_Due__c, Status, Subject, Description, ClosedDate, Vehicle__c, Origin, 
                (
                    SELECT 
                        Id, Name, Equipment__c, Quantity__c, Equipment__r.Maintenance_Cycle__c 
                    FROM 
                        Equipment_Maintenance_Items__r 
                    ORDER BY 
                        Equipment__r.Maintenance_Cycle__c
                ) 
            FROM 
                Case
            WHERE
                Id IN :caseIds
        ]);

        List<Case> casesToInsert = new List<Case>();
        List<Equipment_Maintenance_Item__c> equipmentMaintenanceItemsToInsert = new List<Equipment_Maintenance_Item__c>();
        Map<Id, Case> newCasesByOriginalCaseId = new Map<Id, Case>();

        for (Case cs : cases) {
            List<Equipment_Maintenance_Item__c> equipmentItems = cs.Equipment_Maintenance_Items__r;
            Integer shortestMaintenanceCycle = (Integer) equipmentItems[0].Equipment__r.Maintenance_Cycle__c;
            Id vehicle = cs.Vehicle__c;

            Date today = System.today();
            Date dueDate = today + shortestMaintenanceCycle;

            Case newCase = new Case(
                Type = 'Routine Maintenance',
                Status = 'New',
                Vehicle__c = vehicle,
                Subject = 'New Routine Maintenance Request for ' + vehicle,
                Date_Reported__c = today,
                Date_Due__c = dueDate,
                Origin = cs.Origin ?? 'Web' 
            );

            casesToInsert.add(newCase);
            newCasesByOriginalCaseId.put(cs.Id, newCase);
        }

        if (casesToInsert.size() > 0) {
            insert casesToInsert;
        }

        for (Case cs : cases) {
            Case newCase = newCasesByOriginalCaseId.get(cs.Id);
            List<Equipment_Maintenance_Item__c> equipmentItems = cs.Equipment_Maintenance_Items__r;

            for (Equipment_Maintenance_Item__c equipmentItem : equipmentItems) {
                Equipment_Maintenance_Item__c newEquipmentItem = new Equipment_Maintenance_Item__c(
                    Quantity__c = equipmentItem.Quantity__c,
                    Maintenance_Request__c = newCase.Id,
                    Equipment__c = equipmentItem.Equipment__c
                );

                equipmentMaintenanceItemsToInsert.add(newEquipmentItem);
            }
        }

        if (equipmentMaintenanceItemsToInsert.size() > 0) {
            insert equipmentMaintenanceItemsToInsert;
        }
    }
}
