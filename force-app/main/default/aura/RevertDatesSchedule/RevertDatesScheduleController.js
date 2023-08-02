({
	doInit : function(component, event, helper) {
        component.set("v.isOpen", true);
	    
	},
	
	closeModel : function(component, event, helper) {
	    component.set("v.isOpen", false);
	    var url = location.href;
        var baseURL = url.substring(0, url.indexOf('--', 0));
        var recordId = component.get("v.RecordId");
        window.open(baseURL+'.lightning.force.com/lightning/r/buildertek__Schedule__c/'+escape(recordId)+'/view', '_self');
	},
	RevertTaskrecords : function(component, event, helper) {
	    var action = component.get("c.revertScheduletaskdates");
	    
	    action.setParams({
	        recordId : component.get("v.RecordId")
	    });
	    action.setCallback(this, function(response){
	        var state = response.getState();
	        var recordId = component.get("v.RecordId");
	        var url = location.href;
            var baseURL = url.substring(0, url.indexOf('--', 0));
	        if(state === "SUCCESS"){
                 window.open(baseURL+'.lightning.force.com/lightning/r/buildertek__Schedule__c/'+escape(recordId)+'/view', '_self');
	            
	        }
	    });
	    $A.enqueueAction(action);
	}
	
})