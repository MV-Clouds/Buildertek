({
    getRfqList: function (component, event, helper, pageNumber, pageSize){
        var action = component.get("c.getmasterContinuaionSheets");
        var recId = component.get("v.recordId");
        action.setParams({
            "pageNumber" : pageNumber,
            "pageSize": pageSize
            
            
        });
        action.setCallback(this, function (result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS") {
                var resultData = result.getReturnValue();
                /*for(var i in resultData.recordList){
                    resultData.recordList[i].budgetCheck =false;
                }*/
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
        var action = component.get("c.importContinuationSheetItems");
        action.setParams({
            Id : selectedSheetIds,
            recordId : component.get("v.recordId")
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === "SUCCESS") {
                
                if(location.href.includes("fromsovsheet")){
                    
                    
                    var loc = location.href.split('id=')[1];
                    var recordId = location.href.split('id=')[1].split('&userIdFromcommunity=')[0];
                    var commUserId = location.href.split('id=')[1].split('&userIdFromcommunity=')[1].split("&dummy=")[0];
                    
                    var address = '/continuation-sheet-page?id='+recordId+'&userIdFromcommunity='+commUserId+'&dummy=ignore'+'/';
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": address,
                        "isredirect" :false
                    });
                    urlEvent.fire();
                    $A.get('e.force:refreshView').fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                }else{
                    component.get("v.cancelCallback")();
                    component.set("v.Spinner", false);
                    $A.get('e.force:refreshView').fire();
                    //location.reload();
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": 'Continuation Sheet Lines Successfiully Imported',
                        "type": 'Success'
                    });
                    toastEvent.fire();
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