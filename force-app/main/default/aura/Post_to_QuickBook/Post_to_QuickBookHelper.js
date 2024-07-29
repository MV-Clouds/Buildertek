({
    SyncSIInvoice : function(component, event, helper){
        console.log('inside SyncCOInvoice');
        var action = component.get("c.sync_Invoice_in_QB_AuraCallout");
        action.setParams({
            recordId : component.get("v.recordId"),
            SyncObjName : component.get("v.sobjecttype")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state ==> ' + state);
            var result = response.getReturnValue();
            console.log('return value ==> '+ result);

            if(state === "SUCCESS") {
                if(result != null){
                    helper.ShowResponsePopupHelper(component, event, helper, result, result);
                }
                else{
                    component.find('notifLib').showNotice({
    		            "variant": "error",
    		            "header": "Warning!",
    		            "message": 'Something Went Wrong !!!',
    		        });  
                }
                $A.get("e.force:closeQuickAction").fire();
                
            }
            
        });
        $A.enqueueAction(action);	
    },

    SyncCOInvoice: function(component, event, helper){
        console.log('inside SyncCOInvoice');
        var action = component.get("c.sync_Contractor_Invoice_to_Bill_in_QB_AuraCallout");
        action.setParams({
            recordId : component.get("v.recordId"),
            SyncObjName : component.get("v.sobjecttype")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state ==> ' + state);
            var result = response.getReturnValue();
            console.log('return value ==> '+ result);

            if(state === "SUCCESS") {
                $A.get("e.force:closeQuickAction").fire();
                if(result != null){
                    helper.ShowResponsePopupHelper(component, event, helper, result, result);
                }
                else{
                    component.find('notifLib').showNotice({
    		            "variant": "error",
    		            "header": "Warning!",
    		            "message": 'Something Went Wrong !!!',
    		        });  
                }
                
            }
            
        });
        $A.enqueueAction(action);	
    },

    SyncPayableInvoice: function(component, event, helper){
        console.log('inside SyncCOInvoice');
        var action = component.get("c.sync_Payable_Invoice_to_Bill_in_QB_AuraCallout");
        action.setParams({
            recordId : component.get("v.recordId"),
            SyncObjName : component.get("v.sobjecttype")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state ==> ' + state);
            var result = response.getReturnValue();
            console.log('return value ==> '+ result);

            if(state === "SUCCESS") {
                $A.get("e.force:closeQuickAction").fire();
                if(result != null){
                    helper.ShowResponsePopupHelper(component, event, helper, result, result);
                }
                else{
                    component.find('notifLib').showNotice({
    		            "variant": "error",
    		            "header": "Warning!",
    		            "message": 'Something Went Wrong !!!',
    		        });  
                }
                
            }
            
        });
        $A.enqueueAction(action);	
    },

    SyncPO : function(component, event, helper) {
        var action = component.get("c.sync_Purchase_Order_in_QB_AuraCallout");
        action.setParams({
            recordId : component.get("v.recordId"),
            SyncObjName : component.get("v.sobjecttype")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state ==> ' + state);
            
            if(state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('return value ==> '+ result);
                $A.get("e.force:closeQuickAction").fire();
                if(result != null){
                    helper.ShowResponsePopupHelper(component, event, helper, result, result);
                }
                else{
                    component.find('notifLib').showNotice({
    		            "variant": "error",
    		            "header": "Warning!",
    		            "message": 'Something Went Wrong !!!',
    		        });  
                }
                
            }
        });
        
        $A.enqueueAction(action);	
    },

    SyncAccountToQuickbook: function(component, event, helper){
        var accountType = component.get("v.AccountType");
        if(accountType == 'Customer'){
            component.set("v.ShowAccountTypeOpt", false);
            helper.Post_Customer_ToQBHelper(component, event, helper);
        }
        else if(accountType == 'Vendor'){
            component.set("v.ShowAccountTypeOpt", false);
            helper.Post_Vendor_ToQBHelper(component, event, helper);
        }
        else{
            component.find('notifLib').showNotice({
                "variant": "warning",
                "header": "Validation Warning",
                "message": 'Account type must be Customer or Vendor to sync with QB',
            });    
            $A.get("e.force:closeQuickAction").fire();
        }
    },

    Post_Customer_ToQBHelper: function(component, event, helper){
        console.log("Inside Customer Integration helper");
        var action = component.get("c.sync_Customer_In_QB_AuraCallout");
        action.setParams({
            recordId : component.get("v.recordId"),
            SyncObjName : component.get("v.sObjectName")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('Customer state ==> ' + state);
            var result = response.getReturnValue();
            console.log('Customer result ==> ' + result);
   
            if(result != null){
                helper.ShowResponsePopupHelper(component, event, helper,result, result);
            }    
            else{
                component.find('notifLib').showNotice({
                    "variant": "error",
                    "header": "Warning!",
                    "message": 'Something Went Wrong !!!',
                });  
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    },

    Post_Vendor_ToQBHelper: function(component, event, helper){
        console.log("Inside Vendor Integration helper");
        var action = component.get("c.sync_Vendor_In_QB_AuraCallout");
        action.setParams({
            recordId : component.get("v.recordId"),
            SyncObjName : component.get("v.sObjectName")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('Vendor state ==> ' + state);
            var result = response.getReturnValue();
            console.log('Vendor result ==> ' + result);

            if(result != null){
                helper.ShowResponsePopupHelper(component, event, helper,result, result);
            }    
            else{
                component.find('notifLib').showNotice({
                    "variant": "error",
                    "header": "Warning!",
                    "message": 'Something Went Wrong !!!',
                });  
                $A.get("e.force:closeQuickAction").fire();
            }
        });

        $A.enqueueAction(action);
    },

    SyncExpense: function(component, event, helper){
        console.log('******In expense qb sync******');
        var action = component.get("c.sync_Expense_in_QB_AuraCallout");
        action.setParams({
            recordId : component.get("v.recordId"),
            SyncObjName : component.get("v.sobjecttype")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state ==> ' + state);
            
            if(state === "SUCCESS") {
                
                var result = response.getReturnValue();
                console.log('return value ==> '+ result);
                $A.get("e.force:closeQuickAction").fire();
                
                if(result != null){
                    helper.ShowResponsePopupHelper(component, event, helper,result, result);
                }    
                else{
                    component.find('notifLib').showNotice({
                        "variant": "error",
                        "header": "Warning!",
                        "message": 'Something Went Wrong !!!',
                    });  
                    $A.get("e.force:closeQuickAction").fire();
                }
                
            }
        });
        
        $A.enqueueAction(action);
    },

    SyncReceipt: function(component, event, helper){
        try {
            
            console.log("inside Sync Receipt");
            var action = component.get("c.sync_Receipt_in_QB_AuraCallout");
            action.setParams({
                recordId : component.get("v.recordId"),
                SyncObjName : component.get("v.sobjecttype")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log('state ==> ' + state);
                if(state === "SUCCESS") {
                    var result = response.getReturnValue();
                    console.log('return value ==> '+ result);
                    $A.get("e.force:closeQuickAction").fire();
                    
                    if(result != null){
                        helper.ShowResponsePopupHelper(component, event, helper,result, result);
                    }    
                    else{
                        component.find('notifLib').showNotice({
                            "variant": "error",
                            "header": "Warning!",
                            "message": 'Something Went Wrong !!!',
                        });  
                        $A.get("e.force:closeQuickAction").fire();
                    }
                }
            });

            $A.enqueueAction(action);	
        } catch (error) {
            console.log('error in SyncReceipt : ', error.stack);
        }
    },

    ShowResponsePopupHelper: function(component, event, helper, result, ResponseMessage){
        component.find('notifLib').showNotice({
            "variant": result == 'success' ? "success" : "warning",
            "header": result == 'success' ? "Success" : "Validation Warning",
            "message": result == 'success' ? "Complete" : ResponseMessage,
        });    
    }


})