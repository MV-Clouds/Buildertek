({
    doInit : function(component, event, helper) {
        debugger;
        var action9 = component.get("c.getState");
        action9.setParams({
            recId: component.get("v.recordId")
        });
        action9.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
                
              
                
                if(result.PeriodDate == null){
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'ERROR',
                        message: 'Period To Field should not be Null.',
                        duration: "5000",
                        key: "info_alt",
                        type: "error",
                        mode: "pester",
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                }else{
                    
                
                
                if(result.userrec != true){
                    var action2 = component.get("c.getContsheet");
                    action2.setParams({
                        recId: component.get("v.recordId")
                    });
                    action2.setCallback(this, function(response){
                        var result = response.getReturnValue();
                        if(response.getState() === "SUCCESS"){
                            var result = response.getReturnValue();
                            $A.enqueueAction(action);
                            
                        }
                        else{
                            var navEvt = $A.get("e.force:navigateToSObject");
                            navEvt.setParams({
                                "recordId": component.get("v.recordId"),
                                "slideDevName": "related"
                            });
                            navEvt.fire();
                            
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title: 'ERROR',
                                message: 'There is no Continuation Sheet',
                                duration: "5000",
                                key: "info_alt",
                                type: "error",
                                mode: "pester",
                            });
                            toastEvent.fire();
                            
                            
                        }
                        
                    })
                    $A.enqueueAction(action2);    
                    
                    
                    var action = component.get("c.getUser");
                    action.setCallback(this, function(response){
                        if(response.getState() === "SUCCESS"){
                            
                            var result = response.getReturnValue();
                            var commUserId = result.Id;
                            
                            // alert('isCommunityUser'+result)
                            
                            if(result.IsPortalEnabled == true){
                                var address = '/continuation-sheet-page?id='+component.get("v.recordId")+'&userIdFromcommunity='+commUserId+'&dummy=ignore'+'/';
                                var urlEvent = $A.get("e.force:navigateToURL");
                                urlEvent.setParams({
                                    "url": address,
                                    "isredirect" :false
                                });
                                urlEvent.fire();
                                
                                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                                dismissActionPanel.fire();
                                
                                
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
                                                "componentName": "buildertek__ContinuationSheetItems"
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
                                                label: "Continuation Sheet Details",
                                            });
                                            workspaceAPI.setTabIcon({
                                                tabId: focusedTabId,
                                                icon: "custom:custom5",
                                                iconAlt: "Continuation Sheet Details"
                                            });
                                        })
                                        .catch(function(error) {
                                            console.log(error);
                                        });
                                    })
                                });
                                
                            }
                            
                        }
                    })
                    //$A.enqueueAction(action);
                }
                
                else{ 
                   // if((result.status != "Vendor Submitted" && result.status != "Company Accepted")){
                        //$A.get("e.force:closeQuickAction").fire();
                        var action2 = component.get("c.getContsheet");
                        action2.setParams({
                            recId: component.get("v.recordId")
                        });
                        action2.setCallback(this, function(response){
                            var result = response.getReturnValue();
                            if(response.getState() === "SUCCESS"){
                                var result = response.getReturnValue();
                                $A.enqueueAction(action);
                                
                            }else{
                                var navEvt = $A.get("e.force:navigateToSObject");
                                navEvt.setParams({
                                    "recordId": component.get("v.recordId"),
                                    "slideDevName": "related"
                                });
                                navEvt.fire();
                                
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title: 'ERROR',
                                    message: 'There is no Continuation Sheet',
                                    duration: "5000",
                                    key: "info_alt",
                                    type: "error",
                                    mode: "pester",
                                });
                                toastEvent.fire();
                                
                                
                            }
                            
                        })
                        $A.enqueueAction(action2);    
                        
                        
                        
                        var action = component.get("c.getUser");
                        action.setCallback(this, function(response){
                            if(response.getState() === "SUCCESS"){
                                
                                var result = response.getReturnValue();
                                var commUserId = result.Id;
                                
                                // alert('isCommunityUser'+result)
                                
                                if(result.IsPortalEnabled == true){
                                    var address = '/continuation-sheet-page?id='+component.get("v.recordId")+'&userIdFromcommunity='+commUserId+'&dummy=ignore'+'/';
                                    var urlEvent = $A.get("e.force:navigateToURL");
                                    urlEvent.setParams({
                                        "url": address,
                                        "isredirect" :false
                                    });
                                    urlEvent.fire();
                                    
                                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                                    dismissActionPanel.fire();
                                    
                                    
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
                                                    "componentName": "buildertek__ContinuationSheetItems"
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
                                                    label: "Continuation Sheet Details",
                                                });
                                                workspaceAPI.setTabIcon({
                                                    tabId: focusedTabId,
                                                    icon: "custom:custom5",
                                                    iconAlt: "Continuation Sheet Details"
                                                });
                                            })
                                            .catch(function(error) {
                                                console.log(error);
                                            });
                                        })
                                    });
                                    
                                }
                                
                            }
                        })
                        //$A.enqueueAction(action);
                        
                    /*}
                    else{
                        //component.set("v.IsSubmitted",true);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: '',
                            message: 'You Cannot make any changes to Record, Once the Payment Application is Submitted or Company Accepted',
                            duration: "5000",
                            key: "info_alt",
                            type: "error",
                            mode: "pester",
                        });
                        toastEvent.fire();
                        $A.get("e.force:closeQuickAction").fire();
                        //location.reload();
                    }*/
                    
                }
                    }
            }
        })
        $A.enqueueAction(action9); 
        
        
        
    }
    
})