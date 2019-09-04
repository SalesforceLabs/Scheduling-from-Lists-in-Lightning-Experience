({
	doInit : function(component, event, helper) {
		this.toggleSpinner(component,true);
		// If there are no fields
		if (!$A.util.isUndefinedOrNull(component.get("v.selectedRecords") )) {
			var selRecordsList = component.get("v.selectedRecords");

            var i;
            var selRecords = "";
            for (i = 0; i < selRecordsList.length; i++) { 
                selRecords += selRecordsList[i].Id + ",";
            }

			if (!$A.util.isEmpty(selRecords)){
				var actionParams ={	recordIds: selRecords };
				this.handleAction(component, actionParams, 'c.loadInitialData', this.doInitCallback);
			}else{
				component.set("v.noRecordsSelected",true);
				this.toggleSpinner(component,false);
			}
			
		}
	},
	setCalendarItems : function(component, draftEvents, eventRelatedPersonMap, eventRelatedObjectMap, assignedToName){
		var draftEvents = draftEvents || component.get("v.draftEvents");
		var currentIndex = component.get("v.currentIndex");
		var eventRelatedPersonMap = eventRelatedPersonMap || component.get("v.eventRelatedPersonMap");
		var eventRelatedObjectMap = eventRelatedObjectMap || component.get("v.eventRelatedObjectMap");
		var assignedToName = assignedToName || component.get("v.currentUserName");
		var maxIndex = draftEvents.length - 1;
		var currentEvent = maxIndex > -1 && draftEvents[currentIndex];
		var relatedPersonName = currentEvent && currentEvent.WhoId && eventRelatedPersonMap[currentEvent.WhoId]['Name'];
		var relatedPersonObjApiName = currentEvent && currentEvent.WhoId && eventRelatedPersonMap[currentEvent.WhoId]['ObjApiName'] || 'Contact';
		var relatedObjectName = currentEvent && currentEvent.WhatId && eventRelatedObjectMap[currentEvent.WhatId];
		component.set("v.assignedToName", assignedToName);
		component.set("v.currentDraftEvent", currentEvent);
		component.set("v.relatedPersonName", relatedPersonName);			
		component.set("v.relatedObjectName", relatedObjectName);
		component.set("v.relatedPersonObjApiName", relatedPersonObjApiName);
		component.set("v.disableSaveAndNew", currentIndex >= maxIndex);	
		currentIndex++;
		component.set("v.currentIndex",currentIndex);
	},
	//Logic to run on success.
	doInitCallback : function(component, response, ctx){
		var that = ctx;
		if (!$A.util.isUndefinedOrNull(response)){
			if(!component.isValid()) return;
			component.set("v.draftEvents", response.draftEvents);
			component.set("v.eventRelatedPersonMap",response.eventRelatedPersonMap);
			component.set("v.eventRelatedObjectMap",response.eventRelatedObjectMap);
			component.set("v.currentUserName", response.currentUserName);
			ctx.setCalendarItems(component, response.draftEvents, response.eventRelatedPersonMap, response.eventRelatedObjectMap, response.currentUserName);
			component.set("v.canReadEvents", response.canRead);
			component.set("v.canUpdateEvents", response.canUpdate);
			component.set("v.canEditAllDay", response.canEditAllDay);
			component.set("v.canEditName", response.canEditName);
			component.set("v.canEditRelatedTo", response.canEditRelatedTo);
			component.set("v.loadComplete", true);
			ctx.toggleSpinner(component,false);
		}
	},	
	goBack : function(component, event, helper) {
        var namespace = component.getType().split(':')[0];
        var navEvt = $A.get("e."+namespace+":EvtNavigateBack");
        if (!$A.util.isUndefinedOrNull(navEvt)){
            navEvt.setParams({
				showToast : true
			});
            navEvt.fire();
        }
	},
	toggleSpinner : function(component, show){
		var elem = component.find("spinnerContainer");
		if (!$A.util.isUndefinedOrNull(elem)){
			if(show){
				$A.util.addClass(elem, 'slds-visible');
				$A.util.removeClass(elem, 'slds-hidden');
			}else{
				$A.util.removeClass(elem, 'slds-visible');
				$A.util.addClass(elem, 'slds-hidden');
			}
		}
	},
	triggerEventSave : function(component, afterSaveLoadNext) {
		component.set("v.disableSave", true);
        //load next record
        component.set("v.afterSaveLoadNext", afterSaveLoadNext);
        //fire save on formComponent
        var form = component.find("event-form");
        form.saveEvent(function(validForm) {
			component.set("v.disableSave", validForm);
        });
    },
    
    showToast : function (cmp, event, helper, params){
        var message =  helper.decodeText(params.message);
        var title = helper.decodeText(params.title);
        
        cmp.set('v.toastSuccessTitle', title);
        
        var targetCmp = cmp.find('toastSuccessMessage');

        if (params.type == 'error'){
            
            cmp.set('v.toastErrorBody', message);
            cmp.set('v.toastErrorTitle', title);
            targetCmp = cmp.find('toastErrorMessage'); 

        }else{

            cmp.set('v.toastSuccessBody', message);
            cmp.set('v.toastSuccessTitle', title);
        }

        $A.util.toggleClass(targetCmp, 'slds-hidden');

        setTimeout(function(){
            var toastVisible = !$A.util.hasClass(targetCmp, 'slds-hidden');

            if(toastVisible){
                $A.getCallback(function() {
                    $A.util.toggleClass(targetCmp, 'slds-hidden');
                })();
            }
        }, 1500);

    },
    
    decodeText : function(stringToDecode){
        var parser = new DOMParser;
            var dom = parser.parseFromString(
                '<!doctype html><body>' + stringToDecode,
                'text/html');
            return dom.body.textContent;
    }
})