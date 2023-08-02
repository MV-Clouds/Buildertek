({
    doInit : function(component, event, helper) {
        var contractId = component.get("v.recordId");
	    var stage = component.get("v.contract.buildertek__Status__c");
	    component.set("v.Spinner", true);
	    if(stage == 'Accepted' || stage == 'Approved' || stage == 'Out for Bid' || stage =='Out for Signature' ){
	        $A.get("e.force:closeQuickAction").fire();
	        alert('You Cannot Delete this record as status is '+stage);
    		var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
              "recordId": contractId,
              "slideDevName": "related"
            });
            navEvt.fire();
	    }
	    component.set("v.Spinner", false);
	},
	
	deleteContract : function(component, event, helper) {
	    //component.set("v.Spinner", false);
	    var Name = component.get("v.contract.Name");
	    var contractId = component.get("v.recordId");
	    var action = component.get("c.deleteContractRecord");
	    action.setParams({
	        recordId : contractId
	    });
	    action.setCallback(this, function(response){
	        var state = response.getState();
	        if(state === "SUCCESS"){
	            //$A.enqueueAction(component.get('c.gotoList'));
	            var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'sticky',
                    message: "contract '" +Name+ "' was deleted",
                    type : 'success',
                    duration: '6000',
                    mode: 'dismissible'
                });
                toastEvent.fire();
	            var url = location.href;
                var baseURL = url.substring(0, url.indexOf('/', 14));
                $A.get("e.force:navigateToURL").setParams({ 
                   "url": baseURL+'/one/one.app?source=aloha#/sObject/buildertek__Contract__c/home' 
                }).fire();
	        }
	    });
	    $A.enqueueAction(action);
	},
	
	closeModal : function(component, event, helper) {
	    $A.get("e.force:closeQuickAction").fire();
	}
})