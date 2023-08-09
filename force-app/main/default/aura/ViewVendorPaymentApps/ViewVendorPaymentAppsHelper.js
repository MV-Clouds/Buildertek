({
	getPaymentApplications: function (component, event, helper, pageNumber, pageSize){
        var action = component.get("c.gePaymantApplications");
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

})