/**
 * @author Altimetrik
 * @description
 *  started on 06/05/2018
 *  This class resolves all logic for lightning components
 **/
public with sharing class EventSchedullingLtngCtrl {
    // Static variables
    private static final Integer MINS_PER_DAY = 1440;

    //************************************************************************
    // Constants
    //************************************************************************
    // Static methods


    /*
    * @description
    *   loads details on selected records, checks user permissions over event
    * @params
    *   String recordIds comma separated Id list
    * @return
    *   LightningResponse
    */
    //public static DATA_TYPE some_method(DATA_TYPE, PARAM_NAME){}
    @AuraEnabled
    public static LightningResponse loadInitialData(String recordIds){
        LightningResponse response = new LightningResponse();
        CalendarEventModel calendarEventModel;
        Boolean canCreate = Schema.sObjectType.Event.isCreateable();
        Boolean canUpdate = Schema.sObjectType.Event.isUpdateable() && Schema.sObjectType.Event.fields.IsAllDayEvent.isAccessible();
        Boolean canRead   = Schema.sObjectType.Event.fields.IsAllDayEvent.isAccessible();
        Boolean canSearch = Schema.sObjectType.Event.isSearchable();
 
        if(!String.isNotBlank(recordIds)) {
            response.state = 'ERROR';
            response.error = 'List of records is empty';
        }else{
            try{

                recordIds = recordIds.deleteWhitespace();
                List<String> idList  = recordIds.split(',');
                calendarEventModel = populateDraftEvents(idList);
                Map<String,Object> result  = new Map<String,Object>();
                result.put('draftEvents', calendarEventModel.draftEvents);
                result.put('eventRelatedPersonMap', calendarEventModel.eventRelatedPersonMap);
                result.put('eventRelatedObjectMap', calendarEventModel.eventRelatedObjectMap);
                result.put('currentUserId', calendarEventModel.userId);
                result.put('currentUserName', calendarEventModel.userName);
                result.put('canCreate', canCreate);
                result.put('canUpdate', canUpdate);
                result.put('canRead', canRead);
                result.put('canEditAllDay', Schema.sObjectType.Event.fields.IsAllDayEvent.isUpdateable());
                result.put('canEditName', Schema.sObjectType.Event.fields.WhoId.isUpdateable());
                result.put('canEditRelatedTo', Schema.sObjectType.Event.fields.WhatId.isUpdateable());
                response.jsonResponse = JSON.serialize(result);
            } catch(Exception e) {
                response = new LightningResponse(e);
            }
        }
        return response;
    }



    /*
    * @description
    *    checks user permissions over event
    * @params
    *   
    * @return
    *   LightningResponse
    */
    //public static DATA_TYPE some_method(DATA_TYPE, PARAM_NAME){}
    @AuraEnabled
    public static LightningResponse checkPermissions(){
        LightningResponse response = new LightningResponse();
        List<Object> records;
        Boolean canCreate = Schema.sObjectType.Event.isCreateable();
        Boolean canUpdate = Schema.sObjectType.Event.isUpdateable() && Schema.sObjectType.Event.fields.IsAllDayEvent.isAccessible();
        Boolean canRead   = Schema.sObjectType.Event.fields.IsAllDayEvent.isAccessible();
        Boolean canSearch = Schema.sObjectType.Event.isSearchable();
 
        
        Map<String,Object> result  = new Map<String,Object>();
        result.put('canCreate', canCreate);
        result.put('canUpdate', canUpdate);
        result.put('canRead', canRead);
        response.jsonResponse = JSON.serialize(result);
        
        return response;
    }


    /*
    * @description
    *   Query Records by Id list for the corresponding Object.
    * @params
    *   List<Id>
    * @return
    *   CalendarEventModel
    */
    private static CalendarEventModel populateDraftEvents(List<Id> idList) {
        CalendarEventModel result = new CalendarEventModel();
        try {
            //retrieve first Id to resolve SObject type
            Schema.SObjectType objectName = idList[0].getSObjectType();
            String objName = objectName.getDescribe().getName();
            Id whoId;
            String whoName = null;
            Id whatId;
            String whatName = null;

            String fieldList = ' Id, Name ';
            Boolean hasPersonAccount = checkForSchemaFieldActive('ispersonaccount');

            if (objName == 'Contact'){
                fieldList +=', AccountId ';//Account.isPersonAccount
                if (hasPersonAccount)
                    fieldList +=', IsPersonAccount, Account.Name ';//
            }

            if (objName == 'Account'){
                fieldList +=',  (select Name from Contacts) ';
                if (hasPersonAccount)
                    fieldList +=', isPersonAccount  '; 
            }

            String queryString = ' SELECT '+fieldList+' FROM ' + objName +
                                 ' WHERE Id IN :idList';
            Event draftEvent;
            String subject_attr;

            for(SObject obj : Database.query(queryString)){
                draftEvent = new Event();

                draftEvent.Subject  = '';
                draftEvent.OwnerId  = UserInfo.getUserId();
                draftEvent.IsAllDayEvent = false;
                //if it's a contact
                if (objName == 'contact'){
                    Contact c = (Contact)JSON.deserialize(JSON.serialize(obj), Contact.class);
                    whoId = c.Id;
                    whoName = c.Name;
                     //if its related account IsPersonAccount, we get the whatId
                    if (hasPersonAccount){
                        Map<String,Object> objAsMap = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(obj));
                        Boolean isPersonAccount = Boolean.valueof(objAsMap.get('IsPersonAccount'));
                        if (isPersonAccount && Schema.SObjectType.Account.isAccessible()){
                            whatId = c.Account.Id;
                            whatName = c.Account.Name;
                        }
                    }
                }
                //if it's a lead
                if (objName == 'lead'){
                    Lead l = (Lead)JSON.deserialize(JSON.serialize(obj), Lead.class);
                    whoId = l.Id;
                    whoName = l.Name;
                }
                 //if it's a account
                if (objName == 'account'){
                    Account ac = (Account)JSON.deserialize(JSON.serialize(obj), Account.class);
                    whatId = ac.Id;
                    whatName = ac.Name;
                    //if it's a person account we add the contact
                    if (hasPersonAccount){
                        Map<String,Object> objAsMap = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(obj));
                        Boolean isPersonAccount = Boolean.valueof(objAsMap.get('IsPersonAccount'));
                        if (isPersonAccount){
                            List<Contact> lc =  ac.Contacts;
                        if (!lc.isEmpty())
                            whoId = lc.get(0).Id;
                            whoName = lc.get(0).Name;
                        }
                    }
                }             
                if(String.isNotBlank(whoName)){
                    String apiName = objName == 'lead' ? 'Lead' : 'Contact';
                    Map<String,String> relatedPersonMap = new Map<String,String>();
                    relatedPersonMap.put('Name', whoName);
                    relatedPersonMap.put('ObjApiName', apiName);
                    draftEvent.WhoId = whoId;
                    result.eventRelatedPersonMap.put(whoId, relatedPersonMap);
                }
                if(String.isNotBlank(whatName)){
                    draftEvent.WhatId = whatId;
                    result.eventRelatedObjectMap.put(whatId, whatName); 
                }
                result.draftEvents.add(draftEvent);
                whoName = null;
                whatName = null;
            }
            return result;
        } catch(Exception e) {
            return result;
        }
    }
    // FULL CALENDAR COMPONENT CONTROLLER METHODS START
    //************************************************************************
    // Static methods
    /*
    * @description
    *    Returns the selected records from the listview
    * @params
    *    DATA_TYPE PARAM_NAME PARAM_USED_FOR
    String evtId Id of the event
    String start_time Event start time
    String end_time Event end time
    String user_id Event's associated User Id
    String what_id Event's RelatedTo Object Id
    String sobjectName ApiName of the sObject
    String title Title of the Event
    * @return
    *    Returns a Boolean with the result of the operation
    */
    @auraEnabled
    public static LightningResponse rescheduleEvent( String evtId, String start_time) {
        
        LightningResponse response = new LightningResponse();
        List<Event> ls = [Select Id, DurationInMinutes, IsAllDayEvent, StartDateTime from Event where id=:evtId];
        Event e;
        if (!ls.isEmpty()) {
            try {
                e = ls.get(0);
                DateTime newStart = DateTime.valueOf(start_time);
                if(!e.IsAllDayEvent && e.DurationInMinutes >= MINS_PER_DAY) {
                    newStart = DateTime.newInstance(newStart.year(), newStart.month(), newStart.day(), e.StartDateTime.hour(), 
                    e.StartDateTime.minute(), e.StartDateTime.second()); 
                } else if(e.IsAllDayEvent) {
                    newStart = DateTime.valueOfGMT(start_time);
                } 
                e.StartDateTime = newStart;
                    
                update e;

                response.jsonResponse = JSON.serialize(e);
                
            } catch(DmlException ex) {
                response = new LightningResponse(ex);
                
            } catch(Exception exe) {
                response = new LightningResponse(exe);
            }
                
        } else {
            response.state = 'ERROR';
            response.error = 'Can not find event to update';
        }

        return response;
        
    }
   
    
    /*
    * @description
    *    Returns the events of the user for a specified time range
    * @params
    *    DATA_TYPE PARAM_NAME PARAM_USED_FOR
    DateTime start_time Event start time
    DateTime end_time Event end time
    String user_id Event's associated User Id
    * @return
    *    Returns a list with the events matching the criteria
    */
    @auraEnabled
    public static LightningResponse getEvents( String start_time, String end_time, String user_id ){
        LightningResponse response = new LightningResponse();
        Date dStartDate = Date.valueof(start_time);
        DateTime dEndDate   = DateTime.valueof(end_time);
        LIST<CustomEvent> listEvent = new LIST<CustomEvent>();
        if(Schema.sObjectType.Event.fields.IsAllDayEvent.isAccessible()) {
            for( Event a:[
                        SELECT StartDateTime, EndDateTime, Owner.Name, Subject ,IsAllDayEvent ,DurationInMinutes
                        FROM Event
                        WHERE
                        ( OwnerId =: user_id )
                        AND
                        (   ( StartDateTime >=: dStartDate AND EndDateTime <=: dEndDate ) // scope contains event
                            OR
                            (  ( StartDateTime >=: dStartDate AND StartDateTime <=: dEndDate) // scope partically contains event
                                OR  ( EndDateTime >=: dStartDate AND  EndDateTime <=: dEndDate )
                            )
                            OR
                            (   StartDateTime <=: dStartDate AND  EndDateTime >=: dEndDate )// event contains scope
                        )
                        LIMIT 50000
                    ]
           ){
               CustomEvent tmp = new CustomEvent(a);
               listEvent.add( tmp );
           }
        }
        
            response.jsonResponse = JSON.serialize(listEvent).replace('end_time_x', 'end');
        return     response;
    }



    /*
    * @description
    *   WHAT_THE_METHOD_DOES
    * @params
    *   DATA_TYPE PARAM_NAME PARAM_USED_FOR
    * @return
    *   DATA_TYPE
    */
    //public static DATA_TYPE some_method(DATA_TYPE, PARAM_NAME){}
    @AuraEnabled
    public static LightningResponse saveCurrentEvent(String newEvent){
        LightningResponse response = new LightningResponse();
       
        try{
            Event evtObject = (Event) JSON.deserialize(newEvent,Event.class);
           
            //convert  start-end time to gmt
            if(!evtObject.IsAllDayEvent) {
                Datetime std = evtObject.StartDateTime;
                DateTime StartDT = DateTime.newInstance(std.yearGMT(), std.monthGMT(), std.dayGMT(), 
                                                std.hourGMT(), std.minuteGMT(), std.secondGMT());
                evtObject.StartDateTime = StartDT;

                std = evtObject.EndDateTime;
                DateTime EndDT = DateTime.newInstance(std.yearGMT(), std.monthGMT(), std.dayGMT(), 
                                                std.hourGMT(), std.minuteGMT(), std.secondGMT());
                evtObject.EndDateTime = EndDT;
            }

            upsert evtObject;
            response.jsonResponse = JSON.serialize(evtObject);
        }
        catch(DmlException ex) {
            response = new LightningResponse(ex);
        }
         catch(Exception e) {
            response = new LightningResponse(e);
        }
        return response;
    }

    /*
    * @description
    *    Returns an event details
    * @params
    *    Id recordId id of the event to return
    * @return
    *    Returns a response object wrapping an event or an exception
    */
    @auraEnabled
    public static LightningResponse loadEventDetails( String recordId ){
        LightningResponse response = new LightningResponse();
        Event result = null;
        try{
            result = [
                    SELECT StartDateTime, EndDateTime, Owner.Name, Subject ,IsAllDayEvent ,Description, Location,
                        DurationInMinutes
                    FROM Event
                    WHERE
                        Id  =: recordId 
                    ];
            result.Subject = updateSubject(result.Subject);
            response.jsonResponse = JSON.serialize(result);
        }catch(Exception e){
            response = new LightningResponse(e);
        }
       
        return     response;
    }
    /*
    * @description
    *    Returns an trimmed subject for the event
    * @params
    *    String recordId id of the event to return
    * @return
    *    Returns a string with max length of 15 chars
    */
    private static String updateSubject(String subject){

        Integer maxLengthTitle = 30;
        if (subject.length() > maxLengthTitle){
            subject = subject.substring(0, maxLengthTitle)+'...';
        }
        return subject;
    }
    //************************************************************************
    // Inner classes
    public class CustomEvent{
        public String title {get;set;}
        public String start {get;set;}
        public String end_time_x {get;set;}
        public String id {get;set;}
        public String className {get;set;}
        public Boolean allDay {get;set;}
        public CustomEvent( Event e ){
            this.title = e.subject;
            this.allDay = e.IsAllDayEvent;
            if (this.allDay){
                this.start = e.StartDateTime.formatGMT('yyyy-MM-dd');
                Integer add_days = Integer.valueOf(Math.round(e.DurationInMinutes / MINS_PER_DAY));
                this.end_time_x = e.StartDateTime.addDays(add_days).formatGMT('yyyy-MM-dd');
                
            }else{
                if(e.DurationInMinutes >= MINS_PER_DAY) {
                    this.start = e.StartDateTime.format('yyyy-MM-dd');
                    if(e.StartDateTime.hour() == 0 && e.StartDateTime.minute() == 0 && Math.mod(e.DurationInMinutes, MINS_PER_DAY) == 0) {
                        this.end_time_x = e.EndDateTime.format('yyyy-MM-dd');

                    } else {
                        this.end_time_x = e.EndDateTime.addDays(1).format('yyyy-MM-dd');
                    }
                    this.allDay = true;
                    this.title = '('+e.StartDateTime.format('h:mm a')+') '+this.title;

                } else {
                    this.start = e.StartDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS');
                    this.end_time_x = e.EndDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS');
                }
                
            }
            this.id = e.Id;
        }
    }

    /*
	* @description
	*	Method that return a boolean to know if the fieldname exist on the fields of the schema
	* @params
	*	N/A
	* @return
	*	Boolean
	*/
	public static boolean checkForSchemaFieldActive(String fieldName){
		boolean boolFieldActive = false;
        if(Schema.getGlobalDescribe().get('Account') != null) {
            Schema.DescribeSObjectResult sor = Schema.getGlobalDescribe().get('Account').getDescribe();
            Map<String,Schema.SObjectField> sofs = sor.fields.getMap();
            Set<String> objectFields = sofs.keySet();
            boolFieldActive = objectFields.contains(fieldName);
        }
		return boolFieldActive;
	}
}