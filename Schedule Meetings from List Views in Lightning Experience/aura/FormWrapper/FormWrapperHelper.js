({
	saveCurrentEvent : function(component, event, helper) {
		if (!$A.util.isUndefinedOrNull(component.get("v.newEvent") )) {
			var newEvent = component.get("v.newEvent");
			var actionParams ={	newEvent: JSON.stringify(newEvent) };
			this.handleAction(component, actionParams, 'c.saveCurrentEvent', this.saveSuccessCallback, this.saveErrorCallback);			
		}
	},
	saveSuccessCallback : function(component, response, ctx){
		var that = ctx;
		if (!$A.util.isUndefinedOrNull(response)){
			if(!component.isValid()) return;
			ctx.clearFormValues(component);
			var navEvt = $A.get("e.c:EvtSaveSuccess");
			if (!$A.util.isUndefinedOrNull(navEvt)){
				navEvt.setParams({
					subject: response.Subject
				});                
				navEvt.fire();
			}
		}
	},
	saveErrorCallback : function(component,  errorTitle, errorMessage){
		if(!component.isValid()) return;
	
        var navEvt = $A.get("e.c:EvtSaveError");
		if (!$A.util.isUndefinedOrNull(navEvt)){
			navEvt.setParams({
				"title" : errorTitle,
				"type" : 'error',
				"message" : errorMessage
			});
			navEvt.fire();
		}
	},
	clearFormValues : function (component){
		component.set("v.startDate",null);
		component.set("v.startTime",null);
		component.set("v.endDate",null);
		component.set("v.endTime",null);
		component.set("v.newEvent",{'sObjectType':'Event'});
		component.set("v.relatedObjectName", null);
		component.set("v.relatedPersonName", null);
		component.set("v.relatedPersonObjApiName", 'Contact');
		component.set("v.relatedToObjApiName", 'Account');
		component.set("v.assignedToName", null);
	},

    fixDateTimeFormat : function (date, time, isAllDay){
		if(!time || isAllDay) {
			time = '00:00:00.000';
		}
		var originalString = date + 'T' + time;
        return originalString;
	}
})