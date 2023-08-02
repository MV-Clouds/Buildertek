({
    doInit : function(component, event, helper) {
        
        var action1 = component.get("c.getRFQStatus");
        action1.setParams({
            recordId : component.get("v.recordId")    
        });
        action1.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
                if(result == 'Awarded'){
                    component.set("v.IsAwarded", true)
                }
                
                
                
                
                
                
                
                
                
                var action = component.get("c.getUser");
                action.setCallback(this, function(response){
                    if(response.getState() === "SUCCESS"){
                        var result = response.getReturnValue();
                        var commUserId = result.Id;
                        if(result.IsPortalEnabled == true){
                            component.set("v.communityUserId",commUserId);
                            component.set("v.Vendorname",result.buildertek__Account_Id__c);
                            
                            component.set("v.Iscommunity",true);
                        }
                        
                        
 var action6 = component.get("c.rqSubmitted");
        var loggedInVendor = component.get("v.Vendorname");
        action6.setParams({
            recordId : component.get("v.recordId"),
            vendorId : loggedInVendor
        });
        action6.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
                if(result == "Quote Submitted"){
                    
                    component.set("v.isSubmitted",true);
                }
            }
        });
        $A.enqueueAction(action6);                         
                        
                        
                        
                        var action3 = component.get("c.getRQToAccount");
                        var loggedInVendor = component.get("v.Vendorname");
                        action3.setParams({
                            recordId : component.get("v.recordId"),
                            vendorId : loggedInVendor
                        });
                        action3.setCallback(this, function(response){
                            if(response.getState() === "SUCCESS"){
                                var result = response.getReturnValue();
                                if(result == "Accepted"){
                                    
                                    component.set("v.isRFQAccepted",true);
                                }else{
                                    
                                    
                                    var action4 = component.get("c.getrejectMessage");
                                    var loggedInVendor = component.get("v.Vendorname");
                                    action4.setParams({
                                        recordId : component.get("v.recordId"),
                                        vendorId : loggedInVendor
                                    });
                                    action4.setCallback(this, function(response){
                                        if(response.getState() === "SUCCESS"){
                                            var result = response.getReturnValue();
                                            if(result == true){
                                                
                                                 component.set("v.isAnotherVendor",true);
                                            }
                                        }
                                    });
                                    $A.enqueueAction(action4);
                                    
                                    
                                }
                            }
                        });
                $A.enqueueAction(action3);
                        
                        
                    }
                });
                $A.enqueueAction(action);
                
                
                
                
                
          
               
            }
        });
        $A.enqueueAction(action1); 
        
        
        
        
       
        
        
    },
    
    
    acceptRFQ: function (component, event, helper) {
        component.set("v.acceptPopUp",true);
    },
    
    
    confirmAccept: function (component, event, helper) {
        component.set("v.acceptPopUp",false);
        var loggedInVendor = component.get("v.Vendorname");
        
        var action = component.get("c.submitSOVForView");
        action.setParams({
            recordId : component.get("v.recordId"),
            vendorId : loggedInVendor
        });
        action.setCallback(this, function(response){
            
            if(response.getState() == 'SUCCESS'){
                var result = response.getReturnValue();
                
                
                $A.get('e.force:refreshView').fire();
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'RFQ has been Accepted Successfully',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'Success',
                    mode: 'dismissible'
                });
                toastEvent.fire();
                
                
            }     
            
        });
        $A.enqueueAction(action);
    },
    
    
    
     rejectRFQ: function (component, event, helper) {
       component.set("v.rejectPopUp",true);
    },
    
    
      confirmReject: function (component, event, helper) {
        component.set("v.rejectPopUp",false);
        var action = component.get("c.rejectRfq");
        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            
            if(response.getState() == 'SUCCESS'){
                var result = response.getReturnValue();
                
                 $A.get('e.force:refreshView').fire();
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'RFQ has been Cancelled Successfully',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'Success',
                    mode: 'dismissible'
                });
                toastEvent.fire();
                
               
            }     
            
        });
        $A.enqueueAction(action);
    },
    
    
    cancelSubmit: function (component, event, helper) {
        component.set("v.rejectPopUp",false);
        component.set("v.acceptPopUp",false);
        
    },
    
    
})