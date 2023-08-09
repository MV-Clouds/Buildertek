({
    getRfqList: function (component, event, helper, pageNumber, pageSize){
        debugger;
        var action = component.get("c.getmasterScheduleOValues");
        var recId = component.get("v.recordId");
        action.setParams({
            "pageNumber" : pageNumber,
            "pageSize": pageSize,
            "recordId" : recId
            
            
        });
        action.setCallback(this, function (result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS") {
                var resultData = result.getReturnValue();
                /*for(var i in resultData.recordList){
                    resultData.recordList[i].budgetCheck =false;
                }*/
                for ( var i = 0; i <  resultData.recordList.length; i++ ) {
                    if (  resultData.recordList[i].buildertek__Project__c ) {
                        resultData.recordList[i].buildertek__Project__c =  resultData.recordList[i].buildertek__Project__r.Name;
                    }
                }
                component.set("v.rfqRecordList", resultData.recordList);
                component.set("v.PageNumber", resultData.pageNumber);
                component.set("v.TotalRecords", resultData.totalRecords);
                component.set("v.RecordStart", resultData.recordStart);
                component.set("v.RecordEnd", resultData.recordEnd);
                component.set(
                    "v.TotalPages",
                    Math.ceil(resultData.totalRecords / pageSize)
                );
            }
        });  
        $A.enqueueAction(action);
    },
    
    importContinuationSheetItems : function(component, event, helper, selectedSheetIds, sheetId){
        debugger;
        component.set("v.Spinner", true);
        component.set("v.showMessage", true);
        
        var action = component.get("c.importScheduleOfValueItems");
        // var appId = component.get("v.paymentAppId");
        action.setParams({
            IdList : selectedSheetIds,
            recordId : component.get("v.recordId")
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            
            if (state === "SUCCESS") {
                //  component.get("v.cancelCallback")();
                // component.set("v.Spinner", false);
                //  $A.get('e.force:refreshView').fire();
                //location.reload();
                
                
                component.set("v.Spinner", false);
                component.set("v.showMessage", false);
                
                if(location.href.includes("fromsovsheet")){
                    var address = '/schedule-of-value-lines?id='+component.get("v.recordId")+'&dummy=ignore'+'/';
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": address,
                        "isredirect" :false
                    });
                    urlEvent.fire();
                    $A.get('e.force:refreshView').fire();
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": 'SOV Lines Successfully Imported',
                        "type": 'Success'
                    });
                    toastEvent.fire(); 
                    
                }else{
                    
                    var fromSheet = component.get("v.address");
                    if(fromSheet == 'SOVSheetfromsalesforce'){
                        
                        var evt = $A.get("e.force:navigateToComponent");
                        evt.setParams({
                            componentDef : "c:ScheduleOfValueLines",
                            componentAttributes: {
                                recordId : component.get("v.recordId"),
                            }
                        });
                        evt.fire();
                        
                        var workspaceAPI = component.find( "workspace" );
                        workspaceAPI.getFocusedTabInfo().then( function( response ) {
                            var focusedTabId = response.tabId;
                            window.setTimeout(
                                $A.getCallback(function() {
                                    workspaceAPI.closeTab( { tabId: focusedTabId } );
                                    
                                }), 1500);  
                        })
                        
                        $A.get('e.force:refreshView').fire();
                        
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": 'SOV Lines Successfully Imported',
                            "type": 'Success'
                        });
                        toastEvent.fire();                         
                        
                        
                        
                        
                        
                    }else{
                        
                        
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": component.get("v.recordId"),
                            "slideDevName": "detail"
                        });
                        navEvt.fire();
                        
                        debugger;
                        var workspaceAPI = component.find( "workspace" );
                        workspaceAPI.getFocusedTabInfo().then( function( response ) {
                            var focusedTabId = response.tabId;
                            window.setTimeout(
                                $A.getCallback(function() {
                                    workspaceAPI.closeTab( { tabId: focusedTabId } );
                                    
                                }), 1000);
                        })
                        //  $A.get('e.force:refreshView').fire();
                        
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": 'SOV Lines Successfully Imported',
                            "type": 'Success'
                        });
                        toastEvent.fire(); 
                    }
                    
                }
                
            }else{
                this.showErrorToast(component, event, helper, 'Error', response.getReturnValue());
            }
            
        }); 
        $A.enqueueAction(action);
    },
    
    showErrorToast: function (component, event, helper, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            duration: "5000",
            key: "info_alt",
            type: "error",
            mode: "pester",
        });
        toastEvent.fire();
    },
    showSuccessToast: function (component, event, helper, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            duration: "5000",
            key: "info_alt",
            type: "success",
            mode: "pester",
        });
        toastEvent.fire();
    },
})