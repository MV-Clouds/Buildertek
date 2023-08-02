({
    doInit : function(component, event, helper) {
        debugger;
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then((response) => {
            let opendTab = response.tabId;
            workspaceAPI.setTabLabel({
            tabId: opendTab,
            label: "Pricing Request Lines"
        });
        workspaceAPI.setTabIcon({
            tabId: opendTab,
            icon: 'custom:custom5',
            iconAlt: 'Pricing Request Lines'
        });
    });
    
    
    
    helper.getcurr(component, event, helper);
    
     helper.getPricingreqLines(component, event, helper);
    
    
    
    var action3 = component.get("c.getSOVName");
    action3.setParams({
    recordId: component.get("v.recordId")
});
action3.setCallback(this, function (response) {
    debugger;
    if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
       // alert( response.getReturnValue());
        var  result = response.getReturnValue();
        console.log("Result of list : ",result)
        component.set("v.SOVName",result[0])
         component.set("v.SOVProjectName",result[1])
           component.set("v.SOVProjectId",result[2])
    }
});
$A.enqueueAction(action3);
    


},
    
    
    addNewRow : function(component, event, helper){
        
        var sheetLineItems = component.get("v.continuationSheetLines");        
        var index = Number(event.currentTarget.dataset.index);
        var emptyObj;
        var isocode = component.get("v.ISOCode") 
        
        if(component.get("v.IsCurrencyEnabled") == true){
            emptyObj = {
                //   'SObjectType':'buildertek__Schedule_of_Value_Lines__c',
                buildertek__Description__c: "",
                buildertek__Notes__c : "",
                CurrencyIsoCode: component.get("v.ISOCode")
                
            }
        }else{
            emptyObj = {
                //   'SObjectType':'buildertek__Schedule_of_Value_Lines__c',
                buildertek__Description__c: "",
                buildertek__Notes__c : ""
            }
        }
        
        
        sheetLineItems.splice(index+1,0,emptyObj);
        component.set("v.continuationSheetLines",sheetLineItems);
        console.log("sheetLineItems------->",sheetLineItems);
        console.log('$$$$'+component.get("v.continuationSheetLines").length);
        
    },
        
        
        closeModal : function(component, event, helper) {
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": component.get("v.recordId"),
                "slideDevName": "detail"
            });
            navEvt.fire();
            //  $A.get('e.force:refreshView').fire();  
            
            var workspaceAPI = component.find( "workspace" );
            workspaceAPI.getFocusedTabInfo().then( function( response ) {
                var focusedTabId = response.tabId;
                window.setTimeout(
                    $A.getCallback(function() {
                        workspaceAPI.closeTab( { tabId: focusedTabId } );
                        $A.get('e.force:refreshView').fire();
                    }), 1500);
            })
            
        },
            
            
            
            createContinuationSheetLines : function (component, event, helper) {
                //component.set("v.Spinner", true);
                
                component.set("v.Spinner", true);
                component.set("v.showMessage", true);
                
                debugger;
                var coIds = [];
                console.log(component.get("v.continuationSheetLines"));
                var sheetLines = component.get("v.continuationSheetLines");
                console.log(sheetLines);
                console.log(JSON.stringify(sheetLines));
                
                var recordId = component.get("v.recordId");
                
                
                
                var action = component.get("c.createSheetLines");  
                action.setParams({
                    SovLineValues : sheetLines,//component.get("v.continuationSheetLines"),
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
                            $A.get('e.force:refreshView').fire();
                             var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": component.get("v.recordId"),
                "slideDevName": "detail"
            });
                             component.set("v.Spinner", false);
                    //         $A.get('e.force:refreshView').fire();
                            navEvt.fire();
                            //  $A.get('e.force:refreshView').fire();  
                            
                            var workspaceAPI = component.find( "workspace" );
                            workspaceAPI.getFocusedTabInfo().then( function( response ) {
                                var focusedTabId = response.tabId;
                                window.setTimeout(
                                    $A.getCallback(function() {
                                        workspaceAPI.closeTab( { tabId: focusedTabId } );
                                        $A.get('e.force:refreshView').fire();
                                    }), 1500);
                            })
                           
                            
                       
                           
                            
                            
                            
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
                
                var isemptyrecord = false;
                var continuationRecordList = component.get("v.continuationSheetLines");
                
                for(var i=0; i<continuationRecordList.length; i++){
                    if(continuationRecordList[i].buildertek__Description__c == null || continuationRecordList[i].buildertek__Description__c == '' || continuationRecordList[i].buildertek__Description__c == undefined){
                        isemptyrecord = true;
                    }
                }
                
                if(isemptyrecord == false){
                    $A.enqueueAction(action);
                }else{
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
                }
                
                
            },
                
                
                
                deleteRow : function(component, event, helper){
                    debugger;
                    var target = event.target;
                    var index = Number(target.getAttribute("data-index"));
                    var records = component.get('v.continuationSheetLines');
                    if(records.length == 1 && records[index].Id == undefined){
                        
                        $A.get("e.force:refreshView").fire();
                    }else{
                        if (records[index].Id != undefined) {
                            component.set('v.deleteContinuationSheetLine', index);
                            component.set('v.isdeleteClick', true);
                        } else if (records[index].Id == undefined) {
                            
                           /* for (const item in component.get("v.continuationSheetLines")[index]) {
                                
                                if(item == 'buildertek__Scheduled_Value__c'){
                                    if(component.get("v.continuationSheetLines")[index][item]){
                                        sovtotalvalue = parseFloat(sovtotalvalue) - parseFloat(component.get("v.continuationSheetLines")[index][item].replace(/,/g,'')); 
                                    }
                                    
                                }
                                
                            } */
                            
                            records.splice(index, 1);
                            component.set('v.continuationSheetLines', records);
                        }
                    }
                    
                },
                    
                    cancelline: function (component, event, helper) {
                        component.set('v.isdeleteClick', false);
                        
                    },
                        
                        
                        
                        confirmdelete: function (component, event, helper) {
                            var records = component.get('v.continuationSheetLines');
                            var index = component.get('v.deleteContinuationSheetLine');
                           
                            
                            if (records[index].Id != undefined) {
                                var deleteSheetLine = records[index].Id;
                                component.set('v.isdeleteClick', false);
                            }
                            var actionDeleteLink;
                            actionDeleteLink = component.get("c.deletesheetline");
                            actionDeleteLink.setParams({
                                sheetlineIds: deleteSheetLine,
                                recordId: component.get("v.recordId")
                            });
                            actionDeleteLink.setCallback(this, function (response) {
                                var toastEvent = $A.get("e.force:showToast");
                                if (component.isValid() && response.getState() === "SUCCESS") {
                                    
                                    if (response.getReturnValue() == 'success') {
                                        $A.get("e.force:refreshView").fire();
                                        toastEvent.setParams({
                                            "type": "success",
                                            "title": "",
                                            "message": "Pricing Request Line Deleted Successfully."
                                        });
                                        
                                        var sheetLines = component.get("v.continuationSheetLines");
                                        if(sheetLines.length == 0){
                                            $A.get("e.force:refreshView").fire();
                                        }else{
                                            component.set("v.continuationSheetLines",sheetLines);
                                        }
                                        
                                        
                                    } else {
                                        toastEvent.setParams({
                                            "type": "error",
                                            "title": "Error!",
                                            "message": response.getReturnValue()
                                        });
                                        
                                    }
                                } else {
                                    toastEvent.setParams({
                                        "type": "error",
                                        "title": "Error",
                                        "message": response.getError()[0].message
                                    });
                                }
                                toastEvent.fire();
                            });
                            
                            $A.enqueueAction(actionDeleteLink);
                        },
    

                            
                            NavToSovRec: function (component, event, helper) {
                                var navEvt = $A.get("e.force:navigateToSObject");
                                navEvt.setParams({
                                    "recordId": component.get("v.recordId"),
                                    "slideDevName": "detail"
                                });
                                navEvt.fire();
                            }  ,
                                
                                   NavToProRec: function (component, event, helper) {
                                var navEvt = $A.get("e.force:navigateToSObject");
                                navEvt.setParams({
                                    "recordId": component.get("v.SOVProjectId"),
                                    "slideDevName": "detail"
                                });
                                navEvt.fire();
                            }  ,
        
                    
})