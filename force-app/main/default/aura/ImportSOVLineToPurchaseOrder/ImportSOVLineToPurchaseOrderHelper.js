({

    updateCheckboxValues: function (component) {
        try {
            var PaginationList = component.get("v.PaginationList");
            var checkedRecordIds = component.get("v.checkedRecordIds");
        
            // Iterate through PaginationList and update checkbox values
            PaginationList.forEach(function (record) {
                // Get the record ID for the checkbox
                var recordId = record.Id;
        
                // Get the checkbox by name attribute
                var checkboxes = component.find("checkContractor");
        
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
        } catch (error) {
            console.log('Error---> ',error);
        }
    },

    getAllSOVToImportInPO: function (component, event, helper) {

        var action = component.get("c.getAllSOV");
        action.setParams({
            projectId : component.get("v.ProjectId")
        });
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            console.log('result---> ',result);
            $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
            if(result != null){
                component.set("v.RecordExist", true);
                var pageSize = component.get("v.pageSize");
                component.set("v.allSOVList", result.SOVRecords);
                console.log('allsovlist--->',component.get("v.allSOVList"));
                component.set("v.currencycode", result.CurrSymbol);
                component.set("v.totalRecords", component.get("v.allSOVList").length - 1);
                component.set("v.startPage",0);
                component.set("v.endPage",pageSize - 1);
                var PaginationList = [];
                for(var i=0; i< pageSize; i++){
                    if(component.get("v.allSOVList").length> i)
                        PaginationList.push(result.SOVRecords[i]);    
                }
                component.set('v.PaginationList', PaginationList);
                console.log('PaginationList--->',component.get('v.PaginationList'));
            } else {
                component.set("v.MessageToDisplay", 'There are no SOV record(s) related to the Project or SOV record(s) assigned to another PO.');
                component.set("v.RecordExist", false);
            }
        });
        $A.enqueueAction(action);

    }
})