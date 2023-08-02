({
	doInit : function(component, event, helper) {
	    var recordId = component.get("v.recordId");
	    //alert("recordId -->  "+recordId);
	    var action = component.get("c.getPurchaseOrderRecordData");
	    action.setParams({
	        "recordId" : recordId
	    });
	    action.setCallback(this, function(response){
	        var state = response.getState();
	        if(state === "SUCCESS"){
	            var result =  response.getReturnValue();
	            component.set("v.PurchaseOrderRecord", result);
	           helper.updateProductQuantity(component, event, helper);
	        }
	    });
	    $A.enqueueAction(action);
	}
})