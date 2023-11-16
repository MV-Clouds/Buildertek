({
    doSearchHelper: function (component, event, helper) {
        
        var searchKeyword = component.get('v.searchKeyword');
        console.log('searchKeyword', searchKeyword);
        var action = component.get("c.getInspection");
        action.setParams({
            'searchKeyword': searchKeyword
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result ==> ', { result });
                component.set("v.disableBtn", false);
                var pageSize = component.get("v.pageSize");
                var result = response.getReturnValue();
                console.log('Result =>', { result });
                component.set("v.inspectionList", result);
                component.set("v.totalRecords", component.get("v.inspectionList").length - 1);
                component.set("v.startPage", 0);
                component.set("v.endPage", pageSize - 1);
                var PaginationList = [];
                for (var i = 0; i < pageSize; i++) {
                    if (component.get("v.inspectionList").length > i)
                        PaginationList.push(result[i]);
                }
                component.set('v.PaginationList', PaginationList);
                component.set("v.Spinner", false);
                var pag = component.get('v.PaginationList');
                console.log({ pag });
            } else {
                var error = response.getError();
                console.log('Error =>', { error });
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": 'Error',
                    "type": 'Error',
                    "message": 'Something Went Wrong',
                    "duration": '5000'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },

    showToast: function (type, title, message, time) {
        try {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": title,
                "type": type,
                "message": message,
                "duration": time
            });
            toastEvent.fire();
        } catch (error) {
            console.log({ error });
        }
    },
    updateCheckboxValues: function (component) {
        var PaginationList = component.get("v.PaginationList");
        var checkedRecordIds = component.get("v.checkedRecordIds");
    
        // Iterate through PaginationList and update checkbox values
        PaginationList.forEach(function (record) {
            // Get the record ID for the checkbox
            var recordId = record.Id;
    
            // Get the checkbox by name attribute
            var checkboxes = component.find("checkInspection");
    
            // If there are multiple checkboxes, component.find() returns an array
            if (Array.isArray(checkboxes)) {
                // Loop through the array of checkboxes
                checkboxes.forEach(function (checkbox) {
                    if (checkbox.get("v.text") === recordId) {
                        // Update the checkbox value based on checkedRecordIds
                        checkbox.set("v.value", checkedRecordIds.includes(recordId));
                    }
                });
            } else {
                // If there's only one checkbox
                if (checkboxes.get("v.text") === recordId) {
                    // Update the checkbox value based on checkedRecordIds
                    checkboxes.set("v.value", checkedRecordIds.includes(recordId));
                }
            }
        });
    },
    
    
    
})