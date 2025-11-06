public with sharing class EventReminderScheduler implements Schedulable{
    public void execute(SchedulableContext sc) {
        Database.executeBatch( new EventReminderBatchable(), 100);
    }
}//