({
    doInit : function(component, event, helper) {
        
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
                            if(result == "Vendor Submitted"){
                                //component.set("v.IsSubmitted", true)
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title : 'Error',
                                    message: 'This SOV Is Under Review',
                                    duration:' 5000',
                                    key: 'info_alt',
                                    type: 'error',
                                    mode: 'dismissible'
                                });
                                toastEvent.fire();
                                $A.get("e.force:closeQuickAction").fire(); 
                            }else if(result == "Company Approved" || result == "Customer Approved"){
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title : 'Error',
                                    message: 'This SOV has been Approved, You Cannot Import additional Lines into an Approved SOV.',
                                    duration:' 5000',
                                    key: 'info_alt',
                                    type: 'error',
                                    mode: 'dismissible'
                                });
                                toastEvent.fire();
                                $A.get("e.force:closeQuickAction").fire(); 
                                //component.set("v.IsCompanyApproved", true)
                            }else{
                                var address = '/import-sov?id='+component.get("v.recordId")+'&dummy=ignore'+'/';
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
                    
                    
                    
                    
                      var action2 = component.get("c.isSovSubmitted");
                    action2.setParams({
                        recordId: component.get("v.recordId")
                    });
                    action2.setCallback(this, function(response){
                        if(response.getState() === "SUCCESS"){
                          
                            var result = response.getReturnValue();
                             if(result == "Company Approved" || result == "Customer Approved"){
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title : 'Error',
                                    message: 'This SOV has been Approved, You Cannot Import additional Lines into an Approved SOV.',
                                    duration:' 5000',
                                    key: 'info_alt',
                                    type: 'error',
                                    mode: 'dismissible'
                                });
                                toastEvent.fire();
                                $A.get("e.force:closeQuickAction").fire(); 
                                //component.set("v.IsCompanyApproved", true)
                            }else{
                               
                     var workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then(function(tabResponse) {
                        
                        var parentTabId = tabResponse.tabId;
                        var isSubtab = tabResponse.isSubtab;
                        
                        workspaceAPI.openSubtab({
                            
                            parentTabId: parentTabId,
                            pageReference: {
                                "type": "standard__component",
                                "attributes": {
                                    "recordId" : component.get("v.recordId"),
                                    "componentName": "buildertek__importSOV"
                                },
                                "state": {
                                    "buildertek__parentId": component.get("v.recordId")
                                }
                            },
                            //focus: true
                        }).then(function(response){
                            console.log(response);
                            var workspaceAPI = component.find("workspace");
                            workspaceAPI.getFocusedTabInfo().then(function(response) {
                                var focusedTabId = response.tabId;
                                workspaceAPI.setTabLabel({
                                    tabId: focusedTabId,
                                    label: "Import From CSV",
                                });
                                workspaceAPI.setTabIcon({
                                    tabId: focusedTabId,
                                    icon: "custom:custom5",
                                    iconAlt: "Import From CSV"
                                });
                            })
                            .catch(function(error) {
                                console.log(error);
                            });
                        })
                    });
                    
                            }
                        }
                    });
                    $A.enqueueAction(action2);
                    
                    
                    
                    
                    

                   
                  /*  var evt = $A.get("e.force:navigateToComponent");
                    evt.setParams({
                        componentDef : "c:importSOV",
                        componentAttributes: {
                            recordId : component.get("v.recordId")
                        }
                    });
                    evt.fire();
                    $A.get("e.force:closeQuickAction").fire();  */
                }
            }
        });
        $A.enqueueAction(action);
        
        
        
    }
})