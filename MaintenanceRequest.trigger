trigger MaintenanceRequest on Case (after update) {
    Set<Id> caseIds = new Set<Id>();

    for (Case cs : Trigger.new) {
        if (
            cs.Status == 'Closed' 
            && Trigger.oldMap.get(cs.Id).Status != 'Closed' 
            && (
                cs.Type == 'Repair' 
                || cs.Type == 'Routine Maintenance'
            )
        ) {
            caseIds.add(cs.Id);    
        }
    }

    if (!caseIds.isEmpty()) {
        MaintenanceRequestHelper.createNewMaintenanceRequest(caseIds);
    }
}