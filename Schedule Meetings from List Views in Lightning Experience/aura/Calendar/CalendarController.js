({
	doInit: function(component, event, helper){
		helper.initCalendar(component, event, helper);
	},
	
	
	loadCalendar: function(component, event, helper) {
		component.set("v.user_id", event.getParam("calendarUserId"));
		$('#calendar').fullCalendar( 'refetchEvents' );
	},
	recordSelected: function(component, event, helper) {		
		component.set( "v.recordId", event.getParam("recordid") );
		component.set( "v.sObjectName", event.getParam("sobjectname") );		
	},
	clickNextArrow: function(component, event, helper) {
		$('#calendar').fullCalendar('next');
	},
	clickPreviousArrow: function(component, event, helper) {
		$('#calendar').fullCalendar('prev');
	},
	clickThisWeek: function(component, event, helper) {
		$('#calendar').fullCalendar('today');
		
	},
    
    handleEvtResize : function(component, event, helper) {
		
        var end = event.getParam("end");
		var start = event.getParam("start");
		var isAllDay  = event.getParam("isAllDay")
        
        $('#calendar').fullCalendar( 'removeEvents','new' );
        
        var tempEvent = {id : 'new',
                         start : start,
                         end : end,
                         title : '[No Subject]',
						 className : 'dummyEvent',
						 allDay : isAllDay
						};
						
        $('#calendar').fullCalendar( 'renderEvent', tempEvent ); 
        
	},
	
	handleEvtReloadEvents: function (component, event, helper) {
		$('#calendar').fullCalendar( 'refetchEvents' );
	}
})