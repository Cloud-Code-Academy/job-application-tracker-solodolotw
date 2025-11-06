public with sharing class JoobleIntegrationSchedulable implements Schedulable{

    Date todaysDate = Date.today();
    Date yesterdaysDate = todaysDate - 1;

    String CRON_EXP = '0 4 * * ? *';

    public void execute(SchedulableContext sc) {
        System.enqueueJob(System.schedule('Jooble Job Integration - Daily 4 AM', CRON_EXP, new JoobleIntegrationSchedulable()));
    }
}