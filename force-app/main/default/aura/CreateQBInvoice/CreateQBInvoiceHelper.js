({
    createInvoice : function(component, event, helper) {
        var action = component.get("c.Create_customer_item_invoice_in_QB_flow");
        action.setParams({
            Sales_invoice_Id : component.get("v.recordId") 
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state ==> ' + state);
            
            if(state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('return value ==> '+ result);
                $A.get("e.force:closeQuickAction").fire();
                if(result === true){
            		component.find('notifLib').showNotice({
    		            "variant": "success",
    		            "header": "Success",
    		            "message": "Completed",
    		            // closeCallback: function() {
    		            // 	$A.get('e.force:refreshView').fire();
    		            // 	var event = $A.get('e.force:navigateToSObject' );
    		            // 	event.setParams({
    				    //         'recordId' : response.getReturnValue().newRecordId
    				    //     }).fire();
    		            // }
    		        });    
                }else{
                    component.find('notifLib').showNotice({
    		            "variant": "error",
    		            "header": "Error",
    		            "message": 'Something Went Wrong !!!',
    		            // closeCallback: function() {
    		            	
    		            // }
    		        });    
                }
                
            }
        });
        
        $A.enqueueAction(action);	
    }
})