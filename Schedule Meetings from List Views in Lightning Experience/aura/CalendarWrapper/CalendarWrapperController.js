({
    doInit : function(component, event, helper) {
        var selRecords = component.get("v.selectedRecords");
        component.set("v.namespace", component.getType().split(':')[0]);
   
	    helper.doInit(component, event, helper);
    },
    
    doCancel : function(component, event, helper) {
        helper.goBack(component, event, helper);
    },

    doSave : function(component, event, helper) {
        helper.triggerEventSave(component, false);
    },

    doSaveAndNew : function(component, event, helper) {
        helper.triggerEventSave(component, true);
    },
    
    handleEvtSaveSuccess : function  (component, event, helper){
    	var subject = event.getParam("subject");
        var afterSaveLoadNext = component.get("v.afterSaveLoadNext");
        
        var params = {
            title : 'Event '+ subject + ' was created',
            type : 'success',
            message : ''
           
        };
 
        helper.showToast(component, event, helper, params);
        component.set("v.disableSave", false);
        if (!afterSaveLoadNext){
            
            $('#calendar').fullCalendar('option', {
                editable: false
            });
            
            setTimeout(function(){
                var targetCmp = component.find('toastSuccessMessage');
                $A.util.toggleClass(targetCmp, 'slds-hidden');
            }, 1500);
            setTimeout(function(){
                helper.goBack(component, event, helper);
            }, 1500);            
           
        }else{
            helper.setCalendarItems(component);
            //trigger EvtReloadEvents
            var namespace = component.getType().split(':')[0];
            var reloadEvt = $A.get("e."+namespace+":EvtReloadEvents");
            if (!$A.util.isUndefinedOrNull(reloadEvt)){
                reloadEvt.fire();
            }
        }
    },
    
    handleEvtSaveError : function  (component, event, helper){
       
       var params = {
            title : event.getParam("title"),
            type : 'error',
            message : event.getParam("message")
        };
       component.set("v.disableSave", false);
       helper.showToast(component, event, helper, params);      
    },
    
    closeToastSuccess : function  (component, event, helper){

 	    var targetCmp = component.find('toastSuccessMessage');
        $A.util.toggleClass(targetCmp, 'slds-hidden');
          
    },
    
    closeToastError : function  (component, event, helper){
 	    var targetCmp = component.find('toastErrorMessage');
        $A.util.toggleClass(targetCmp, 'slds-hidden');
          
    },
    
    showToast : function  (component, event, helper){
        
        var params = {
            title : event.getParam("title"),
            type : event.getParam("type"),
            message : event.getParam("message")
        };
        
        helper.showToast(component, event, helper, params);
          
    }
})