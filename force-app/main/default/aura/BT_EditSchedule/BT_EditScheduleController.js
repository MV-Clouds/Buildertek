({
	doInit : function(component, event, helper) {
	    //alert('isOpen ------>'+component.get("v.isOpen"));
	    component.set("v.isOpen", true);
	    component.set("v.Spinner", true);
        var recordId = component.get("v.recordId");
        var action = component.get("c.getScheduleDetails");
        action.setParams({
            recordId : recordId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                if(result != undefined){
                    if(result.buildertek__Contractor__c != undefined){
                        component.find("accountId").set("v.value", result.buildertek__Contractor__c);         
                    }
                    component.set("v.Schedule", result);
                    component.set("v.Spinner", false);
                }
                //
            }
        });
        $A.enqueueAction(action);
	},
    
    UpdateRecord: function(component, event, helper) {
        component.set("v.isOpen", true);
        var scheduleRecord = component.get("v.Schedule");  
        var accountId = component.find("accountId").get("v.value");
        var action = component.get("c.updateSchedule");
        action.setParams({
            scheduleRecord : scheduleRecord,
            accountId : accountId
        });
        action.setCallback(this, function(response){
              component.set("v.isOpen", false);   
              component.set("v.Spinner", false);
              document.location.reload(true);
        });
        $A.enqueueAction(action);
    },
   
    closeModel: function(component, event, helper) {
        component.set("v.isOpen", false);
        document.location.reload(true);
    }
})