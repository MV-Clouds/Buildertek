({
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
                if(result == 'success'){
            		component.find('notifLib').showNotice({
    		            "variant": "success",
    		            "header": "Success",
    		            "message": "Completed",
    		        });    
                }else if(result == 'no_polines') {
                    component.find('notifLib').showNotice({
    		            "variant": "error",
    		            "header": "Error",
    		            "message": 'There are no PO Line(s) associated with the PO.',
    		        });    
                }else if(result == 'no_vendor_account'){
                    component.find('notifLib').showNotice({
    		            "variant": "error",
    		            "header": "Error",
    		            "message": 'There are no Vendor account associated with the PO.',
    		        });  
                } 
                else if(result == 'account_sync_as_customer'){
                    component.find('notifLib').showNotice({
    		            "variant": "error",
    		            "header": "Error",
    		            "message": 'Vendor Account Already Sync as Customer in Quickbooks.',
    		        });  
                }
                else{
                    component.find('notifLib').showNotice({
    		            "variant": "error",
    		            "header": "Error",
    		            "message": 'Something Went Wrong !!!',
    		        });  
                }
                
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
                if(result == 'success'){
            		component.find('notifLib').showNotice({
    		            "variant": "success",
    		            "header": "Success",
    		            "message": "Completed",
    		        });    
                }else if(result == 'no_colines') {
                    component.find('notifLib').showNotice({
    		            "variant": "error",
    		            "header": "Error",
    		            "message": 'There are no Line(s) associated with the Invoice.',
    		        });    
                }
                else if(result == 'no_po'){
                    component.find('notifLib').showNotice({
    		            "variant": "error",
    		            "header": "Error",
    		            "message": 'There are no PPO associated with the Invoice.',
    		        });  
                }else if(result == 'no_vendor_account'){
                    component.find('notifLib').showNotice({
    		            "variant": "error",
    		            "header": "Error",
    		            "message": 'There are no Vendor account associated with the PO Of this Invoice.',
    		        });  
                }
                else if(result == 'account_sync_as_customer'){
                    component.find('notifLib').showNotice({
    		            "variant": "error",
    		            "header": "Error",
    		            "message": 'PO Vendor Account Already Sync as Customer in Quickbooks.',
    		        });  
                }
                else{
                    component.find('notifLib').showNotice({
    		            "variant": "error",
    		            "header": "Error",
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
                if(result == 'success'){
            		component.find('notifLib').showNotice({
    		            "variant": "success",
    		            "header": "Success",
    		            "message": "Completed",
    		        });    
                }else if(result == 'no_payablelines') {
                    component.find('notifLib').showNotice({
    		            "variant": "error",
    		            "header": "Error",
    		            "message": 'There are no Line(s) associated with the Invoice.',
    		        });    
                }
                else if(result == 'no_vendor_account'){
                    component.find('notifLib').showNotice({
    		            "variant": "error",
    		            "header": "Error",
    		            "message": 'There are no Vendor account associated with this Invoice.',
    		        });  
                }
                else if(result == 'account_sync_as_customer'){
                    component.find('notifLib').showNotice({
    		            "variant": "error",
    		            "header": "Error",
    		            "message": 'Vendor Account Already Sync as Customer in Quickbooks.',
    		        });  
                }
                else{
                    component.find('notifLib').showNotice({
    		            "variant": "error",
    		            "header": "Error",
    		            "message": 'Something Went Wrong !!!',
    		        });  
                }
                
            }
            
        });
        $A.enqueueAction(action);	
    },

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
    		            "message": 'There are no Line(s) associated with the Invoice.',
    		        });    
                }
                else if(result == 'no_customer_account'){
                    component.find('notifLib').showNotice({
    		            "variant": "error",
    		            "header": "Error",
    		            "message": 'There are no Customer associated with the Invoice.',
    		        });  
                }
                else if(result == 'account_synced_as_vendor'){
                    component.find('notifLib').showNotice({
    		            "variant": "error",
    		            "header": "Error",
    		            "message": 'Customer Account Already Synced as Vendor in QB.',
    		        });  
                }
                else{
                    component.find('notifLib').showNotice({
    		            "variant": "error",
    		            "header": "Error",
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
                "variant": "error",
                "header": "Error",
                "message": 'Please Select at least on Account Type!',
            });    
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
   
            if(result == 'Completed'){
                component.find('notifLib').showNotice({
                    "variant": "success",
                    "header": "Success",
                    "message": 'Completed',
                }); 
                $A.get("e.force:closeQuickAction").fire();
            }
            else{
                component.find('notifLib').showNotice({
                    "variant": "error",
                    "header": "Error",
                    "message": 'Something Went Wrong!',
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

            if(result == 'Completed'){
                component.find('notifLib').showNotice({
                    "variant": "success",
                    "header": "Success",
                    "message": 'Completed',
                }); 
                $A.get("e.force:closeQuickAction").fire();
            }
            else{
                component.find('notifLib').showNotice({
                    "variant": "error",
                    "header": "Error",
                    "message": 'Something Went Wrong!',
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
                if(result == 'success'){
            		component.find('notifLib').showNotice({
    		            "variant": "success",
    		            "header": "Success",
    		            "message": "Completed",
    		        });    
                }else if(result == 'no_expenselines') {
                    component.find('notifLib').showNotice({
    		            "variant": "error",
    		            "header": "Error",
    		            "message": 'There are no Expense Line(s) associated with the Expense.',
    		        });    
                }else if(result == 'no_vendor_account'){
                    component.find('notifLib').showNotice({
    		            "variant": "error",
    		            "header": "Error",
    		            "message": 'There are no Vendor account associated with the Expense.',
    		        });  
                } 
                else if(result == 'account_sync_as_customer'){
                    component.find('notifLib').showNotice({
    		            "variant": "error",
    		            "header": "Error",
    		            "message": 'Vendor Account Already Sync as Customer in Quickbooks.',
    		        });  
                }
                else{
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