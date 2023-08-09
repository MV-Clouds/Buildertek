({
    doInit : function(component, event, helper) {
        
      
        var action = component.get("c.getUser");
        
        action.setCallback(this, function(response){
            
            if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
                var commUserId = result.Id;
                if(result.IsPortalEnabled == true){
                    component.set("v.communityUserId",commUserId);
                    component.set("v.Vendorname",result.buildertek__Account_Id__c);
                    component.set("v.Iscommunity",true);
                 
                    var action2 = component.get("c.isSovSubmitted");
                    action2.setParams({
                        recordId: component.get("v.recordId")
                    });
                    action2.setCallback(this, function(response){
                        if(response.getState() === "SUCCESS"){
                            var result = response.getReturnValue();
                            if(result == "Vendor Submitted"){
                                //component.set("v.IsSubmitted", true)
                                 var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title : '',
                                    message: 'This SOV Is Under Review.',
                                    duration:' 5000',
                                    key: 'info_alt',
                                    type: 'error',
                                    mode: 'dismissible'
                                });
                                toastEvent.fire();
                                $A.get("e.force:closeQuickAction").fire();
                                
                                
                            }else if(result == "Company Approved"){
                                //component.set("v.IsCompanyApproved", true)
                                 var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title : '',
                                    message: 'This SOV Is Approved by Company, You cannot resubmit this SOV.',
                                    duration:' 5000',
                                    key: 'info_alt',
                                    type: 'error',
                                    mode: 'dismissible'
                                });
                                toastEvent.fire();
                                $A.get("e.force:closeQuickAction").fire();
                                
                            }
                            else if(result == "Company Rejected" || result == "Company Submitted" ){
                                 component.set("v.IsActive", true)
                            }else {
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title : '',
                                    message: 'You can Submit the SOV only when the Status is set to Company Submitted or Company Rejected.',
                                    duration:' 5000',
                                    key: 'info_alt',
                                    type: 'error',
                                    mode: 'dismissible'
                                });
                                toastEvent.fire();
                                $A.get("e.force:closeQuickAction").fire();
                            }
                           
                        }
                    });
                    $A.enqueueAction(action2);
                }
                
               
          
            }
        });
        $A.enqueueAction(action);
        
    },
    
    
    
    confirmSubmit: function (component, event, helper) {
        debugger;
        var action = component.get("c.submitSOVForView");
        action.setParams({
            recordId : component.get("v.recordId"),
            todayDate : new Date(),
            vendor : component.get("v.Vendorname")
        });
        action.setCallback(this, function(response){
            debugger;
            if(response.getState() == 'SUCCESS'){
                var result = response.getReturnValue();
                
                if(result == 'success'){
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    
                    $A.get('e.force:refreshView').fire();
                    
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'SOV Submitted To Owner Successfully',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'Success',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    
                    $A.get('e.force:refreshView').fire();
                    
                    
                }else if(result.includes('Project Is Required')){
                    
                     var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message: 'Project is Required',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                }
             
            }     
        });
        $A.enqueueAction(action);
    },
    
    cancelSubmit: function (component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        component.set("v.isSubmitForView",false);
    },
    
    close: function (component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        
    }
    
    
    
})