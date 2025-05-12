@isTest
private class WarehouseSyncScheduleTest {

    static testMethod void testScheduler() {

        String cronExpr = '0 0 0 * * ?';
    
        Test.startTest();
        String jobId = System.schedule('testSchedulingLogic', cronExpr, new WarehouseSyncSchedule());
        Test.stopTest();

        CronTrigger ct = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime 
            FROM CronTrigger 
            WHERE Id = :jobId
        ];

        System.assertEquals(cronExpr, ct.CronExpression);
    }
}