({
    handleClick: function (cmp, event, helper) {
        var namespace = cmp.getType().split(':')[0];
        var navEvt = $A.get("e." + namespace + ":EvtNavigateBack");
        if (!$A.util.isUndefinedOrNull(navEvt)) {
            navEvt.fire();
        }
    },

    saveEvent: function (component, event, helper) {
        var validlookupCmpAssignedTo = component.find('lookupAssignedTo').validateInput();
        var validRelatedTo = component.get("v.canEditRelatedTo") ? component.find('lookupRelatedTo').validateInput() : true;
        var validName = component.get("v.canEditName") ? component.find('lookupName').validateInput() : true;
        var validEvent = component.find('eventform').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);

        var datesAreValid = moment(component.get("v.newEvent.StartDateTime"))
            .isSameOrBefore(component.get("v.newEvent.EndDateTime"));
        var params = event.getParam('arguments');
        if(params && params.callback) {
            params.callback(validEvent && datesAreValid && validlookupCmpAssignedTo && validRelatedTo && validName);
        }
        if(!datesAreValid && validEvent) {
        
        	 var params = {
				        "title" : "Start value should be same or before than End value",
				        "type" : "error",
				        "message" : "Start field should be before or equals than End field"
				    };
				           
				    helper.showToast(component, null, null, params);
        }

        else if(validEvent && datesAreValid && validlookupCmpAssignedTo && validRelatedTo && validName) {
            helper.saveCurrentEvent(component, event, helper);
        }
    },

    
    handleScheduleEvt: function (component, event, helper) {
        var startDate = event.getParam("startDate");
        var startTime = event.getParam("startTime");
        var endDate = event.getParam("endDate");
        var endTime = event.getParam("endTime");
        var isAllDay = event.getParam("isAllDay");

        component.set("v.startDate", startDate);
        component.set("v.startTime", startTime);
        component.set("v.endDate", endDate);
        component.set("v.endTime", endTime);
        component.set("v.newEvent.IsAllDayEvent", isAllDay);

        var startDateTimeString = helper.fixDateTimeFormat(startDate, startTime, isAllDay);
        var endDateTimeString = helper.fixDateTimeFormat(endDate, endTime, isAllDay);
        component.set("v.newEvent.StartDateTime", startDateTimeString);
        component.set("v.newEvent.EndDateTime", endDateTimeString);

    },

    changeStartOrEnd: function (component, event, helper) {
        var startDate = component.get("v.startDate");
        var startTime = component.get("v.startTime");
        var endDate = component.get("v.endDate");
        var endTime = component.get("v.endTime");
        var isAllDay = component.get("v.newEvent.IsAllDayEvent");

        //alse update newEvent details
        var startDateTimeString = helper.fixDateTimeFormat(startDate, startTime, isAllDay);
        var endDateTimeString = helper.fixDateTimeFormat(endDate, endTime, isAllDay);
        
        component.set("v.newEvent.StartDateTime", startDateTimeString);
        component.set("v.newEvent.EndDateTime", endDateTimeString);
        var startDtMoment = moment(startDateTimeString);
        var endDtMoment = moment(endDateTimeString);

        if(endDtMoment.diff(startDtMoment, 'minutes') >= 1440){
            isAllDay = true;
        }
        
        if (isAllDay != null && startDate && endDate) {
            var changeEvt = $A.get("e.c:EvtResize");
            if(isAllDay)
            	var newEndDate = moment(endDate).add(1, 'days').format("YYYY-MM-DD");
                        
            changeEvt.setParams({
                "start": startDateTimeString,
                "end": isAllDay ? newEndDate : endDateTimeString,
                "isAllDay": isAllDay
            });

            changeEvt.fire();
        }
    },
	handleRelatedPersonNameChange : function (component, event, helper){
        if (event.getParam("value") == 'Lead'){
            component.set("v.newEvent.WhatId", null);
            component.set("v.relatedObjectName", null);
        }
	}
})