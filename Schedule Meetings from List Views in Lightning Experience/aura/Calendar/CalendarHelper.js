({
	//Deprecated Code
	doInit : function(component, event, helper) {
		// If there are no fields
		var actionParams ={};
		this.handleAction(component, actionParams, 'c.checkPermissions', this.checkPermissionsCallback);
		
	},

	//Logic to run on success.
	checkPermissionsCallback : function(component, response, ctx){
		var that = ctx;
		if (!$A.util.isUndefinedOrNull(response)){
			if(!component.isValid()) return;
			component.set("v.canReadEvents", response.canRead);
			component.set("v.canUpdateEvents", response.canUpdate);
			ctx.initCalendar(component, response, ctx);
		}
	},
	// End deprecated Code
	initCalendar : function(component,event,helper){	



		var userId = $A.get("$SObjectType.CurrentUser.Id");
		component.set("v.user_id", userId);
		var self = this;
		var timezone = $A.get("$Locale.timezone");
		moment.now = function() {
			return new Date().toLocaleString("en-US", {timeZone: timezone});
		}
		var draggedEventAllDay = false;
		var dragStarted = false;
		var canUpdateEvents = component.get("v.canUpdateEvents");
		var canReadEvents = component.get("v.canReadEvents");
		
		$('#calendar').fullCalendar({
	    	defaultView: 'agendaWeek',
	    	selectable: false,
			selectHelper: true,
			nowIndicator : true,
			editable  : canUpdateEvents,
			allDaySlot : true,
			eventDurationEditable : false,
			header: false, // buttons for switching between views
			timeFormat: 'h(:mm)a',
			agendaEventMinHeight: 20,
			height: window.innerHeight * 0.75,
			columnHeaderHtml: function(mom) {
				return  mom.format('ddd D') ;
			},
			eventAfterRender: function(event, element) {
				var thisTitle = event.title;
				var diffStart = moment().diff(event.start, 'minutes');
				var diffEnd = moment().diff(event.end, 'minutes');
				if (diffEnd > 0 || (!diffEnd && diffStart > 0)){
					element.addClass('pastEvent');
				}else{
					element.addClass('futureEvent');
				}

				if(event.id !== 'new') {
				    element.find('.fc-title').click(function(){
						helper.navigateToDetailPage(component, event.id);
					});
				}

				element.removeClass('fc-short');
				if(element.prop('offsetHeight') < element.prop('scrollHeight')) {
					element.addClass('detail-on-hover');
					if(event.start.hour() >= 16 && !element.hasClass('fc-not-start')) {
						element.addClass('late-event');
					} else {
						element.addClass('early-event');
					}
				}			
			},

            dayClick: function(date, jsEvent, view) {
				var canSelectAllDay = component.get("v.canSelectAllDay");
				var enabled = $('#calendar').fullCalendar('option', 'editable') && (!date.hasTime() && canSelectAllDay || date.hasTime());
				if ( ! canUpdateEvents || dragStarted) return;
				helper.hideModalView(component);
                var start = date.clone();
                var end = date.clone();
                
                if (end.hasTime()) {
                    end = start.clone();
                    end.add(60, 'minutes');
                }
                
                if(enabled){
                    $('#calendar').fullCalendar( 'removeEvents','new' );
                    
                    var tempEvent = {id : 'new',
                                     start : start,
                                     end : end,
                                     title : '[No Subject]',
                                     className : 'dummyEvent'
                                    };
                    
                    helper.triggerEvtSchedule(start,end,!date.hasTime());
                    
                    $('#calendar').fullCalendar( 'renderEvent', tempEvent );                
                    
                    $('#calendar').fullCalendar('unselect');
                } else {
                	
				    var params = {
				        "title" : "Looks like you don\'t have permission to perform this action.",
				        "type" : "error",
				        "message" : ""
				    };
				           
				    helper.showToast(component, null, null, params);
					//helper.showToast('error', 'Looks like you don\'t have permission to perform this action.', 
					//'Looks like you don\'t have permission to perform this action.');
				} 
                
            },
            
			select: function(start, end) {
				
				if ( ! canUpdateEvents) return;
				helper.hideModalView(component);

                if (end.hasTime()) {
                    end = start.clone();
                    end.add(60, 'minutes');
                }
                
                var tempEvent = {id : '',
                                 start : start,
                                 end : end,
                                 title : '[No Subject]',
								 className : 'dummyEvent'
                                };
                $('#calendar').fullCalendar( 'refetchEvents' );
                $('#calendar').fullCalendar( 'renderEvent', tempEvent );                

				helper.triggerEvtSchedule(start,end,false);
                
                $('#calendar').fullCalendar('unselect');
            },
            events: function(start, end, timezone, callback) {
				helper.loadEvents(
					component,
					start.subtract(1, 'days').format("YYYY-MM-DD HH:mm:ss"),
					end.format("YYYY-MM-DD HH:mm:ss"), 
					callback
				);
            },
            
            eventDragStart: function(calEvent, jsEvent, view) {
                
                
                
                    helper.hideModalView(component);
                    if (calEvent.id !== "new" || !$A.util.isEmpty(calEvent.id)){
                        draggedEventAllDay = calEvent.allDay;
                        dragStarted= true;
                    }else{
                        revertFunc();
                    }
            },

            eventClick: function(calEvent, jsEvent, view) {
				if (!$A.util.isEmpty(calEvent.id) && calEvent.id !== "new"){
					component.set('v.currentEventId',calEvent.id);
					helper.showModalView(calEvent,jsEvent,view);
				}	
			},

			eventMouseover : function(calEvent, jsEvent, view) {},
			
			eventDrop: function(event, delta, revertFunc) {
				dragStarted = false;
				helper.hideModalView(component);
				if((!event.allDay && draggedEventAllDay || event.allDay && !draggedEventAllDay  )
					|| $A.util.isEmpty(event.id) || event.id === "new"){
					revertFunc();
				}else{
					helper.rescheduleEvent(component,event, delta, helper);
				}
			
			},
			eventDragStop: function(event, delta) {
                $(this).mouseup();  // Fix to resolve dragging event out of the calendar issue              
                dragStarted = false;
			
			},
			eventResize: function(event, delta) {},

			viewRender : function( view, element ){
				helper.hideModalView(component);
				component.set('v.todayEnabled', moment().isBefore(view.end) && 
				    moment().isSameOrAfter(view.start));
				component.set('v.currentWeek', view.start.format("MMMM DD, YYYY") +
				    "–" + view.end.subtract(1,'days').format("MMMM DD, YYYY"));
			},
		});

		$(window).resize(function(){
			$('#calendar').fullCalendar('option', 'height', window.innerHeight * 0.75);
		});
	
	},

	loadEvents : function(component,start,end, calendarCallback) {

		var actionParams ={	start_time : start,
							end_time   : end,
							user_id    : $A.get("$SObjectType.CurrentUser.Id")	 };
		this.handleAction(component, actionParams, 'c.getEvents', function(component, response, ctx){
			calendarCallback(response);
		} );

	},
    rescheduleEvent : function(component,event, delta, helper) {
        var actionParams ={	
            evtId : event.id,
            start_time : event.start.format("YYYY-MM-DD HH:mm:ss")
		};
		this.handleAction(component, actionParams, 'c.rescheduleEvent', function(component, response, ctx){
                        
            var params = {
                "title" : 'Event was rescheduled',
                "type" : 'success',
                "message" : '',
            };            
            
            helper.showToast(component,event,helper, params);
			
		} );

	},

	showModalView : function(calEvent, jsEvent, view){
		var modalView = $('#modalView');
		if ($A.util.isUndefinedOrNull(modalView)) {
		} else {
			//slds-hide
			modalView.removeClass('slds-hide');
			modalView.addClass('slds-show');
			var pageHeight = document.documentElement.clientHeight + 20;
			var pageWidth = document.documentElement.clientWidth + 20 ;
			var modalH = 120;
			var modalW = 190;
			var modalTop = jsEvent.pageY;
			var modalLeft = jsEvent.pageX;

			if ((jsEvent.pageY + modalH) > pageHeight)
				modalTop = modalTop - modalH;
			if ((jsEvent.pageX + modalH) > pageHeight)
				modalLeft = modalLeft - modalH;

			modalView.css('top', modalTop);
			modalView.css('left', modalLeft);
		
		}
	},
	hideModalView : function (component) {
		var modalView = $('#modalView');

		if ($A.util.isUndefinedOrNull(modalView)) {
		} else {
			//slds-hide
			component.set("v.currentEventId", {});
			modalView.addClass('slds-hide');
			modalView.removeClass('slds-show');
		}
	},

	triggerEvtSchedule : function (start, end,isAllDay){
		var cmpEvent = $A.get("e.c:EvtSchedule");

			cmpEvent.setParams({
				"startDate" : start.format("YYYY-MM-DD"),
				"startTime" : start.format("HH:mm:ss"),
				"endDate"  : end.format("YYYY-MM-DD"), 
				"endTime"  : end.format("HH:mm:ss"),
				"start"	: start.format("YYYY-MM-DD HH:mm:ss"),
				"end" : end.format("YYYY-MM-DD HH:mm:ss"),
				"isAllDay" : isAllDay

			});
			cmpEvent.fire();

	}
})