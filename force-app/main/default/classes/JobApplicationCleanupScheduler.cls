public with sharing class JobApplicationCleanupScheduler implements Schedulable{
    public void execute(SchedulableContext sc) {
        Database.executeBatch( new JobApplicationCleanupBatchable(), 100);
    }
}