public with sharing class EventTriggerHandler extends TriggerHandler {

    public static void preventOverLappingEvents(List<Event> interviews) {

        //A Set of Event Start Dates that we use to reference for our error
        Set<Datetime> startDates = new Set<Datetime>();

        for (Event ev : interviews) {
            startDates.add(ev.StartDateTime);
        }

        //Retrieve all Events with the same Start Date as the triggering record
        List<Event> overlappingEvents = [SELECT Id, StartDateTime FROM Event WHERE StartDateTime IN :startDates];
        
        //Null check
        if (overlappingEvents.isEmpty()) {
            return;
        }

        Map<Datetime, List<Event>> overlapMap = new Map<Datetime, List<Event>>();

        //Compare Start Dates
        for (Event ev : overlappingEvents) {
            if (!overlapMap.containsKey(ev.StartDateTime)) {
                overlapMap.put(ev.StartDateTime, new List<Event>());
            }
            overlapMap.get(ev.StartDateTime).add(ev);
        }

        //Add Error to Event
        for (Event interview : interviews) {
            if (overlapMap.containsKey(interview.StartDateTime)) {
                interview.addError('The time slot you are trying to schedule this Event for is currently taken. Please check your calendar and choose a time that does not overlap with another event.');
            }
        }
    }
}