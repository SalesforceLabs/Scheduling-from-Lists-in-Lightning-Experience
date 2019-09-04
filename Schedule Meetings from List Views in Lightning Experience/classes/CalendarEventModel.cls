/**
* @author Altimetrik
* @description
* started on June 2018
* This class represents a draft event
**/

public with sharing class CalendarEventModel {
    public List<Event> draftEvents {get; set;}
    /* eventRelatedPersonMap manages the following fields by Id: Name, ObjApiName */
    public Map<Id,Map<String,String>> eventRelatedPersonMap {get; set;}
    public Map<Id,String> eventRelatedObjectMap {get; set;}
    public Id userId {get; set;}
    public String userName {get; set;}

    public CalendarEventModel(){
        draftEvents = new List<Event>();
        eventRelatedPersonMap = new Map<Id,Map<String,String>>();
        eventRelatedObjectMap = new Map<Id,String>();
        userId = UserInfo.getUserId();
        userName = UserInfo.getName();
    }
}