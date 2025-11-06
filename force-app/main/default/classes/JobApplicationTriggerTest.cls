@isTest
public with sharing class JobApplicationTriggerTest {
    @testSetup 
    //Setup method to for the rest of the methods to reference inside of this class
    static void setup() {
        List<Account> accountsToInsert = new List<Account>();
        List<Contact> contactsToInsert = new List<Contact>();
        List<Job_Application__c> appsToInsert = new List<Job_Application__c>();

        //Creating accounts, contacts and job applications for bulk testing
        for (Integer i = 0; i < 5; i++) {
            Account acc = new Account(Name = 'Test Company ' + i);
            accountsToInsert.add(acc);
        }
        insert accountsToInsert;

        for (Integer i = 0; i < 5; i++) {
            Contact con = new Contact(
                FirstName = 'Test', 
                LastName = 'Contact ' + i, 
                Email = i + 'test' + '@gmail.com',
                AccountId = accountsToInsert[i].Id
            );
            contactsToInsert.add(con);
        }
        insert contactsToInsert;

        for (Integer i = 0; i < 5; i++) {
            Job_Application__c app = new Job_Application__c(
                Job_Title__c = 'Test Dev ' + i, 
                Account__c = accountsToInsert[i].Id,
                Status__c = 'Saved', 
                Primary_Contact__c = contactsToInsert[i].Id
            );
            appsToInsert.add(app);
        }
        insert appsToInsert;
    }
    @isTest
    public static void testStatusCreateTask_statusChange() {
        List<Job_Application__c> apps = [SELECT Id, Job_Title__c, Company_Name__c, Status__c  
                                         FROM Job_Application__C 
                                         WHERE Job_Title__c LIKE 'Test Dev%'];
        //Get the count of current tasks to confirm our trigger created the proper amount of records
        Integer taskCountBefore = [SELECT COUNT() 
                                   FROM Task 
                                   WHERE WhatId IN :apps];
        
        for (Job_Application__c app : apps) {
            app.Status__c = 'Applying';
        }
        
        Test.startTest();
        update apps;
        Test.stopTest();

        //Retrieve tasks AFTER status change to confirm the status change created the correct amount of tasks
        List<Task> createdTasks = [SELECT Id, WhatId, Subject, Description, ActivityDate, Priority
                                   FROM Task 
                                   WHERE WhatId IN :apps];

        Assert.areEqual(5, createdTasks.size(), 'A task should be created for each application status change');
        Assert.areNotEqual(taskCountBefore, createdTasks.size(), 'Task count should increase after status update');
    }
    @isTest
    public static void testStatusCreateTask_allStatuses() {
        List<Job_Application__c> apps = [SELECT Id, Job_Title__c, Company_Name__c, Status__c  
                                         FROM Job_Application__C 
                                         WHERE Job_Title__c LIKE 'Test Dev%'];
        
        Account acc = new Account(Name = 'Test Company');
        insert acc;

        Contact con = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = acc.Id);
        insert con;
        
        List<String> allStatuses = new List<String>{'Applying', 'Applied', 'Interviewing', 'Negotiating', 'Accepted', 'Closed'};
        List<Job_Application__c> appsToInsert = new List<Job_Application__c>();

        for (Integer i = 0; i < allStatuses.size(); i++) {
            Job_Application__c app = new Job_Application__c(
                Job_Title__c = 'Status Test ' + allStatuses[i],
                Account__c = acc.Id,
                Primary_Contact__c = con.Id,
                Status__c = 'Saved'
            );
            appsToInsert.add(app);
        }
        insert appsToInsert;

        //Change the status of each application
        for (Integer i = 0; i < appsToInsert.size(); i++) {
            appsToInsert[i].Status__c = allStatuses[i];
        }

        Test.startTest();
        update appsToInsert;
        Test.stopTest();

        List<Task> createdTasks = [SELECT Id, Subject, Priority, ActivityDate 
                                   FROM Task 
                                   WHERE WhatId IN :appsToInsert 
                                   ORDER BY Subject];
        Assert.areEqual(allStatuses.size(), createdTasks.size(), 'A task should be created for each status transition');
    }

    @isTest
    public static void testStatusCreateTask_noStatusChange(){
        List<Job_Application__c> apps = [SELECT Id, Job_Title__c, Company_Name__c, Status__c  
                                         FROM Job_Application__C 
                                         WHERE Job_Title__c LIKE 'Test Dev%'];
        //Get the count of current tasks
        Integer taskCountBefore = [SELECT COUNT() 
                                   FROM Task 
                                   WHERE WhatId IN :apps];
        
        for (Job_Application__c app : apps) {
            app.Salary__c = 125000;
        }
        
        Test.startTest();
        update apps;
        Test.stopTest();

        //Retrieve tasks AFTER non-status field change to confirm NO tasks were created
        List<Task> createdTasks = [SELECT Id, WhatId, Subject, Description, ActivityDate, Priority
                                   FROM Task 
                                   WHERE WhatId IN :apps];

        Assert.areEqual(taskCountBefore, createdTasks.size(), 'A task should only be created for an application status change');
        Assert.areNotEqual(5, createdTasks.size(), 'Task count should NOT increase after non-status update');
    }
    @isTest
    public static void testSetPrimaryContact_noContact() {
        List<Contact> contactsToInsert = new List<Contact>();
        List<Job_Application__c> appsToInsert = new List<Job_Application__c>();

        //Create a parent account and 3 new contacts
        Account acc = new Account(Name = 'Bands Emeka Dance');
        insert acc;

        for (Integer i = 0; i < 3; i++) {
            Contact con = new Contact(
                FirstName = 'Emeka',
                LastName = 'Egbuka ' + i,
                AccountId = acc.Id
            );
            contactsToInsert.add(con);
        }
        insert contactsToInsert;

        //Create job applications WITHOUT primary contacts
        for (Integer i = 0; i < 3; i++) {
            Job_Application__c app = new Job_Application__c(
                Job_Title__c = 'Salesforce Developer ' + i,
                Account__c = acc.Id,
                Status__c = 'Saved'
            );
            appsToInsert.add(app);
        }

        Test.startTest();
        insert appsToInsert;
        Test.stopTest();

        List<Job_Application__c> insertedApps = [SELECT Id, Primary_Contact__c, Account__c 
                                                  FROM Job_Application__c 
                                                  WHERE Job_Title__c LIKE 'Salesforce Developer%'];
        
        for (Job_Application__c app : insertedApps) {
            Assert.isNotNull(app.Primary_Contact__c, 'Primary contact should have been auto-populated');
        }
    }
}    