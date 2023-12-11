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
                if(result == 'success'){
            		component.find('notifLib').showNotice({
    		            "variant": "success",
    		            "header": "Success",
    		            "message": "Completed",
    		        });    
                }else if(result == 'no_invoicelines') {
                    component.find('notifLib').showNotice({
    		            "variant": "error",
    		            "header": "Error",
    		            "message": 'There are no Invoice Line (AR) associated with the Sales Invoice.',
    		        });    
                }else if(result == 'no_customer_account'){
                    component.find('notifLib').showNotice({
    		            "variant": "error",
    		            "header": "Error",
    		            "message": 'There are no Customer account associated with the Invoice.',
    		        });  
                }else{
                    component.find('notifLib').showNotice({
    		            "variant": "error",
    		            "header": "Error",
    		            "message": 'Something Went Wrong !!!',
    		        });  
                }
                
            }
        });
        
        $A.enqueueAction(action);	
    }
})