({
    doInit : function(component, event, helper) {
        debugger;
        
        
        var action1 = component.get("c.getPaymentAppStatus");
        action1.setParams({
            recordId: component.get("v.recordId")
        });
        action1.setCallback(this, function(response){
            var state =  response.getState();
            if(state == "SUCCESS")
            {
                
                var result = response.getReturnValue(); 
                
                if(result != null){
                    if(result == 'Company Accepted' || result == 'Customer Accepted'){
                        
                        $A.get("e.force:closeQuickAction").fire();
                        
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : "Error!",
                            message : 'The Payment Application is Approved, Please Contact your System Administrator',
                            type: 'error',
                            duration: '1000',
                            key: 'info_alt',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                        
                        
                    }else{
                        
                        var action = component.get("c.getUser");
                        action.setCallback(this, function(response){
                            if(response.getState() === "SUCCESS"){
                                
                                var result = response.getReturnValue();
                                var commUserId = result.Id;
                                if(result.IsPortalEnabled == true){
                                    var address = '/co-tracking?id='+component.get("v.recordId")+'&dummy=ignore'+'/';
                                    
                                    var urlEvent = $A.get("e.force:navigateToURL");
                                    urlEvent.setParams({
                                        "url": address,
                                        "isredirect" :false
                                    });
                                    urlEvent.fire();
                                    
                                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                                    dismissActionPanel.fire();
                                    
                                    
                                }else{
                                    var evt = $A.get("e.force:navigateToComponent");
                                    evt.setParams({
                                        componentDef : "c:ChangeOrderTracking",
                                        componentAttributes: {
                                            recordId : component.get("v.recordId")
                                        }
                                    });
                                    evt.fire();
                                    $A.get("e.force:closeQuickAction").fire();
                                    
                                }
                                
                            }
                        })
                        
                        $A.enqueueAction(action);
                    }
                }else{
                    
                    $A.get("e.force:closeQuickAction").fire();
                    
                     var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : "Error!",
                            message : 'There is no Payment Application for this record',
                            type: 'error',
                            duration: '1000',
                            key: 'info_alt',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                }
                
                
            }else if (state=="ERROR") {
                console.log(action1.getError()[0].message);
            }
        });
        $A.enqueueAction(action1);
        
        
        
        
    }
})