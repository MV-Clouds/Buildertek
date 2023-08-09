({
	getpoList: function (component, event, helper, pageNumber, pageSize,projectValue, vendorValue, DateValue){
        var action = component.get("c.getProducts");
        var recId = component.get("v.recordId");
        action.setParams({
            "pageNumber" : pageNumber,
            "pageSize": pageSize,
            "project" : projectValue.trim(),
            "vendor":vendorValue.trim(),
            "Datevalue" : DateValue ?  DateValue.trim() : '',
        });
        action.setCallback(this, function (result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS") {
                var resultData = result.getReturnValue();
                component.set("v.masterSchedulesList", resultData.recordList);
                component.set("v.PageNumber", resultData.pageNumber);
                component.set("v.TotalRecords", resultData.totalRecords);
                component.set("v.RecordStart", resultData.recordStart);
                component.set("v.RecordEnd", resultData.recordEnd);
                component.set(
                    "v.TotalPages",
                    Math.ceil(resultData.totalRecords / pageSize)
                );
                  var PaginationList = [];
                for (var i = 0; i < pageSize; i++) {
                    if (component.get("v.masterSchedulesList").length > i)
                        PaginationList.push(resultData.recordList[i]);
                }

                component.set('v.PaginationList', PaginationList);
                component.set("v.startPage", 0);
                component.set("v.endPage", pageSize - 1);
                component.set("v.Spinner", false);
            }
        });  
        $A.enqueueAction(action);
    } 
})