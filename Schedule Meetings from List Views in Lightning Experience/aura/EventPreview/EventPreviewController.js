({
	handleEventIdUpdate : function(component, event, helper) {
		
		if (!$A.util.isUndefinedOrNull(component.get("v.recordId") ) && typeof component.get("v.recordId") == 'string') {
			helper.handleEventIdUpdate(component, event, helper);
		}else{
		}
	},
	handleClose : function (component, event, helper) {
		var modalView = $('#modalView');

		if ($A.util.isUndefinedOrNull(modalView)) {
		} else {
			//slds-hide
			component.set("v.eventRecord", {});
			component.set("v.recordId", null);
			modalView.addClass('slds-hide');
			modalView.removeClass('slds-show');
		}
	},
	navigateToEvent : function(component, event, helper) {
		var rId = component.get("v.recordId");
		helper.navigateToDetailPage(component, rId);
	}

})