({
	fetchCalenderEvents : function(component, event, helper) {
        var action = component.get("c.fetchAllEvents");
       
         action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data= response.getReturnValue();
                console.log('data'+JSON.stringify(data));
                var josnArr = this.formatFullCalendarData(component,response.getReturnValue());
                this.loadDataToCalendar(component,josnArr);
                component.set("v.Objectlist",josnArr);
           
            } else if (state === "ERROR") {
                                 
            }
        });
        
        $A.enqueueAction(action);
    },
    
    formatFullCalendarData : function(component,events) {
        var josnDataArray = [];
        for(var i = 0;i < events.length;i++){
            var startdate = (events[i].StartDateTime);//$A.localizationService.formatDate(events[i].StartDateTime);
            var enddate = (events[i].EndDateTime);//$A.localizationService.formatDate(events[i].EndDateTime);
            josnDataArray.push({
                'title':events[i].Subject,
                'start':startdate,
                'end':enddate,
                'id':events[i].Id
            });
        }
      
        return josnDataArray;
    },
    
    loadDataToCalendar :function (component,data) {  
        $('#calendar').fullCalendar({
            header: {
                left: 'prev',
                center: 'title',
                right: 'next'
            },
            height:250,
            aspectRatio: 1,
            events:data,
            contentHeight:'auto',
            eventLimit: true,
            displayEventTime: false,
            eventColor: '#334048',
            eventClick: function(event) {
                console.log(event.id);
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                  "recordId": event.id
                });
                navEvt.fire();
           }
        });
    }
})