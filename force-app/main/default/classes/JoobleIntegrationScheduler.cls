public with sharing class JoobleIntegrationScheduler implements Schedulable{

    public static Date todaysDate = Date.today();
    public static String yesterdaysDate = String.valueOf(todaysDate - 1);

    public void execute(SchedulableContext sc) {
        System.enqueueJob( new JoobleIntegrationQueueable('Salesforce Developer', 'Phoenix, AZ', 100000, '20', '1', yesterdaysDate));
    }
}