({
    doInit : function(component, event, helper) {
        var RFQId = component.get("v.recordId");
	    var stage = component.get("v.RFQ.buildertek__Status__c");
	    component.set("v.Spinner", true);
	    if(stage == 'Awarded' || stage == 'Accepted' || stage == 'Request Sent'){
	        $A.get("e.force:closeQuickAction").fire();
	        alert('You Cannot Delete this record as status is '+stage);
    		var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
              "recordId": RFQId,
              "slideDevName": "related"
            });
            navEvt.fire();
	    }
	    component.set("v.Spinner", false);
	},
	
	deleteRFQ : function(component, event, helper) {
	    //component.set("v.Spinner", false);
	    var Name = component.get("v.RFQ.Name");
	    var RFQId = component.get("v.recordId");
	    var action = component.get("c.deleteRFQsRecord");
	    
	    action.setParams({
	        recordId : RFQId
	    });
	    action.setCallback(this, function(response){
	        var state = response.getState();
	        if(state === "SUCCESS"){
	            //$A.enqueueAction(component.get('c.gotoList'));
	            var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'sticky',
                    message: "RFQ '" +Name+ "' was deleted",
                    type : 'success',
                    duration: '6000',
                    mode: 'dismissible'
                });
                toastEvent.fire();
	            var url = location.href;
                var baseURL = url.substring(0, url.indexOf('/', 14));
                $A.get("e.force:navigateToURL").setParams({ 
                   "url": baseURL+'/one/one.app?source=aloha#/sObject/buildertek__RFQ__c/home' 
                }).fire();
	        }
	    });
	    $A.enqueueAction(action);
	},
	
	closeModal : function(component, event, helper) {
	    $A.get("e.force:closeQuickAction").fire();
	}
})