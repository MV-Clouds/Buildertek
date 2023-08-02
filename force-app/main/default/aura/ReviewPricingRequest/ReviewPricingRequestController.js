({
    doInit : function(component, event, helper) {
        
        
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then((response) => {
            let opendTab = response.tabId;
            workspaceAPI.setTabLabel({
            tabId: opendTab,
            label: "Review Pricing Request"
        });
        workspaceAPI.setTabIcon({
            tabId: opendTab,
            icon: 'custom:custom5',
            iconAlt: 'Review Pricing Request'
        });
    });
    
    var recordId = component.get("v.recordId");
    
    var action3 = component.get("c.getSOVName");
    action3.setParams({
    recordId: component.get("v.recordId")
});
action3.setCallback(this, function (response) {
    debugger;
    if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
        var  result = response.getReturnValue();
        component.set("v.SOVName",result)
    }
});
$A.enqueueAction(action3);


helper.getcurr(component, event, helper);

helper.fetchSOVLinesList(component,event,helper,recordId);

},
    
    
    closeModal : function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId"),
            "slideDevName": "detail"
        });
        navEvt.fire(); 
        
        
        
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId}).then(function(response) {
                setTimeout($A.getCallback(function() {
                    $A.get('e.force:refreshView').fire();
                }), 800);  
            })
            
        })
        .catch(function(error) {
            console.log(error);
        });
        
        
    },
        
        
        ApproveSOVs : function(component, event, helper){
            
            debugger;
            var target = event.target;
            var selectId = target.getAttribute("data-index");
            
            component.set("v.ApprovedSOVid",selectId);
            component.set("v.isApproveClick", true);
        },
            
            
            
            
            cancelSingleApprove: function (component, event, helper) {
                debugger;
               component.set("v.isApproveClick", false);
               // component.set('v.isApproveAllClick', false);
            },
                
                
                
                confirmApprove: function (component, event, helper) {
                    var action = component.get("c.ApproveSovLines");
                    action.setParams({
                        "sovLineIds": component.get("v.ApprovedSOVid")         
                    });
                    action.setCallback(this, function (response) {
                        if (response.getState() == 'SUCCESS') {
                            component.set('v.isApproveClick', false);
                            
                            var  result = response.getReturnValue();
                            
                            if(result == 'success'){
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    mode: 'sticky',
                                    message: 'Pricing Request Lines are Approved Successfully.',
                                    type: 'success',
                                    duration: '5000',
                                    mode: 'dismissible'
                                });
                                toastEvent.fire();
                            }
                            
                            $A.get('e.force:refreshView').fire();
                        } 
                        else {
                            console.log('Error');
                        }
                    });
                    $A.enqueueAction(action);
                    
                },
                    
                    
                    RejectSOVs : function(component, event, helper){
                        var target = event.target;
                        var selectId = target.getAttribute("data-index");
                        
                        component.set("v.RejectSOVid",selectId);
                        component.set("v.isRejectClick", true);
                    },
                        
                        cancelReject: function (component, event, helper) {
                            component.set("v.rejectionreason",'');
                            component.set('v.isRejectClick', false);
                        },
                            
                            
                            
                            confirmReject: function (component, event, helper) {
                                
                                debugger;                            var value =  component.get("v.RejectSOVid");
                                var action = component.get("c.rejectSovLines");
                                action.setParams({
                                    "sovLineIds": component.get("v.RejectSOVid"),
                                    "rejectReason" : component.get("v.rejectionreason")
                                });
                                action.setCallback(this, function (response) {
                                    if (response.getState() == 'SUCCESS') {
                                        component.set('v.isRejectClick', false);
                                        
                                        var  result = response.getReturnValue();
                                        // alert(JSON.stringify(result));
                                        if(result == 'success'){
                                            var toastEvent = $A.get("e.force:showToast");
                                            toastEvent.setParams({
                                                mode: 'sticky',
                                                message: 'Pricing Request Lines are Rejected Successfully.',
                                                type: 'success',
                                                duration: '5000',
                                                mode: 'dismissible'
                                            });
                                            toastEvent.fire();
                                        }
                                        
                                        $A.get('e.force:refreshView').fire();
                                        
                                        //  component.set("v.editreject",result);
                                        
                                    } 
                                    else {
                                        console.log('Error');
                                    }
                                });
                                
                                
                                if(component.get('v.rejectionreason') != null && component.get('v.rejectionreason') != undefined && component.get('v.rejectionreason') != ''){
                                    $A.enqueueAction(action);
                                }else{
                                    var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        "type": "error",
                                        "title": "Error",
                                        "message": "Please Complete this field."
                                    }); 
                                    toastEvent.fire();
                                } 
                                // $A.enqueueAction(action);
                            },
                                
                                
                                NavToSovRec: function (component, event, helper) {
                                    var navEvt = $A.get("e.force:navigateToSObject");
                                    navEvt.setParams({
                                        "recordId": component.get("v.recordId"),
                                        "slideDevName": "detail"
                                    });
                                    navEvt.fire();
                                }  ,
                                    
                                    
                                    
                                    createContinuationSheetLines : function (component, event, helper) {
                                        //component.set("v.Spinner", true);
                                        
                                        component.set("v.Spinner", true);
                                        component.set("v.showMessage", true);
                                        
                                        debugger;
                                        var coIds = [];
                                        console.log(component.get("v.sovLineList"));
                                        var sheetLines = component.get("v.sovLineList");
                                        console.log(sheetLines);
                                        console.log(JSON.stringify(sheetLines));
                                        
                                        var recordId = component.get("v.recordId");
                                        
                                        
                                        
                                        var action = component.get("c.createSheetLines");  
                                        action.setParams({
                                            SovLineValues : sheetLines,//component.get("v.sovLineList"),
                                            recordId : recordId
                                        });
                                        action.setCallback(this, function(response){
                                            debugger;
                                            var state = response.getState();
                                            if(state === "SUCCESS"){
                                                component.set("v.Spinner", false);
                                                component.set("v.showMessage", false);
                                                
                                                var result = response.getReturnValue();  
                                                if(result.Status === 'Success'){
                                                    var toastEvent = $A.get("e.force:showToast");
                                                    toastEvent.setParams({
                                                        "title": "Success!",
                                                        "message": result.Message,
                                                        "type": 'Success'
                                                    });
                                                    toastEvent.fire(); 
                                                    component.set("v.Spinner", false);
                                                    
                                                    
                                                    /*    var navEvt = $A.get("e.force:navigateToSObject");
                            navEvt.setParams({
                                "recordId": component.get("v.recordId"),
                                "slideDevName": "detail"
                            });
                            navEvt.fire(); */
                                                    
                                                    $A.get('e.force:refreshView').fire();
                                                    
                                                    
                                                    
                                                }else{
                                                    component.set("v.Spinner", false);
                                                    var toastEvent = $A.get("e.force:showToast");
                                                    toastEvent.setParams({
                                                        "title": "Error!",
                                                        "message": result.Message,
                                                        "type": 'error'
                                                    });
                                                    toastEvent.fire();    
                                                }
                                                
                                                component.set("v.isEditable",true);
                                                
                                            }else{
                                                console.log(response.getError());
                                            }
                                        });
                                        
                                      //  var isemptyrecord = false;
                                        var continuationRecordList = component.get("v.sovLineList");
                                        
                                    /*    for(var i=0; i<continuationRecordList.length; i++){
                                            if(continuationRecordList[i].buildertek__Description__c == null || continuationRecordList[i].buildertek__Description__c == '' || continuationRecordList[i].buildertek__Description__c == undefined){
                                                isemptyrecord = true;
                                            }
                                        }*/
                                        
                                       // if(isemptyrecord == false){
                                            $A.enqueueAction(action);
                                      /*  }else{
                                            component.set("v.Spinner", false);
                                            component.set("v.showMessage", false);
                                            
                                            var toastEvent = $A.get("e.force:showToast");
                                            toastEvent.setParams({
                                                title: 'Error',
                                                message: 'Description is Required',
                                                duration: "5000",
                                                key: "info_alt",
                                                type: "error",
                                            });
                                            toastEvent.fire();
                                        }*/
                                        
                                        
                                    },
                                        
                                        
                                        
                                        AcceptAll :  function(component, event, helper) {
                                            
                                            component.set('v.isApproveAllClick', true);
                                            
                                        },
                                            
                                            
                                            cancelApprove: function (component, event, helper) {
                                                component.set('v.isApproveAllClick', false);
                                            },
                                                
                                                
                                                
                                                confirmApproveAll :  function(component, event, helper) {
                                                    //var SovIds = component.get("v.sovLineListIds");
                                                    var action = component.get("c.getAllApproved");
                                                    action.setParams({
                                                        "sovLineIds": component.get("v.sovLineListIds")         
                                                    });
                                                    action.setCallback(this, function (response) {
                                                        var  result = response.getReturnValue();
                                                        
                                                        if (response.getState() == 'SUCCESS') {
                                                            component.set('v.isApproveAllClick', false);
                                                            var toastEvent = $A.get("e.force:showToast");
                                                            toastEvent.setParams({
                                                                mode: 'sticky',
                                                                message: 'Pricing Request Lines are Approved Successfully.',
                                                                type: 'success',
                                                                duration: '5000',
                                                                mode: 'dismissible'
                                                            });
                                                            toastEvent.fire();
                                                            
                                                            
                                                            $A.get('e.force:refreshView').fire();
                                                        } 
                                                        else {
                                                            console.log('Error');
                                                        }
                                                    });
                                                    $A.enqueueAction(action);
                                                    
                                                },
                                                    
                                                    
                                                    
                                                    
                                                    
                                                    rejectAll :  function(component, event, helper) {
                                                        
                                                        component.set('v.isRejectAllClick', true);
                                                        
                                                    },
                                                        
                                                        
                                                        cancelRejectAll: function (component, event, helper) {
                                                            component.set('v.isRejectAllClick', false);
                                                        },
                                                            
                                                            
                                                            
                                                            confirmRejectAll :  function(component, event, helper) {
                                                                //var SovIds = component.get("v.sovLineListIds");
                                                                var action = component.get("c.getAllRejected");
                                                                action.setParams({
                                                                    "sovLineIds": component.get("v.sovLineListIds")         
                                                                });
                                                                action.setCallback(this, function (response) {
                                                                    var  result = response.getReturnValue();
                                                                    
                                                                    if (response.getState() == 'SUCCESS') {
                                                                        component.set('v.isRejectAllClick', false);
                                                                        var toastEvent = $A.get("e.force:showToast");
                                                                        toastEvent.setParams({
                                                                            mode: 'sticky',
                                                                            message: 'Pricing Request Lines are Rejected Successfully.',
                                                                            type: 'success',
                                                                            duration: '5000',
                                                                            mode: 'dismissible'
                                                                        });
                                                                        toastEvent.fire();
                                                                        
                                                                        
                                                                        $A.get('e.force:refreshView').fire();
                                                                    } 
                                                                    else {
                                                                        console.log('Error');
                                                                    }
                                                                });
                                                                $A.enqueueAction(action);
                                                                
                                                            },
                                                                
                           
                                                                
                                                                
                                                                
                                                                clearAll :  function(component, event, helper) {
                                                                    
                                                                    component.set('v.isClearAllClick', true);
                                                                    
                                                                },
                                                                    
                                                                    
                                                                    cancelclearAll: function (component, event, helper) {
                                                                        component.set('v.isClearAllClick', false);
                                                                    },                                                         
                                                                        
                                                                        
                                                                        
                                                                
                                                                
                                                                        confirmclearAll :  function(component, event, helper) {
                                                                            
                                                                var action = component.get("c.clearAllLines");
                                                                action.setParams({
                                                                    "sovLineIds": component.get("v.sovLineListIds")         
                                                                });
                                                                action.setCallback(this, function (response) {
                                                                    var  result = response.getReturnValue();
                                                                    
                                                                    if (response.getState() == 'SUCCESS') {
                                                                        component.set('v.isClearAllClick', false);
                                                                        var toastEvent = $A.get("e.force:showToast");
                                                                        toastEvent.setParams({
                                                                            mode: 'sticky',
                                                                            message: 'Pricing Request Lines are Cleared Successfully.',
                                                                            type: 'success',
                                                                            duration: '5000',
                                                                            mode: 'dismissible'
                                                                        });
                                                                        toastEvent.fire();
                                                                        
                                                                        
                                                                        $A.get('e.force:refreshView').fire();
                                                                    } 
                                                                    else {
                                                                        console.log('Error');
                                                                    }
                                                                });
                                                                $A.enqueueAction(action);
                                                                
                                                                        }   ,          





       rejectAllWithRejectReason : function(component, event, helper){
                        var target = event.target;
                        var selectId = target.getAttribute("data-index");
                        
                        component.set("v.RejectSOVid",selectId);
                        component.set("v.isRejectAllLinesClick", true);
                    },                                                          
                                                                
               
                        
                        cancelRejectAll: function (component, event, helper) {
                            component.set("v.rejectionreason",'');
                            component.set('v.isRejectAllLinesClick', false);
                        },
                            
                            
                            
                             confirmRejectAllLines: function (component, event, helper) {
                                
                                debugger;                            var value =  component.get("v.RejectSOVid");
                                var action = component.get("c.getAllRejected");
                                action.setParams({
                                     "sovLineIds": component.get("v.sovLineListIds") ,
                                    "rejectReason" : component.get("v.rejectionreason")
                                });
                                action.setCallback(this, function (response) {
                                    if (response.getState() == 'SUCCESS') {
                                        component.set('v.isRejectAllLinesClick', false);
                                        
                                        var  result = response.getReturnValue();
                                        // alert(JSON.stringify(result));
                                        if(result == 'success'){
                                            var toastEvent = $A.get("e.force:showToast");
                                            toastEvent.setParams({
                                                mode: 'sticky',
                                                message: 'Pricing Request Lines are Rejected Successfully.',
                                                type: 'success',
                                                duration: '5000',
                                                mode: 'dismissible'
                                            });
                                            toastEvent.fire();
                                        }
                                        
                                        $A.get('e.force:refreshView').fire();
                                        
                                        //  component.set("v.editreject",result);
                                        
                                    } 
                                    else {
                                        console.log('Error');
                                    }
                                });
                                
                                
                                if(component.get('v.rejectionreason') != null && component.get('v.rejectionreason') != undefined && component.get('v.rejectionreason') != ''){
                                    $A.enqueueAction(action);
                                }else{
                                    var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        "type": "error",
                                        "title": "Error",
                                        "message": "Please Complete this field."
                                    }); 
                                    toastEvent.fire();
                                } 
                                // $A.enqueueAction(action);
                            },
                                
                                
                        
                                                                
})