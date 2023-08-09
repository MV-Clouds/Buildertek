({
	doInit : function(component, event, helper) {
	     var recordId = component.get("v.recordId");
	    //alert("recordId -->  "+recordId);
	    var action = component.get("c.getQuoteRecordData");
	    action.setParams({
	        recordId : recordId
	    });
	    action.setCallback(this, function(response){
	        var state = response.getState();
	        if(state === "SUCCESS"){
	            var result =  response.getReturnValue();
	            component.set("v.QuoteRecord", result);
	            
	        }
	    });
	    $A.enqueueAction(action);
	}
})