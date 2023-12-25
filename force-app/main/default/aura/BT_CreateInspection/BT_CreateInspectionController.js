({
    doInit: function (component, event, helper) {
        component.set("v.Spinner", true);
        var recordId = component.get('v.recordId');
        component.set("v.permitId", recordId);
        var action = component.get("c.getInspection");
        action.setParams({
            'searchKeyword': ''
        });

        // Fetch Inspection records with Type Master
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var pageSize = component.get("v.pageSize");
                var result = response.getReturnValue();
                console.log('Master Inspection ==>', { result });
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

                console.log('Start Page ----------> ' + component.get("v.startPage"));
                console.log('End Page ----------> ' + component.get("v.endPage"));
                console.log('Total Records ---------> ' + component.get("v.totalRecords"));
            }
        });
        $A.enqueueAction(action);
    },

    // Handle Checkbox selection
    handleCheckbox: function (component, event, helper) {
        var checkbox = event.getSource();
        var isChecked = checkbox.get("v.value");
        var recordId = checkbox.get("v.text");
        var checkedRecordIds = component.get("v.checkedRecordIds");
        console.log(`isChecked: ${isChecked} recordId: ${recordId}`);
        if (isChecked) {
            checkedRecordIds.push(recordId);
        } else {
            var index = checkedRecordIds.indexOf(recordId);
            if (index !== -1) {
                checkedRecordIds.splice(index, 1);
            }
        }

        component.set("v.checkedRecordIds", checkedRecordIds);
        console.log('checkedRecordIds', checkedRecordIds);
    },

    closeModel: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    // Create Inspection and InspectionLine
    createInspection: function (component, event, helper) {
        component.set("v.Spinner", true);
        var selectedRecordIds = component.get("v.checkedRecordIds");
        var permitId = component.get("v.permitId");
        console.log('selectedRecordIds:', selectedRecordIds);
        if (selectedRecordIds.length === 0) {
            helper.showToast('error', 'Error', 'Please check at least one record before creating inspection.', '3');
            component.set("v.Spinner", false);
        } else {
            var action = component.get("c.createInspectionAndInspectionLine");
            action.setParams({
                "listOfInspectionId": selectedRecordIds,
                "permitId": permitId
            });

            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    console.log("Result: ", result);
                    component.set("v.Spinner", false);
                    helper.showToast('success', 'Success', 'Inspection Created Successfully!', '3');
                    $A.get("e.force:closeQuickAction").fire();
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        console.error("Error: " + errors[0].message);
                        helper.showToast('error', 'Error', 'Error while creating inspection!', '3');
                    }
                    component.set("v.Spinner", false);
                }
            });

            $A.enqueueAction(action);
        }
    },

    // Used for Pagination
    next: function (component, event, helper) {
        var sObjectList = component.get("v.inspectionList");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var Paginationlist = [];
        var counter = 0;
        for (var i = end + 1; i < end + pageSize + 1; i++) {
            if (sObjectList.length > i) {
                Paginationlist.push(sObjectList[i]);
            }
            counter++;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage", start);
        component.set("v.endPage", end);
        component.set('v.PaginationList', Paginationlist);
        helper.updateCheckboxValues(component);
    },

    previous: function (component, event, helper) {
        var sObjectList = component.get("v.inspectionList");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var Paginationlist = [];
        var counter = 0;
        for (var i = start - pageSize; i < start; i++) {
            if (i > -1) {
                Paginationlist.push(sObjectList[i]);
                counter++;
            } else {
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage", start);
        component.set("v.endPage", end);
        component.set('v.PaginationList', Paginationlist);
        helper.updateCheckboxValues(component);
    },

    // Handle search result
    onSearch: function (component, event, helper) {
        helper.doSearchHelper(component, event, helper);
    },
})