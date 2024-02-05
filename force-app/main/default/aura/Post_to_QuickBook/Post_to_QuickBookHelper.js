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
                if(result == 'success'){
            		component.find('notifLib').showNotice({
    		            "variant": "success",
    		            "header": "Success",
    		            "message": "Completed",
    		        });    
                }else if(result == 'no_invoicelines') {
                    component.find('notifLib').showNotice({
    		            "variant": "warning",
    		            "header": "Validation Warning",
    		            "message": 'There are zero line(s) associated with the Invoice. Please create at least one line to sync with QB.',
    		        });    
                }
                else if(result.includes('Lines Without Name:')){
                    component.find('notifLib').showNotice({
    		            "variant": "warning",
    		            "header": "Validation Warning",
    		            "message": 'The invoice line(s) with reference \b' + result.replace('Lines Without Name:','') + '\b does not have a name associated with it, Please provide Name to these Invoice line(s).',
    		        });    
                }
                else if(result == 'no_customer_account'){
                    component.find('notifLib').showNotice({
    		            "variant": "warning",
    		            "header": "Validation Warning",
    		            "message": 'Customer must be linked with the Invoice. Please link Customer account to sync with QB',
    		        });  
                }
                else if(result == 'account_synced_as_vendor'){
                    component.find('notifLib').showNotice({
    		            "variant": "warning",
    		            "header": "Validation Warning",
    		            "message": 'Customer Account already synced as Vendor in QB. You can not resync customer account. Please change the Customer Account.',
    		        });  
                }
                else if(result == 'account_type_not_customer'){
                    component.find('notifLib').showNotice({
    		            "variant": "warning",
    		            "header": "Validation Warning",
    		            // "message": 'Customer Account\'s account type is not a Customer. Please make it customer or change Customer account',
    		            "message": 'You cannot assign non-customer account to the Customer field. Please Change the account type to customer or select customer account to sync with QB.',
    		        });  
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
                if(result == 'success'){
            		component.find('notifLib').showNotice({
    		            "variant": "success",
    		            "header": "Success",
    		            "message": "Completed",
    		        });    
                }else if(result == 'no_colines') {
                    component.find('notifLib').showNotice({
    		            "variant": "warning",
    		            "header": "Validation Warning",
    		            "message": 'There are no line(s) associated with the Invoice. Please create at least one line to sync with QB.',
    		        });    
                }
                else if(result == 'no_po'){
                    component.find('notifLib').showNotice({
    		            "variant": "warning",
    		            "header": "Validation Warning",
    		            "message": 'Purchase Order must be associted with the Invoice to sync with QB',
    		        });  
                }else if(result == 'no_vendor_account'){
                    component.find('notifLib').showNotice({
    		            "variant": "warning",
    		            "header": "Validation Warning",
    		            "message": 'Vendor account must be linked with Invoice\'s PO in order to sync with QB ',
    		        });  
                }
                else if(result == 'account_sync_as_customer'){
                    component.find('notifLib').showNotice({
    		            "variant": "warning",
    		            "header": "Validation Warning",
    		            "message": 'Purchase order\'s Vendor Already Sync as Customer in QB. Please change Vendor account from Purchase order of the Invoice.',
    		        });  
                }
                else if(result == 'account_type_not_vendor'){
                    component.find('notifLib').showNotice({
    		            "variant": "warning",
    		            "header": "Validation Warning",
    		            // "message": 'Purchase order\'s Vendor\'s account type is not a Vendor. Please make it Vendor type or change the vendor to sync with QB.',
    		            "message": 'You cannot assign non-vendor account to the Vendor field. Please Change the account type to vendor or change account to sync with QB.',
    		        });  
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
                if(result == 'success'){
            		component.find('notifLib').showNotice({
    		            "variant": "success",
    		            "header": "Success",
    		            "message": "Completed",
    		        });    
                }else if(result == 'no_payablelines') {
                    component.find('notifLib').showNotice({
    		            "variant": "warning",
    		            "header": "Validation Warning",
    		            "message": 'There are no Line(s) associated with the Invoice. Please create at least one line to sync with QB.',
    		        });    
                }
                else if(result == 'no_vendor_account'){
                    component.find('notifLib').showNotice({
    		            "variant": "warning",
    		            "header": "Validation Warning",
    		            "message": 'Vendor account must be linked with the Invoice in order to sync with QB',
    		        });  
                }
                else if(result == 'account_sync_as_customer'){
                    component.find('notifLib').showNotice({
    		            "variant": "warning",
    		            "header": "Validation Warning",
    		            "message": 'Vendor Already Sync as Customer in QB. Please change Vendor account from Purchase order of the Invoice.',
    		        });  
                }
                else if(result == 'account_type_not_vendor'){
                    component.find('notifLib').showNotice({
    		            "variant": "warning",
    		            "header": "Validation Warning",
    		            // "message": 'Vendor\'s account type is not a Vendor. Please make it Vendor type or change the vendor to sync with QB.',
    		            "message": 'You cannot assign non-vendor account to the Vendor field on Purchase Order. Please Change the account type to vendor or change account to sync with QB.',
    		        });  
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
                if(result == 'success'){
            		component.find('notifLib').showNotice({
    		            "variant": "success",
    		            "header": "Success",
    		            "message": "Completed",
    		        });    
                }else if(result == 'no_polines') {
                    component.find('notifLib').showNotice({
    		            "variant": "warning",
    		            "header": "Validation Warning",
    		            "message": 'There are no PO line(s) associated with the PO. Please create at least one line to sync with QB.',
    		        });    
                }else if(result == 'no_vendor_account'){
                    component.find('notifLib').showNotice({
    		            "variant": "warning",
    		            "header": "Validation Warning",
    		            "message": 'Vendor account must be linked in order to sync with QB',
    		        });  
                } 
                else if(result == 'account_sync_as_customer'){
                    component.find('notifLib').showNotice({
    		            "variant": "warning",
    		            "header": "Validation Warning",
    		            "message": 'Vendor Already Sync as Customer in QB. Please change Vendor account.',
    		        });  
                }
                else if(result == 'account_type_not_vendor'){
                    component.find('notifLib').showNotice({
    		            "variant": "warning",
    		            "header": "Validation Warning",
    		            // "message": 'Vendor\'s account type is not a Vendor. Please make it Vendor type or change the vendor to sync with QB.',
    		            "message": 'You cannot assign non-vendor account to the Vendor field. Please Change the account type to vendor or change account to sync with QB.',
    		        });  
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
                    "header": "Warning!",
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
                    "header": "Warning!",
                    "message": 'Something Went Wrong',
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
    		            "variant": "warning",
    		            "header": "Validation Warning",
    		            "message": 'There are no Expense Line(s) associated with the Expense. Please create at least one line to sync with QB.',
    		        });    
                }else if(result == 'no_vendor_account'){
                    component.find('notifLib').showNotice({
    		            "variant": "warning",
    		            "header": "Validation Warning",
    		            "message": 'There are no Vendor account associated with the Expense. Please associate Vendor account to the Expense',
    		        });  
                } 
                else if(result == 'account_type_not_vendor'){
                    component.find('notifLib').showNotice({
    		            "variant": "warning",
    		            "header": "Validation Warning",
    		            "message": 'You cannot assign non-vendor account to the vendor field. Please Change the account type to vendor or select vendor account to sync with QB.',
    		        });  
                }
                else if(result == 'account_sync_as_customer'){
                    component.find('notifLib').showNotice({
    		            "variant": "warning",
    		            "header": "Validation Warning",
    		            "message": 'Vendor Account Already Sync as Customer in QB.',
    		        });  
                }
                else if(result == 'payment_method_null'){
                    component.find('notifLib').showNotice({
    		            "variant": "warning",
    		            "header": "Validation Warning",
    		            "message": 'Payment Method should not be empty.',
    		        });  
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
                    var ResponseMessage;
                    if(result == 'success'){
                        ResponseMessage = 'Completed';
                        helper.ShowResponsePopupHelper(component, event, helper,result, ResponseMessage);
                    }
                    else if(result == 'no_invoice'){
                        ResponseMessage = 'Invoice must be linked with the Receipt. Please link Invoice to sync with QB.';
                        helper.ShowResponsePopupHelper(component, event, helper,result, ResponseMessage);
                    }
                    else if(result == 'no_invoicelines'){
                        ResponseMessage = 'There are zero line(s) associated with the Invoice. Please create at least one line to sync with QB.'  
                        helper.ShowResponsePopupHelper(component, event, helper,result, ResponseMessage);
                    }
                    else if(result.includes('Lines Without Name:')){
                        ResponseMessage = 'The invoice line(s) with reference \b' + result.replace('Lines Without Name:','') + '\b does not have a name associated with it, Please provide Name to these Invoice line(s).'  
                        helper.ShowResponsePopupHelper(component, event, helper,result, ResponseMessage);
                    }
                    else if(result == 'no_customer_account'){
                        ResponseMessage = 'Customer must be linked with the Invoice. Please link Customer account to sync with QB.';
                        helper.ShowResponsePopupHelper(component, event, helper,result, ResponseMessage);
                    }
                    else if(result == 'account_synced_as_vendor'){
                        ResponseMessage = 'Invoice\'s Customer Account already synced as Vendor in QB. You can not resync customer account. Please change the Customer Account.';
                        helper.ShowResponsePopupHelper(component, event, helper,result, ResponseMessage);
                    }
                    else if(result == 'account_type_not_customer'){
                            // "message": 'Customer Account\'s account type is not a Customer. Please make it customer or change Customer account',
                        ResponseMessage = 'You cannot assign non-customer account to the Customer field on Invoice. Please Change the account type to customer or select customer account to sync with QB.';
                        helper.ShowResponsePopupHelper(component, event, helper,result, ResponseMessage);
                    }
                    else if(result == 'no_amount'){
                            // "message": 'Customer Account\'s account type is not a Customer. Please make it customer or change Customer account',
                        ResponseMessage = 'Please insert amount value to sync with QB.';
                        helper.ShowResponsePopupHelper(component, event, helper,result, ResponseMessage);
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
        } catch (error) {
            console.log('error in SyncReceipt : ', error.stack);
        }
    },

    ShowResponsePopupHelper: function(component, event, helper, result, ResponseMessage){
        component.find('notifLib').showNotice({
            "variant": result == 'success' ? "success" : "warning",
            "header": result == 'success' ? "Success" : "Validation Warning",
            "message": ResponseMessage,
        });    
    }


})