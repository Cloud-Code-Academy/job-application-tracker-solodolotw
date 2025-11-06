@isTest
public with sharing class EventReminderTest {
    @testSetup
    static void setup() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Contact con = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test@gmail.com',
            AccountId = acc.Id
        );
        insert con;

        Job_Application__c app = new Job_Application__c(
            Job_Title__c = 'Software Developer',
            Account__c = acc.Id,
            Status__c = 'Saved'
        );
        insert app;
    }

    @isTest
    public static void testEventReminderBatchable() {
        Job_Application__c app = [SELECT Id FROM Job_Application__c LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        Date tomorrowsDate = Date.today().addDays(1);
        Datetime tomorrowStart = Datetime.newInstance(tomorrowsDate.year(), tomorrowsDate.month(), tomorrowsDate.day());

        Event ev = new Event(
            Subject = 'Interview',
            StartDateTime = tomorrowStart.addHours(10),
            EndDateTime = tomorrowStart.addHours(11),
            WhatId = app.Id,
            WhoId = con.Id
        );
        insert ev;

        Test.startTest();
        Database.executeBatch(new EventReminderBatchable());
        Test.stopTest();

        //Verify the batch executed without errors
        List<AsyncApexJob> jobs = [SELECT Id, Status FROM AsyncApexJob WHERE ApexClass.Name = 'EventReminderBatchable'];
        Assert.areEqual(2, jobs.size(), 'Batch job should execute');
        Assert.areEqual('Completed', jobs[0].Status, 'Batch job should complete successfully');
    }
}