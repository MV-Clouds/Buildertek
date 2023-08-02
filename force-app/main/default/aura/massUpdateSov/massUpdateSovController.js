({
    doInit: function (component, event, helper) {
        
        
        var action = component.get("c.getUser");
        action.setCallback(this, function(response){
            
            if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
                var commUserId = result.Id;
                if(result.IsPortalEnabled == true){
                    component.set("v.Iscommunity",true);
                    
                    
                     //To Check Status Is Submitted Or Not
                    var action2 = component.get("c.isSovSubmitted");
                    action2.setParams({
                        recordId: component.get("v.recordId")
                    });
                    action2.setCallback(this, function(response){
                        if(response.getState() === "SUCCESS"){
                            var result = response.getReturnValue();
                            if(result == "Vendor Submitted" || result == "Approved"){
                                component.set("v.IsSubmitted", true)
                            }else{
                                var address = '/mass-update-sov?id='+component.get("v.recordId")+'&dummy=ignore'+'/';
                                var urlEvent = $A.get("e.force:navigateToURL");
                                urlEvent.setParams({
                                    "url": address,
                                    "isredirect" :false
                                });
                                urlEvent.fire();
                                $A.get("e.force:closeQuickAction").fire();
                            }
                        }
                    });
                    $A.enqueueAction(action2);
                    
                    
                    
                }else{
                    
                    var evt = $A.get("e.force:navigateToComponent");
                    evt.setParams({
                        componentDef : "c:SOVLinesMassUpdate",
                        componentAttributes: {
                            recordId : component.get("v.recordId")
                        }
                    });
                    evt.fire();
                    $A.get("e.force:closeQuickAction").fire();
                }
            }
        });
        $A.enqueueAction(action);
        
    }
})