trigger JobApplicationTrigger on Job_Application__c (before insert, before update, after insert, after update) {
    switch on Trigger.operationType {
        when BEFORE_INSERT {
            JobApplicationTriggerHandler.setPrimaryContact(Trigger.new);
        }
        when BEFORE_UPDATE {
            JobApplicationTriggerHandler.setPrimaryContact(Trigger.new);
        }
        when AFTER_INSERT {
            JobApplicationTriggerHandler.statusCreateTask(Trigger.oldMap, Trigger.new);
            
        }
        when AFTER_UPDATE {
            JobApplicationTriggerHandler.statusCreateTask(Trigger.oldMap, Trigger.new);
            
        }
    }
}