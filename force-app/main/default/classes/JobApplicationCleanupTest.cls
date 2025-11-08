@isTest
public with sharing class JobApplicationCleanupTest {

    @testSetup
    static void setup() {

        List<Job_Application__c> appsToInsert = new List<Job_Application__c>();
        
        // Create app with Follow_Up_Date older than 30 days
        Job_Application__c staleApp = new Job_Application__c(
            Job_Title__c = 'Stale Position',
            Status__c = 'Saved',
            Follow_Up_Date__c = Date.today().addDays(-31)
        );
        appsToInsert.add(staleApp);

        // Create app with Follow_Up_Date within 30 days
        Job_Application__c recentApp = new Job_Application__c(
            Job_Title__c = 'Recent Position',
            Status__c = 'Saved',
            Follow_Up_Date__c = Date.today().addDays(-10)
        );
        appsToInsert.add(recentApp);

        // Create app that's already Closed
        Job_Application__c closedApp = new Job_Application__c(
            Job_Title__c = 'Already Closed Position',
            Status__c = 'Closed',
            Follow_Up_Date__c = Date.today().addDays(-31)
        );
        appsToInsert.add(closedApp);

        insert appsToInsert;
    }

    @isTest
    public static void testJobApplicationCleanupBatchable() {

        //Run our Batch job
        Test.startTest();
        Database.executeBatch(new JobApplicationCleanupBatchable());
        Test.stopTest();

        //Retrieve all three kinds of Apps and test them to confirm proper assignments
        List<Job_Application__c> staleApps = [SELECT Id, Status__c, Notes__c 
                                              FROM Job_Application__c 
                                              WHERE Job_Title__c = 'Stale Position'];
        
        Assert.areEqual(1, staleApps.size(), 'Stale app should exist');
        Assert.areEqual('Closed', staleApps[0].Status__c, 'Stale app should be closed');
        Assert.isTrue(staleApps[0].Notes__c.contains('Automated Process'), 'Notes should contain automated process message');

        List<Job_Application__c> recentApps = [SELECT Id, Status__c 
                                               FROM Job_Application__c 
                                               WHERE Job_Title__c = 'Recent Position'];
        
        Assert.areEqual('Saved', recentApps[0].Status__c, 'Recent app should remain Saved');

        List<Job_Application__c> closedApps = [SELECT Id, Status__c 
                                               FROM Job_Application__c 
                                               WHERE Job_Title__c = 'Already Closed Position'];
        
        Assert.areEqual('Closed', closedApps[0].Status__c, 'Already closed app should remain Closed');
    }
}