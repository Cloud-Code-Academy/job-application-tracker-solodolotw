public with sharing class EventReminderBatchable implements Database.Batchable<SObject> {
    
    public Date todaysDate = Date.today();
    public Date tomorrowsDate = todaysDate.addDays(1);
    
    //Start our Batchable
    public Database.QueryLocator start(Database.BatchableContext bc){
        //Variables for reference in our query 
        Datetime startOfTomorrow = Datetime.newInstance(tomorrowsDate.year(), tomorrowsDate.month(), tomorrowsDate.day());
        Datetime endOfTomorrow = startOfTomorrow.addDays(1).addSeconds(-1);

        return Database.getQueryLocator([SELECT Id, StartDateTime, Owner.Email, Owner.Name, WhatId, WhoId, Who.Name  
                                         FROM EVENT 
                                         WHERE StartDateTime >= :startOfTomorrow 
                                         AND StartDateTime <= :endOfTomorrow]);
    }
    
    //Execute our Batchable
    public void execute(Database.BatchableContext bc, List<Event> scope) {
        
        Set<Id> appIds = new Set<Id>();
        
        for(Event ev : scope){ 
            appIds.add(ev.WhatId);
        }

        List<Job_Application__c> apps = [SELECT Id, Job_Title__c, Company_Name__c
                                         FROM Job_Application__c
                                         WHERE Id IN :appIds];
        //A Map that we can reference Job Applications from
        Map<Id, Job_Application__c> appMap = new Map<Id, Job_Application__c>(apps);
        
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

        //Assigning the amount of emails our process can send
        Messaging.reserveSingleEmailCapacity(scope.size());
        
        //Looping through every Event and assigning an email send
        for(Event ev : scope){

            if (appMap.containsKey(ev.WhatId)) {
                Job_Application__c relatedApp = appMap.get(ev.WhatId);

                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                mail.setReplyTo('tannerwetnight@gmail.com');
                
                mail.setSenderDisplayName('Interview Alert');
                
                mail.setSubject('URGENT: Upcoming Interview');
                
                mail.setBccSender(false);
                
                mail.setUseSignature(false);
                
                mail.setPlainTextBody('Your Interview is coming up');

                String[] toAddresses = new String[] {ev.Owner.Email};

                mail.setToAddresses(toAddresses);

                mail.setHtmlBody(
                    'Hello ' + ev.Owner.Name + ',<br/><br/>' +
                    'This is a friendly reminder that you have an upcoming interview scheduled for <b>tomorrow, ' + 
                    ev.StartDateTime.format('EEEE, MMMM d, yyyy \'at\' h:mm a') + '</b>.<br/><br/>' +
                    'Please review the meeting details and ensure you are prepared and available at the scheduled time.<br/><br/>' +
                    '<b>Interview Details:</b><br/>' +
                    'Position: ' + relatedApp.Job_Title__c + '<br/>' +
                    'Interviewer: ' + (ev.Who != null ? ev.Who.Name : 'N/A') + '<br/>' +
                    'Company: ' + relatedApp.Company_Name__c + '<br/><br/>' +
                    'If you have any questions or need to reschedule, please do so via <a href=https://cloudcodeacademy-b-dev-ed.develop.lightning.force.com/lightning/r/Job_Application__c/'+ ev.Id +'>this link.</a>' +
                    '<br/>Best of luck!<br/>'
                );

                emailsToSend.add(mail);
            }
        }

        //Null check and error handling
        if (!emailsToSend.isEmpty()) {
            try {
                Messaging.sendEmail(emailsToSend);
            } catch (Exception e) {
                System.debug('Email sending failed: ' + e.getMessage());
            }
        }
    }

    //Finish our Batchable.
    public void finish(Database.BatchableContext bc) {
        System.debug('All Emails for tomorrows Interview\'s have been sent');
    }
}