({
	handleEventIdUpdate : function(component, event, helper) {
		// If there are no fields
		var actionParams ={	recordId: component.get("v.recordId") };
		this.handleAction(component, actionParams, 'c.loadEventDetails', this.handleEventIdUpdateCallback);		
	
	},

	//Logic to run on success.
	handleEventIdUpdateCallback : function(component, response, ctx){
		var that = ctx;
		if (!$A.util.isUndefinedOrNull(response)){
			if(!component.isValid()) return;

            if(response.IsAllDayEvent){
                var startDatetime = response.StartDateTime;
                var endDatetime = response.EndDateTime;
                
                response.StartDateTime =  $A.localizationService.formatDateTimeUTC(startDatetime, "M/d/yyyy");
                response.EndDateTime =  $A.localizationService.formatDateTimeUTC(endDatetime, "M/d/yyyy");

            }
            
            component.set("v.eventRecord", response);
            
		}
	}
})