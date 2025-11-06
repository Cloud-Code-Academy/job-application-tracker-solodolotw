trigger EventTrigger on Event (before insert, before update, after insert, after update) {
    switch on Trigger.operationType {
        when BEFORE_INSERT {
            EventTriggerHandler.preventOverLappingEvents(Trigger.new);
        }
        when BEFORE_UPDATE {
            EventTriggerHandler.preventOverLappingEvents(Trigger.new);
        }
        when AFTER_INSERT {
        }
        when AFTER_UPDATE {
        }
    }
}