({
    
    doInit : function(component, event, helper) {
        
        
        
          //Fetching Record Type Id  
        var recordTypeId = component.get( "v.pageReference" ).state.recordTypeId;  

        component.set("v.RecordTypeId",recordTypeId);
        
        var action = component.get("c.getUser");
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
                var commUserId = result.Id;
                if(result.IsPortalEnabled == true){
                    component.set("v.Iscommunity",true);
                    component.set("v.communityUserId",commUserId);
                    component.set("v.Vendorname",result.buildertek__Account_Id__c);
                   // component.find("sovType").set("v.value","Vendor");
                    component.find("sovstatus").set("v.value","Pending");
                }else{
                  //  component.find("sovType1").set("v.value","Standard");
                    component.find("sovstatus1").set("v.value","Pending");
                    
                    
                    var recType = component.get("c.getRecordTypeName");
                    recType.setParams({
                        recTypeId : component.get("v.RecordTypeId")
                    });
                    recType.setCallback(this, function (response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            var result = response.getReturnValue();
                            if(result != null){
                                component.set("v.RecordTypeName",result);  
                            }
                        }
                    });
                    $A.enqueueAction(recType);
                    
                    
                    var dbAction = component.get("c.Getadmindetails");
                    dbAction.setCallback(this, function (response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            var result = response.getReturnValue();
                            if(result != null){
                                component.set("v.defaultVendorname", result);  
                               // component.find("vendor").set("v.value",result);
                            }
                        }
                    });
                    $A.enqueueAction(dbAction);
                    
                }
            }

            debugger;
            var action1 = component.get("c.getParentProject");
            debugger;
            var value = helper.getParameterByName(component, event, 'inContextOfRef');
            var context = '';
            var parentRecordId = '';
            component.set("v.parentRecordId", parentRecordId);
            if (value != null) {
                context = JSON.parse(window.atob(value));
                parentRecordId = context.attributes.recordId;
                component.set("v.parentRecordId", parentRecordId);
            } else {
                var relatedList = window.location.pathname;
                var stringList = relatedList.split("/");
                parentRecordId = stringList[4];
                if (parentRecordId == 'related') {
                    var stringList = relatedList.split("/");
                    parentRecordId = stringList[3];
                }
                component.set("v.parentRecordId", parentRecordId);
            }
            if(parentRecordId != null && parentRecordId != ''){
                var action1 = component.get("c.getParentProject");
                action1.setParams({
                    recordId: parentRecordId,
                });
                action1.setCallback(this, function (response) {
                    if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                        var objName = response.getReturnValue();
                        if(objName == 'buildertek__Project__c'){
                            component.set("v.parentprojectRecordId", parentRecordId);
                        }
                    } 
                });
                $A.enqueueAction(action1);
            }
        });
        $A.enqueueAction(action);
    },
    handleOnSubmit : function(component, event, helper) {
        debugger;
        component.set("v.Spinner", true);
        component.set("v.showMessage", true);
        event.preventDefault(); //Prevent default submit
         var eventFields = event.getParam("fields"); 
        if(component.get("v.RecordTypeName") != null &&  component.get("v.RecordTypeName") != undefined){
            eventFields["buildertek__Type__c"] = component.get("v.RecordTypeName"); 
        }
        if(component.get("v.Iscommunity") == true){
            if(component.get("v.Vendorname") != null && component.get("v.Vendorname") != undefined){
                eventFields["buildertek__Vendor__c"] = component.get("v.Vendorname"); 
            }
            component.find('leadCreateForm').submit(eventFields);
            component.set("v.applicationValues",eventFields)
        }else{
            component.find('leadCreateForm').submit(eventFields);
            component.set("v.applicationValues",eventFields)
        }
    },
    handleOnSuccess : function(component, event, helper) {
        debugger;
        component.set("v.Spinner", false);
        component.set("v.showMessage", false);
        var payload = event.getParams().response;
        console.log(payload.id);
        component.set("v.recordId",payload.id)
        component.set("v.isOpen", true);
        if(component.get("v.Iscommunity") == true){
            if(component.get("v.isSaveAndNew") == false){
                var action = component.get("c.updateSubmittedDate");
                action.setParams({
                    recordId : payload.id
                });
                action.setCallback(this, function(response){
                    if(response.getState() === "SUCCESS"){
                        var result = response.getReturnValue();
                    }
                });
                $A.enqueueAction(action); 
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": component.get("v.recordId"),
                    "slideDevName": "detail"
                });
                navEvt.fire();
                
            }else if(component.get("v.newattr")){
                var address = '/import-master-sov?recordId='+component.get("v.recordId")+'&dummy=ignore'+'/';
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": address,
                    "isredirect" :true
                });
                urlEvent.fire();
            }else{
                var action = component.get("c.updateSubmittedDate");
                action.setParams({
                    recordId : payload.id
                });
                action.setCallback(this, function(response){
                    if(response.getState() === "SUCCESS"){
                        var result = response.getReturnValue();
                    }
                });
                $A.enqueueAction(action);            
                var address = '/schedule-of-value-lines?id='+component.get("v.recordId")+'&dummy=ignore'+'/';
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": address,
                    "isredirect" :true
                });
                urlEvent.fire();
            }
            
        }else{
            
            var action3 = component.get("c.GivingSharingForMasterSov");
            
            action3.setParams({
                recordId : component.get("v.recordId")
            });
            action3.setCallback(this, function(response){
                if(response.getState() === "SUCCESS"){
                    var result = response.getReturnValue();
                }
            });
            $A.enqueueAction(action3);  
            var recordIdval =  component.get("v.recordId");
            if(component.get("v.isSaveAndNew") == false){
                
                
                var workspaceAPI = component.find("workspace");
                workspaceAPI.getFocusedTabInfo().then(function (response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.closeTab({
                        tabId: focusedTabId
                    });
                }).catch(function (error) {
                    console.log('Error', JSON.stringify(error));
                });
                setTimeout(function () {
                    component.set('v.isLoading', false);
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        /*  "recordId": component.get("v.recordId"),
                    "slideDevName": "detail"*/
                        "recordId": payload.id,
                        "slideDevName": "related"
                    });
                    navEvt.fire();
                }, 200);
                
                
                
                
                
            }
            else if(component.get("v.newattr")){
                debugger;
                
                
                var action2 = component.get("c.getVendorSovList");
                action2.setParams({
                    recordId: component.get("v.recordId")
                });
                action2.setCallback(this, function(response){
                    debugger;
                    if(response.getState() === "SUCCESS"){
                        var result = response.getReturnValue();
                        if(result == null){
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : "Error!",
                                message : 'There are No Vendor Submitted Or Company Approved SOVs for this Project',
                                type: 'error',
                                duration: '1000',
                                key: 'info_alt',
                                mode: 'pester'
                            });
                            toastEvent.fire();
                        }else{
                            var recordId = recordIdval;
                            
                            
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
                                            "componentName": "buildertek__BT_ImportSOVsForNewOverrideButton"
                                        },
                                        "state": {
                                            "buildertek__parentId": recordId
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
                                            label: "Import Vendor SOVs",
                                        });
                                        workspaceAPI.setTabIcon({
                                            tabId: focusedTabId,
                                            icon: "custom:custom5",
                                            iconAlt: "Import Vendor SOVs"
                                        });
                                    })
                                    .catch(function(error) {
                                        console.log(error);
                                    });
                                })
                            });     
                            
                            var workspaceAPI = component.find( "workspace" );
                            workspaceAPI.getFocusedTabInfo().then( function( response ) {
                                var focusedTabId = response.tabId;
                                window.setTimeout(
                                    $A.getCallback(function() {
                                        workspaceAPI.closeTab( { tabId: focusedTabId } );
                                        
                                    }), 1500);
                            }) 
                        }
                    }
                });
                $A.enqueueAction(action2);
                
                
            }
                else{
                    debugger;
            
                    var recordId = recordIdval;
                    
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
                                    "componentName": "buildertek__ScheduleOfValueLines"
                                },
                                "state": {
                                    "buildertek__parentId": recordId
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
                                    label: "View SOV Lines",
                                });
                                workspaceAPI.setTabIcon({
                                    tabId: focusedTabId,
                                    icon: "custom:custom5",
                                    iconAlt: "View SOV Lines"
                                });
                            })
                            .catch(function(error) {
                                console.log(error);
                            });
                        })
                    });     
                    
                    var workspaceAPI = component.find( "workspace" );
                    workspaceAPI.getFocusedTabInfo().then( function( response ) {
                        var focusedTabId = response.tabId;
                        window.setTimeout(
                            $A.getCallback(function() {
                                workspaceAPI.closeTab( { tabId: focusedTabId } );
                                
                            }), 2000);
                    })
                    
                }
            
        }
    },
    
    handleError: function (cmp, event, helper) {
        debugger;
        var error = event.getParams();
        
        // Get the error message
        var errorMessage = event.getParam("message");
    },
    
    CloseScreen : function(component, event, helper) {
        
        var action = component.get("c.getListViews");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var listviews = response.getReturnValue();
                var navEvent = $A.get("e.force:navigateToList");
                navEvent.setParams({
                    "listViewId": listviews.Id,
                    "listViewName": null,
                    "scope": "buildertek__Schedule_of_Values__c"
                });
                navEvent.fire();
               
            }
        });
        $A.enqueueAction(action);
        
        
       var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({tabId: focusedTabId}).then(function(response) {
                    setTimeout($A.getCallback(function() {
                        location.reload()
                     // $A.get('e.force:refreshView').fire();
                    }), 800);  
                })
                 
            })
            .catch(function(error) {
                console.log(error);
            });
        

        
        
     //   component.set("v.isOpen",true);
        
        
    },
    
    saveandclose : function(component, event, helper) {
        
    },
    
    setSaveAndNewFasle :  function (component, event, helper) {
        debugger;
        component.set("v.isSaveAndNew",false);
        component.set("v.newattr",false)
    },
    saveImportMasterSOV : function (component, event, helper) {
        debugger;
        component.set("v.newattr",true)
        // component.set("v.isSaveAndNew",false);
        
        
    }
    
    
})