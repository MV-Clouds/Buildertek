({
    doInit : function(component, event, helper) {
        
        var sovId = component.get("v.recordId");
        
        var action = component.get("c.getProjectId");
        action.setParams({
            "sovId": sovId            
        });
        action.setCallback(this, function (response) {
            debugger;
            if (response.getState() == 'SUCCESS') {
                var action1 = component.get("c.getSovType");
                action1.setParams({
                    "sovId": sovId            
                });
                action1.setCallback(this, function (response1) {
                    if (response1.getState() == 'SUCCESS') {
                        var result = response1.getReturnValue()
                       
                        if((result.RecordType.Name == "Vendor" || result.RecordType.Name == "Master") && result.buildertek__Status__c != 'Company Approved'){
                              
                            debugger;
                             if(response.getReturnValue() != null){
                                var recordId = response.getReturnValue();
                                
                                var workspaceAPI = component.find("workspace");
                                workspaceAPI.getFocusedTabInfo().then(function(tabResponse) {
                                    
                                    var parentTabId = tabResponse.tabId;
                                    var isSubtab = tabResponse.isSubtab;
                                    
                                    workspaceAPI.openSubtab({
                                        
                                        parentTabId: parentTabId,
                                        pageReference: {
                                            "type": "standard__component",
                                            "attributes": {
                                                "recordId" : recordId,
                                                "ManageSovId" :sovId,
                                                "componentName": "buildertek__ManageVendorSOV"
                                            },
                                            "state": {
                                                "buildertek__parentId": recordId,
                                                "buildertek__ManageSovId" : sovId
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
                                                label: "Manage Vendor SOV",
                                            });
                                            workspaceAPI.setTabIcon({
                                                tabId: focusedTabId,
                                                icon: "custom:custom5",
                                                iconAlt: "Manage vendor SOV"
                                            });
                                        })
                                        .catch(function(error) {
                                            console.log(error);
                                        });
                                    })
                                });
                                
                            }else{
                                $A.get("e.force:closeQuickAction").fire();
                                
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title : "Error!",
                                    message : 'Project is required',
                                    type: 'error',
                                    duration: '1000',
                                    key: 'info_alt',
                                    mode: 'pester'
                                });
                                toastEvent.fire(); 
                            }
                            
                            
                            
                            
                        }
                        
                        else if(result.buildertek__Status__c == 'Company Approved'){
                              $A.get("e.force:closeQuickAction").fire();
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : "Error!",
                                message : 'You cannot make changes to Company Approved SOV',
                                type: 'error',
                                duration: '1000',
                                key: 'info_alt',
                                mode: 'pester'
                            });
                            toastEvent.fire(); 
                        }
                        else if(result.buildertek__Status__c == 'Customer Approved'){
                              $A.get("e.force:closeQuickAction").fire();
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : "Error!",
                                message : 'You cannot make changes to Customer Approved SOV',
                                type: 'error',
                                duration: '1000',
                                key: 'info_alt',
                                mode: 'pester'
                            });
                            toastEvent.fire(); 
                        }
                        
                        else{
                            
                            
                            if(response.getReturnValue() != null){
                                var recordId = response.getReturnValue();
                                
                                var workspaceAPI = component.find("workspace");
                                workspaceAPI.getFocusedTabInfo().then(function(tabResponse) {
                                    
                                    var parentTabId = tabResponse.tabId;
                                    var isSubtab = tabResponse.isSubtab;
                                    
                                    workspaceAPI.openSubtab({
                                        
                                        parentTabId: parentTabId,
                                        pageReference: {
                                            "type": "standard__component",
                                            "attributes": {
                                                "recordId" : recordId,
                                                "ManageSovId" :sovId,
                                                "componentName": "buildertek__CreateMasterSovForProjectSubmitted"
                                            },
                                            "state": {
                                                "buildertek__parentId": recordId,
                                                "buildertek__ManageSovId" : sovId
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
                                                label: "Manage SOV",
                                            });
                                            workspaceAPI.setTabIcon({
                                                tabId: focusedTabId,
                                                icon: "custom:custom5",
                                                iconAlt: "Manage SOV"
                                            });
                                        })
                                        .catch(function(error) {
                                            console.log(error);
                                        });
                                    })
                                });
                                
                            }else{
                                $A.get("e.force:closeQuickAction").fire();
                                
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title : "Error!",
                                    message : 'Project is required',
                                    type: 'error',
                                    duration: '1000',
                                    key: 'info_alt',
                                    mode: 'pester'
                                });
                                toastEvent.fire(); 
                            }
                            
                        }
                    }
                });
                $A.enqueueAction(action1);
                
                
                
                
                
            }
        });
        
        $A.enqueueAction(action);
        
        
    }
})