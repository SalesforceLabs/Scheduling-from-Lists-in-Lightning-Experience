/**
 * @author Altimetrik
 * @description
 *  started on 06/06/2018
 *  This class test EventSchedullingLtngCtrl class
 **/
@isTest
public class EventSchedullingLtngCtrl_Test {
@testSetup
    public static void setup() {
        Account ac = new Account(Name = 'Test Account');
        insert ac;
        Contact ct = new Contact(LastName = 'Contact', FirstName = 'Test');
        insert ct;
        Lead ld = new Lead(LastName = 'Lead', FirstName = 'Test', Company = 'Test Company');
        insert ld;
        Event e = new Event();
           e.StartDateTime = DateTime.valueOf( '2018-01-01 00:00:00' );
           e.EndDateTime   = DateTime.valueOf( '2018-01-01 01:00:00' );
           e.OwnerId =  UserInfo.getUserId();
           e.subject = 'Test Subject';
           INSERT e;
        List<Event> events = new List<Event>();
        for(Integer i = 0; i < 5; i++) {
            events.add(new Event(Subject = 'This Week Event ' + 1, OwnerId = UserInfo.getUserId(),
                StartDateTime = DateTime.now(),EndDateTime = DateTime.now().addHours(1)));
            events.add(new Event(Subject = 'Last Week Event ' + 1, OwnerId = UserInfo.getUserId(),
                StartDateTime = DateTime.now().addDays(-6), EndDateTime = DateTime.now().addDays(-5)));
            events.add(new Event(Subject = 'Next Week Event ' + 1, OwnerId = UserInfo.getUserId(),
                StartDateTime = DateTime.now().addDays(5), EndDateTime = DateTime.now().addDays(6)));
            events.add(new Event(Subject = 'This Week Event ' + 1, OwnerId = UserInfo.getUserId(),
                StartDateTime = DateTime.now().addDays(-5),EndDateTime = DateTime.now().addDays(-3)));
            events.add(new Event(Subject = 'This Week Event ' + 1, OwnerId = UserInfo.getUserId(),
                StartDateTime = DateTime.now().addDays(3),EndDateTime = DateTime.now().addDays(5)));
            events.add(new Event(Subject = 'All Day Event In Range ' + 1, OwnerId = UserInfo.getUserId(),
                StartDateTime = DateTime.now(),EndDateTime = DateTime.now().addDays(2), IsAllDayEvent = true));
        }
        insert events;
        
        System.assertEquals(30, events.size());
    }
    /*
    Description: Pass a Contact Id should return the same Contact Object
    */

     @isTest
    public static void test_loadInitialData_emptyIdList() {
        List<Contact> lct = [select Id from Contact limit 1];
        Test.startTest();
        LightningResponse resp = EventSchedullingLtngCtrl.loadInitialData('');
        Test.stopTest();
        System.assertEquals(LightningResponse.ERROR_STATE, resp.state,'Execution should not be be  succesful  ');
       
    }

    @isTest
    public static void test_loadInitialData_ContactIds() {
        List<Contact> lct = [select Id from Contact limit 1];
        Test.startTest();
        LightningResponse resp = EventSchedullingLtngCtrl.loadInitialData(lct.get(0).Id);
        Test.stopTest();

        //execution successful
        System.assertEquals(LightningResponse.SUCCESS_STATE, resp.state,'Execution should be  succesful  ');
        
        Map<String,Object> m = (Map<String,Object>) JSON.deserializeUntyped(resp.jsonResponse);
        String tmp = JSON.serialize(m.get('draftEvents'));
        
        //draft event list is returned
        System.assert(String.isNotBlank(tmp));
        List<Event>  events = (List<Event>) JSON.deserialize(tmp,List<Event>.class);
        //draft event size is 1
        System.assertEquals(1, events.size(),'There should be only one draft event');
    }
    /*
    Description: Pass an account Id should return the same Account Object
    */
    @isTest
    private static void test_loadInitialData_AccountIds() {
        Account acct = [SELECT Id, Name FROM Account LIMIT 1];
        Test.startTest();
        LightningResponse resp = EventSchedullingLtngCtrl.loadInitialData(acct.Id);
        Test.stopTest();
         //execution successful
        System.assertEquals(LightningResponse.SUCCESS_STATE, resp.state,'Execution should be  succesful  ');
        
        Map<String,Object> m = (Map<String,Object>) JSON.deserializeUntyped(resp.jsonResponse);
        String tmp = JSON.serialize(m.get('draftEvents'));
        
        //draft event list is returned
        System.assert(String.isNotBlank(tmp));
        List<Event>  events = (List<Event>) JSON.deserialize(tmp,List<Event>.class);
        //draft event size is 1
        System.assertEquals(1, events.size(),'There should be only one draft event');
    }
    /*
    Description: Pass a lead Id should return the same Lead Object
    */
    @isTest
    private static void test_loadInitialData_LeadIds() {
        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        Test.startTest();
        LightningResponse resp = EventSchedullingLtngCtrl.loadInitialData(lead.Id);
        Test.stopTest();
          //execution successful
        System.assertEquals(LightningResponse.SUCCESS_STATE, resp.state,'Execution should be  succesful  ');
        
        Map<String,Object> m = (Map<String,Object>) JSON.deserializeUntyped(resp.jsonResponse);
        String tmp = JSON.serialize(m.get('draftEvents'));
        
        //draft event list is returned
        System.assert(String.isNotBlank(tmp));
        List<Event>  events = (List<Event>) JSON.deserialize(tmp,List<Event>.class);
        //draft event size is 1
        System.assertEquals(1, events.size(),'There should be only one draft event');
    }

    /*
    Description: check user permissions over events
    */
    @isTest
    private static void test_checkPermissions() {
        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        Test.startTest();
        LightningResponse resp = EventSchedullingLtngCtrl.checkPermissions();
        Test.stopTest();
          //execution successful
        System.assertEquals(LightningResponse.SUCCESS_STATE, resp.state,'Execution should be  succesful  ');
        
        Map<String,Object> m = (Map<String,Object>) JSON.deserializeUntyped(resp.jsonResponse);
        Boolean canCreate = Boolean.valueOf(m.get('canCreate'));
        
      
        System.assert(canCreate,'Sys admin can create events');
    }


    /*
    Description: Get the Event records that falls into a specific Date range for the current user
    */
    @isTest
    private static void test_getEvents() {
        Test.startTest();
        String startD = String.valueOf(DateTime.now().addDays(-4));
        String endD = String.valueOf(DateTime.now().addDays(-4));
        LightningResponse resp = EventSchedullingLtngCtrl.getEvents(startD, endD, UserInfo.getUserId());
        Test.stopTest();
        System.assertEquals(LightningResponse.SUCCESS_STATE, resp.state, 'Execution should be successful.');
        List<EventSchedullingLtngCtrl.CustomEvent> events = (List<EventSchedullingLtngCtrl.CustomEvent>) JSON.deserialize(resp.jsonResponse,
            List<EventSchedullingLtngCtrl.CustomEvent>.class);
        System.assertEquals(5, events.size());//will only retrieve events for current week
        for(EventSchedullingLtngCtrl.CustomEvent event: events) {
            System.assert((event.title.contains('This Week Event') && event.allDay) ||
                          (event.title.contains('All Day Event In Range') && event.allday));
        }
    }
    /*
    Description: Test basic reschedule scenario for no all day event with duration less than 24 hours
    */
    @isTest
    private static void test_rescheduleNormalEvent() {
        Event evt = [Select Id, Subject, StartDateTime,EndDateTime FROM Event WHERE Subject like 'Test Subject' LIMIT 1];
        Test.startTest();
        LightningResponse resp = EventSchedullingLtngCtrl.rescheduleEvent( evt.Id, '2018-02-02 03:00:00');
        Test.stopTest();
        System.assertEquals(LightningResponse.SUCCESS_STATE, resp.state);
        Event evtModified = [Select Id, Subject, StartDateTime,EndDateTime FROM Event WHERE Id =: evt.Id];
        System.assertEquals(DateTime.valueOf('2018-02-02 03:00:00'), evtModified.StartDateTime);
        System.assertEquals(DateTime.valueOf('2018-02-02 04:00:00'), evtModified.EndDateTime);
    }
    /*
    Description: Test reschedule scenario for all day event
    */
    @isTest
    private static void test_rescheduleAllDayEvent() {
        Event evt = [Select Id, Subject, StartDateTime,EndDateTime FROM Event WHERE IsAllDayEvent = true LIMIT 1];
        Test.startTest();
        LightningResponse resp = EventSchedullingLtngCtrl.rescheduleEvent( evt.Id, '2018-02-15 00:00:00');
        Test.stopTest();
        System.assertEquals(LightningResponse.SUCCESS_STATE, resp.state);
        Event evtModified = [Select Id, Subject, StartDateTime,EndDateTime FROM Event WHERE Id =: evt.Id];
        System.assertEquals(DateTime.valueOfGmt('2018-02-15 00:00:00'), evtModified.StartDateTime);
        System.assertEquals(DateTime.valueOfGmt('2018-02-17 00:00:00'), evtModified.EndDateTime);
    }
    /*
    Description: Test reschedule scenario for non all day event that's duration is more than 24 hours
    */
    @isTest
    private static void test_rescheduleLargeEvent() {
        Event evt = [Select Id, Subject, StartDateTime,EndDateTime, DurationInMinutes 
                     FROM Event WHERE IsAllDayEvent = false AND DurationInMinutes >= 1440 LIMIT 1];
        Test.startTest();
        LightningResponse resp = EventSchedullingLtngCtrl.rescheduleEvent( evt.Id, '2018-02-15 00:00:00');
        Test.stopTest();
        System.assertEquals(LightningResponse.SUCCESS_STATE, resp.state);
        Event evtModified = [Select Id, Subject, StartDateTime,EndDateTime, DurationInMinutes FROM Event WHERE Id =: evt.Id];
        System.assertEquals(DateTime.newInstance(2018, 2, 15, evt.EndDateTime.hour(), 
        evt.EndDateTime.minute(), evt.EndDateTime.second()), evtModified.StartDateTime);
        System.assertEquals(evt.DurationInMinutes, evtModified.DurationInMinutes);
    }
    /*
    Description: Test reschedule scenario for unexisting event record id
    */
    @isTest
    private static void test_rescheduleEventNotExist() {
        Test.startTest();
        LightningResponse resp = EventSchedullingLtngCtrl.rescheduleEvent( 'fakeid', '2018-02-15 00:00:00');
        Test.stopTest();
        System.assertEquals(LightningResponse.ERROR_STATE, resp.state);
    }
    /*
    Description: Load event details
    */
    @isTest
    private static void test_loadEventDetails_validId() {
        Event evt = [Select Id, Subject, StartDateTime,EndDateTime FROM Event WHERE Subject like 'Test Subject' LIMIT 1];
        Test.startTest();
        LightningResponse resp = EventSchedullingLtngCtrl.loadEventDetails( evt.Id);
        Test.stopTest();
        System.assertEquals(LightningResponse.SUCCESS_STATE, resp.state,'Execution should be  succesful  ');
       
        Event evtDetails = (Event) JSON.deserialize(resp.jsonResponse,Event.class);
        System.assertEquals(evt.Subject, evtDetails.Subject);
    }
    /*
    Description: Creating an Event with Required fields missing.
    */
    @isTest
    private static void test_saveCurrentEvent_error() {

        Event e = new Event();
        e.OwnerId =  UserInfo.getUserId();
        e.subject = 'this is custom error subject';
        //start end time are required fields so the upsert dml will fail
        String jsonEvent = JSON.serialize(e);

        Test.startTest();
        LightningResponse resp = EventSchedullingLtngCtrl.saveCurrentEvent( jsonEvent);
        
        Test.stopTest();
        System.assertEquals(LightningResponse.ERROR_STATE, resp.state,'Execution should have been unsuccesful  ');
 
    }

    /*
    Description: Load event details
    */
    @isTest
    private static void test_saveCurrentEvent_success() {

        Event e = new Event();
        e.StartDateTime = DateTime.valueOf( '2018-01-01 00:00:00' );
        e.EndDateTime   = DateTime.valueOf( '2018-01-01 01:00:00' );
        e.OwnerId =  UserInfo.getUserId();
        e.subject = 'this is custom subject';
        String jsonEvent = JSON.serialize(e);

        Test.startTest();
        LightningResponse resp = EventSchedullingLtngCtrl.saveCurrentEvent( jsonEvent);
        
        Test.stopTest();
        System.assertEquals(LightningResponse.SUCCESS_STATE, resp.state,'Execution should be  succesful  ');
        List<Event> lEvts = [Select Id, Subject, StartDateTime,EndDateTime FROM Event WHERE Subject like :e.subject LIMIT 1];
       
        System.assertEquals(1, lEvts.size(), 'should have matched the new event');
    }

    /*
    Description: Test CustomEvent Constructor for not all day events with duration less than 1440 minutes.
    */
    @isTest
    private static void test_CustomEventShort() {
        Event evt = [SELECT Id, StartDateTime, EndDateTime, Owner.Name, Subject ,IsAllDayEvent ,DurationInMinutes 
                     FROM Event WHERE IsAllDayEvent = false AND DurationInMinutes < 1440 LIMIT 1];
        Test.startTest();
        EventSchedullingLtngCtrl.CustomEvent ce = new EventSchedullingLtngCtrl.CustomEvent(evt);
        Test.stopTest();
        System.assertEquals(evt.Id, ce.id);
        System.assertEquals(evt.Subject, ce.title);
        System.assertEquals(evt.StartDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS'), ce.start);
        System.assertEquals(evt.EndDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS'), ce.end_time_x);
        System.assertEquals(evt.IsAllDayEvent, ce.allDay);
    }
    /*
    Description: Test CustomEvent Constructor for not all day events with duration greater or equals than 1440 minutes.
    */
    @isTest
    private static void test_CustomEventLong() {
        Event evt = [SELECT Id, StartDateTime, EndDateTime, Owner.Name, Subject ,IsAllDayEvent ,DurationInMinutes 
                     FROM Event WHERE IsAllDayEvent = false AND DurationInMinutes >= 1440 LIMIT 1];
        Test.startTest();
        EventSchedullingLtngCtrl.CustomEvent ce = new EventSchedullingLtngCtrl.CustomEvent(evt);
        Test.stopTest();
        System.assertEquals(evt.Id, ce.id);
        System.assertEquals('(' + evt.StartDateTime.format('h:mm a')+') ' + evt.Subject, ce.title);
        System.assertEquals(evt.StartDateTime.format('yyyy-MM-dd'), ce.start);
        System.assertEquals(evt.EndDateTime.addDays(1).format('yyyy-MM-dd'), ce.end_time_x);
        System.assert(ce.allDay);
    }
    /*
    Description: Test CustomEvent Constructor for not all day events with duration multiple of 1440.
    */
    @isTest
    private static void test_CustomEventLongStartAt0() {
        Event newEvt = new Event(Subject = 'This Week Event ' + 1, OwnerId = UserInfo.getUserId(),
                StartDateTime = DateTime.newInstance(2018, 7, 6, 0, 0, 0), DurationInMinutes = 1440);
        Database.insert(newEvt);
        Event evt = [SELECT Id, StartDateTime, EndDateTime, Owner.Name, Subject ,IsAllDayEvent ,DurationInMinutes 
                     FROM Event WHERE Id =: newEvt.Id];
        Test.startTest();
        EventSchedullingLtngCtrl.CustomEvent ce = new EventSchedullingLtngCtrl.CustomEvent(evt);
        Test.stopTest();
        System.assertEquals(evt.Id, ce.id);
        System.assertEquals('(' + evt.StartDateTime.format('h:mm a')+') ' + evt.Subject, ce.title);
        System.assertEquals(evt.StartDateTime.format('yyyy-MM-dd'), ce.start);
        System.assertEquals(evt.EndDateTime.format('yyyy-MM-dd'), ce.end_time_x);
        System.assert(ce.allDay);
    }
    /*
    Description: Test CustomEvent Constructor for all day events.
    */
    @isTest
    private static void test_CustomEventAllDay() {
        Event evt = [SELECT Id, StartDateTime, EndDateTime, Owner.Name, Subject ,IsAllDayEvent ,DurationInMinutes 
                     FROM Event WHERE IsAllDayEvent = true LIMIT 1];
        Test.startTest();
        EventSchedullingLtngCtrl.CustomEvent ce = new EventSchedullingLtngCtrl.CustomEvent(evt);
        Test.stopTest();
        System.assertEquals(evt.Id, ce.id);
        System.assertEquals(evt.Subject, ce.title);
        System.assertEquals(evt.StartDateTime.formatGMT('yyyy-MM-dd'), ce.start);
        System.assertEquals(evt.EndDateTime.addDays(1).formatGMT('yyyy-MM-dd'), ce.end_time_x);
        System.assert(ce.allDay);
    }
}