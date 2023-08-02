({
	doInit : function(component, event, helper) {
	var action = component.get("c.createRFQFromQuote");
        action.setParams({ 
            QuoteId : component.get("v.recordId"), 
            selectQuoteItemId : component.get("v.selectedQuoteItem")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result.isSuccess == true){
                    $A.get("e.force:closeQuickAction").fire();
            		component.find('notifLib').showNotice({
    		            "variant": "success",
    		            "header": "Success",
    		            "message": "RFQ created.",
    		            closeCallback: function() {
    		            	$A.get('e.force:refreshView').fire();
    		            	var event = $A.get('e.force:navigateToSObject' );
    		            	event.setParams({
    				            'recordId' : result.strRecordId
    				        }).fire();
    		            }
    		        });    
                }else{
                    component.find('notifLib').showNotice({
    		            "variant": "error",
        				"header": "Error",
        				"message": result.strMessage,
        				closeCallback: function () {}
    		        });    
                }
                
            }
        });
        
        $A.enqueueAction(action); 
	}
})