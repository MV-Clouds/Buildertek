({
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
    addRFQToBudget :function (component, event, helper, rfqIds, budgetId) {
        var action = component.get("c.addRfqLinesToBudget");
        action.setParams({
            "rfqIds" : rfqIds,
            "budgetId" : budgetId
        });
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
                console.log(response);
                helper.showSuccessToast(component,event,helper, "Success!",'Successfully added RFQ to Budget!');
                $A.get("e.force:closeQuickAction").fire();
                setTimeout(function(){ location.reload(); }, 1800);
                
            }else{
                helper.showErrorToast(component,event,helper,"Error occurs","Something went wrong!");
            }
        });
        $A.enqueueAction(action);
    },
    getRfqList: function (component, event, helper, pageNumber, pageSize, vendorValue, tradeValue, descriptionValue){
        var action = component.get("c.getRFQs");
        /*action.setCallback(this, function (response) {
            if(response.getState() == "SUCCESS"){
                console.log(response.getReturnValue());
                var list = JSON.parse(JSON.stringify(response.getReturnValue()));
                for(var i=0;i<list.length;i++){
                    if(list[i].buildertek__Vendor__r != null || list[i].buildertek__Vendor__r != undefined){
                        list[i]['vendorName'] = list[i].buildertek__Vendor__r.Name;
                    }else{
                        list[i]['vendorName'] = "";
                    }
                }
                component.set("v.rfqRecordList",list);
            }
            
        }) */
        var recId = component.get("v.recordId");
        action.setParams({
            "budgetId":component.get('v.recordId'),
            "pageNumber" : pageNumber,
            "pageSize": pageSize,
            "RFQRecId" : recId,
            "vendorName" : vendorValue.trim(),
            "tradeType" : tradeValue.trim(),
            "description":descriptionValue.trim()
            
        });
        action.setCallback(this, function (result) {
            console.log(component.get('v.recordId') , ':::::::');
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
                // console.log('Total Records --> ',  resultData.totalRecords);
            }
        });  
        $A.enqueueAction(action);
    } 
})