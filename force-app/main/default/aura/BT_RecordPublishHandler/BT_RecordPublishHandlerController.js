({
	init : function(component, event, helper) {
	   console.log(event.getParam('id'));
	   console.log(event);
	   var recordId =  event.getParam('id');
       var event = $A.get('e.force:navigateToSObject');
	            	event.setParams({
			            'recordId' :recordId
			        }).fire();
	},
    addHandleAppEvent : function(component, event, helper) {
        component.addEventHandler("force:recordPublished", component.getReference("c.init"));
    }
})