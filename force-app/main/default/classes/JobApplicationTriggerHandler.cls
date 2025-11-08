public with sharing class JobApplicationTriggerHandler extends TriggerHandler{
    
    public static Date todaysDate = Date.today();

    public static final String SAVED_DESC = 'Check if the job description aligns with your interests and values\n' +
                                            'Review the highlighted skills to see if the role is a good fit\n' +
                                            'Research the company or role and mark your excitement level';
    public static final String APPLYING_DESC =  'Find and research someone who works at the company and add them as a contact\n' +
                                                'Set up an informational interview to learn more about the role/company\n' +
                                                'Identify potential referrals to help get your application on the top of the pile\n' +
                                                'Customize your work achievements using the job description keywords\n' + 
                                                'Submit your application on the company website if possible';
    public static final String APPLIED_DESC =   'Reach out to the hiring manager or recruiter\n' +
                                                'Follow up on your application via email weekly\n' +
                                                'Continue identifying and saving similar job opportunities\n' + 
                                                'Set up weekly networking calls to explore similar companies/roles';
    public static final String INTERVIEWING_DESC =  'Prepare your blurb or “tell me about yourself” response\n' +
                                                    'Practice answering behavioral interview questions\n' +
                                                    'Research the company and your interviewers\n' +
                                                    'Set up your virtual interview space and test your tech\n' +
                                                    'Send thank you emails within 24 hours'; 
    public static final String NEGOTIATING_DESC =   'Research your market value and know your numbers\n' +
                                                    'Prepare your negotiation scripts\n' +
                                                    'Evaluate your offer and decline or accept';   
    public static final String ACCEPTED_DESC =  'Plan your resignation if applicable\n' +
                                                'Take some time to relax and recharge\n' +
                                                'Prepare for your first day of onboarding';
    public static final String CLOSED_DESC = 'Send a follow-up email thanking the interviewer and asking for feedback\n' +
                                             'Review your notes and reflect on areas of improvement'; 
    
    public static void statusCreateTask(Map<Id, Job_Application__c> oldMap, List<Job_Application__c> apps) { 
        
        //Check if record is new
        if (oldMap == null) {
            return;
        }

        //To only trigger upon a status change, the method compares the OLD and NEW status
        Set<Id> appsIds = new Set<Id>();

        //Loop through Applications
        for (Job_Application__c app : apps) {

            Job_Application__c oldApp = oldMap.get(app.Id);
            
            //if the OLD status is unchanged, flip to next iteration of the loop
            if (app.Status__c == oldApp.Status__c) {
                continue;
            }
            //If the Status WAS changed, add to the Id to the list
            appsIds.add(app.Id);
        }

        if (appsIds.isEmpty()) {
            return;
        }

        //List of Tasks to insert
        List<Task> newTasks = new List<Task>();
        
        //List of Applications who's status was changed
        List<Job_Application__c> appList = [SELECT Id, Status__c, Primary_Contact__c, Company_Name__c
                                            FROM Job_Application__c
                                            WHERE Id IN :appsIds];

        //Loop through Status changed Applications
        for (Job_Application__c app : appList) {

            String appStatus = app.Status__c;
            String appCompany = app.Company_Name__c;

            //Create a new task and link the Application, as well as the base priority level so we don't have to set it on every status change
            Task task = new Task();
            task.WhatId = app.Id;
            task.Priority = 'Medium';

            if(app.Primary_Contact__c != null){
                task.WhoId = app.Primary_Contact__c;
            }

            //Switch statement on the Status field, checking for each status and creating a subsequent Task
            //Switch statement for readability and simplicity
            switch on appStatus {
                when  'Saved'{
                    task.Subject = 'Saved Job Application at "' + appCompany + '" Next Steps';
                    task.ActivityDate = todaysDate.addDays(3);
                    task.Priority = 'Low';
                    task.Description = SAVED_DESC;
                    newTasks.add(task);
                }
                when  'Applying'{
                    task.Subject = 'Applying for a job at "' + appCompany + '" Next Steps';
                    task.ActivityDate = todaysDate.addDays(1);
                    task.Description = APPLYING_DESC;
                    newTasks.add(task);
                }
                when  'Applied'{
                    task.Subject = 'Applied for a job at "' + appCompany + '" Next Steps';
                    task.ActivityDate = todaysDate.addDays(7);
                    task.Description = APPLIED_DESC;
                    newTasks.add(task);
                }
                when  'Interviewing'{
                    task.Subject = 'Interview at "' + appCompany + '" Next Steps';
                    task.ActivityDate = todaysDate;
                    task.Priority = 'High';
                    task.Description = INTERVIEWING_DESC;
                    newTasks.add(task);
                }
                when  'Negotiating'{
                    task.Subject = 'Negotiating job offer at "' + appCompany + '" Next Steps';
                    task.ActivityDate = todaysDate.addDays(1);
                    task.Description = NEGOTIATING_DESC;
                    newTasks.add(task);
                }
                when  'Accepted'{
                    task.Subject = 'Accept offer at "' + appCompany + '" Next Steps';
                    task.ActivityDate = todaysDate.addDays(1);
                    task.Description = ACCEPTED_DESC;
                    newTasks.add(task);
                }
                when  'Closed'{
                    task.Subject = 'Closed Job Application at "' + appCompany + '" Next Steps';
                    task.ActivityDate = todaysDate.addDays(1);
                    task.Description = CLOSED_DESC;
                    newTasks.add(task);
                }
                when else {
                    System.debug('The value selected for the Status field does not exist');
                }
            }
        }
        if(!newTasks.isEmpty()){
            Database.insert( newTasks, false);
        }
    }
    
    public static void setPrimaryContact(List<Job_Application__c> apps){

        Set<Id> accIds = new Set<Id>();
        List<Job_Application__c> appsToUpdate = new List<Job_Application__c>();

        //Loop throuh Applications and check for a Contact
        for (Job_Application__C app : apps) {
            if(app.Primary_Contact__c == null && app.Account__c != null) {
                appsToUpdate.add(app);
                accIds.add(app.Account__c);
            }
        }

        //If all Applications have a contact, return
        if (appsToUpdate.isEmpty()) {
            return;
        }
        //Key is Account, value is Contact
        Map<Id, Id> accToCon = new Map<Id, Id>();

        //Loop through every Contact related to the Account and assign to a Map
        for (Contact con : [SELECT Id, AccountId FROM Contact WHERE AccountId IN :accIds]) {
            if (!accToCon.containsKey(con.AccountId)) {
                accToCon.put(con.AccountId, con.Id);
            }
        }

        //Loop through the Applications to update and update with the Contact from Map
        for (Job_Application__C app : appsToUpdate) {
            if (accToCon.containsKey(app.Account__c) && app.Primary_Contact__c == null) {
                app.Primary_Contact__c = accToCon.get(app.Account__c);
            }
        }
    }
}