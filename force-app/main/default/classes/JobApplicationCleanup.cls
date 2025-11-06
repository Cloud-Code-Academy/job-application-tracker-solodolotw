public with sharing class JobApplicationCleanup implements Database.Batchable<SObject> {

    public Date todaysDate = Date.today();
    public Date thirtyDaysAgo = todaysDate - 30;
    public static final String CLOSED_NOTES = 'This Job Application was Closed by an Automated Process.\n'+
                                              'Ask your Salesforce Administrator for more information.';
    public Database.QueryLocator start(Database.BatchableContext bc){

        return Database.getQueryLocator([SELECT Id, Status__c, Follow_Up_Date__c, Notes__c  
                                         FROM Job_Application__c 
                                         WHERE Follow_Up_Date__c <= :thirtyDaysAgo
                                         AND (Status__c != 'Closed'
                                         OR Status__c != 'Accepted')]);
    }
    

    public void execute(Database.BatchableContext bc, List<Job_Application__c> scope) {
        List<Job_Application__c> appsToUpdate = new List<Job_Application__c>();
        for (Job_Application__c app : scope) {
            app.Status__c = 'Closed';
            app.Notes__c = CLOSED_NOTES;

            appsToUpdate.add(app);
        }
        if (!appsToUpdate.isEmpty()) {
            Database.update( appsToUpdate, false);
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('All Stale Job Applications have been Closed.`');
    }    
}