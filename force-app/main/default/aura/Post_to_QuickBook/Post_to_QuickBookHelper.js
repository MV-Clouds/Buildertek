({
    // createPO : function(component, event, helper) {
    //     var action = component.get("c.Create_customer_item_po_in_QB_flow");
    //     action.setParams({
    //         recordId : component.get("v.recordId"),
    //         Objecttype : component.get("v.sobjecttype")
    //     });
        
    //     action.setCallback(this, function(response) {
    //         var state = response.getState();
    //         console.log('state ==> ' + state);
            
    //         if(state === "SUCCESS") {
    //             var result = response.getReturnValue();
    //             console.log('return value ==> '+ result);
    //             $A.get("e.force:closeQuickAction").fire();
    //             if(result == 'success'){
    //         		component.find('notifLib').showNotice({
    // 		            "variant": "success",
    // 		            "header": "Success",
    // 		            "message": "Completed",
    // 		        });    
    //             }else if(result == 'no_invoicelines') {
    //                 component.find('notifLib').showNotice({
    // 		            "variant": "error",
    // 		            "header": "Error",
    // 		            "message": 'There are no PO Line(s) associated with the PO.',
    // 		        });    
    //             }else if(result == 'no_customer_account'){
    //                 component.find('notifLib').showNotice({
    // 		            "variant": "error",
    // 		            "header": "Error",
    // 		            "message": 'There are no Vendor account associated with the PO.',
    // 		        });  
    //             }else{
    //                 component.find('notifLib').showNotice({
    // 		            "variant": "error",
    // 		            "header": "Error",
    // 		            "message": 'Something Went Wrong !!!',
    // 		        });  
    //             }
                
    //         }
    //     });
        
    //     $A.enqueueAction(action);	
    // },

    PostAccountToQuickbook: function(component, event, helper){
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
        var action = component.get("c.Create_Customer_In_QB_AuraCallout");
        action.setParams({
            AccoountId : component.get("v.recordId"),
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
        var action = component.get("c.Create_Vendor_In_QB_AuraCallout");
        action.setParams({
            AccoountId : component.get("v.recordId"),
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



})