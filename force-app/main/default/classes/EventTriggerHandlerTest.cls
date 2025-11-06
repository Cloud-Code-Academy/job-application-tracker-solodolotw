@isTest
public with sharing class EventTriggerHandlerTest {
    @testSetup
    static void setup() {
        Account acc = new Account(Name = 'Test Company');
        insert acc;
    }

    @isTest
    public static void testPreventOverlappingEvents_noOverlap() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Datetime eventDateTime = Datetime.now().addDays(1);
        
        Event event1 = new Event(
            Subject = 'Interview 1',
            StartDateTime = eventDateTime,
            EndDateTime = eventDateTime.addHours(1),
            WhatId = acc.Id
        );
        insert event1;

        Event event2 = new Event(
            Subject = 'Interview 2',
            StartDateTime = eventDateTime.addHours(2),
            EndDateTime = eventDateTime.addHours(3),
            WhatId = acc.Id
        );

        Test.startTest();
        insert event2;
        Test.stopTest();

        List<Event> events = [SELECT Id FROM Event WHERE WhatId = :acc.Id];
        Assert.areEqual(2, events.size(), 'Both events should be created when there is no overlap');
    }

    @isTest
    public static void testPreventOverlappingEvents_withOverlap() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Datetime eventDateTime = Datetime.now().addDays(1);
        
        Event event1 = new Event(
            Subject = 'Interview 1',
            StartDateTime = eventDateTime,
            EndDateTime = eventDateTime.addHours(1),
            WhatId = acc.Id
        );
        insert event1;

        Event event2 = new Event(
            Subject = 'Interview 2',
            StartDateTime = eventDateTime,
            EndDateTime = eventDateTime.addHours(1),
            WhatId = acc.Id
        );

        Test.startTest();
        try {
            insert event2;
            Assert.fail('Should have thrown an error for overlapping events');
        } catch (DmlException e) {
            Assert.isTrue(e.getMessage().contains('The time slot you are trying to schedule this Event for is currently taken'), 'Error message should match');
        }
        Test.stopTest();
    }
}