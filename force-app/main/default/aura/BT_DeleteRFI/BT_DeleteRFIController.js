({
    doInit : function(component, event, helper) {
        var rfiId = component.get("v.recordId");
	    var stage = component.get("v.RFI.buildertek__Status__c");
	    component.set("v.Spinner", true);
	    if(stage == 'Submitted' || stage == 'Completed'){
	        $A.get("e.force:closeQuickAction").fire();
	        alert('You Cannot Delete this record as status is '+stage);
    		var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
              "recordId": rfiId,
              "slideDevName": "related"
            });
            navEvt.fire();
	    }
	    component.set("v.Spinner", false);
	},
	
	deleteRFI : function(component, event, helper) {
	    //component.set("v.Spinner", false);
	    var Name = component.get("v.RFI.Name");
	    var rfiId = component.get("v.recordId");
	    var action = component.get("c.deleteRFIsRecord");
	    action.setParams({
	        recordId : rfiId
	    });
	    action.setCallback(this, function(response){
	        var state = response.getState();
	        if(state === "SUCCESS"){
	            //$A.enqueueAction(component.get('c.gotoList'));
	            var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'sticky',
                    message: "RFI '" +Name+ "' was deleted",
                    type : 'success',
                    duration: '6000',
                    mode: 'dismissible'
                });
                toastEvent.fire();
	            var url = location.href;
                var baseURL = url.substring(0, url.indexOf('/', 14));
                $A.get("e.force:navigateToURL").setParams({ 
                   "url": baseURL+'/one/one.app?source=aloha#/sObject/buildertek__RFI__c/home' 
                }).fire();
	        }
	    });
	    $A.enqueueAction(action);
	},
	
	closeModal : function(component, event, helper) {
	    $A.get("e.force:closeQuickAction").fire();
	}
})