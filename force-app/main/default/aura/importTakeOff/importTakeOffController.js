({
    doInit: function (component, event, helper) {
        component.set("v.Spinner", true);
        var recordId = component.get('v.recordId');
        component.set("v.quoteId", recordId);
        var action = component.get("c.fetchTakeoff");
        action.setParams({
            'searchKeyword': ''
        });

        // Fetch takeoff records with status approved
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var pageSize = component.get("v.pageSize");
                var result = response.getReturnValue();
                console.log('Quote =>', { result });
                component.set("v.takeoffList", result);
                component.set("v.totalRecords", component.get("v.takeoffList").length);
                component.set("v.startPage", 0);
                component.set("v.endPage", pageSize - 1);
                var PaginationList = [];
                for (var i = 0; i < pageSize; i++) {
                    if (component.get("v.takeoffList").length > i)
                        PaginationList.push(result[i]);
                }
                component.set('v.PaginationList', PaginationList);
                component.set("v.Spinner", false);
                var pag = component.get('v.PaginationList');
                console.log({ pag });

                console.log('Start Page ----------> ' + component.get("v.startPage"));
                console.log('End Page ----------> ' + component.get("v.endPage"));
            }
        });
        $A.enqueueAction(action);
    },

    // Handle Checkbox selection
    handleCheckedTakeoff: function (component, event, helper) {
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

    selectAll: function (component, event, helper) {
        var selectAllCheckbox = component.find("checkAllTakeoff");
        var isChecked = selectAllCheckbox.get("v.value");
        var checkboxes = component.find("checkTakeoff");
        var checkedRecordIds = [];
        
        checkboxes.forEach(function (checkbox) {
            checkbox.set("v.value", isChecked);

            if (isChecked) {
                var recordId = checkbox.get("v.text");
                checkedRecordIds.push(recordId);
            }
        });
        
        component.set("v.checkedRecordIds", checkedRecordIds);
        console.log('checkedRecordIds', checkedRecordIds);
    },

    closeModel: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    // Create quoteLine from takeoffline based on takeoff selected.
    importTakeoff: function (component, event, helper) {
        component.set("v.Spinner", true);
        var selectedRecordIds = component.get("v.checkedRecordIds");
        var quoteId = component.get("v.quoteId");
        console.log('selectedRecordIds:', selectedRecordIds);
        console.log('import quoteId', quoteId);
        if (selectedRecordIds.length === 0) {
            helper.showToast('error', 'Error', 'Please check at least one record before importing.', '3');
            component.set("v.Spinner", false);
        } else {
            var action = component.get("c.fetchTakeoffLines");
            action.setParams({
                "listOfTakeoffIds": selectedRecordIds,
                "quoteId": quoteId
            });

            action.setCallback(this, function (response) {
                var state = response.getState();
                var result = response.getReturnValue();
                component.set("v.Spinner", false);
                console.log("Result: ", result);
                if (state === "SUCCESS") {
                    if (result.Status === 'Success') {
                        helper.showToast('success', 'Success', result.Message, '3');
                        location.reload();
                    } else {
                        helper.showToast('error', 'Error', result.Message, '3');
                    }
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        console.error("Error: " + errors[0].message);
                        helper.showToast('error', 'Error', 'Error while importing QuoteLine !!!', '3');
                    }
                }
            });

            $A.enqueueAction(action);
        }
    },

    // Used for Pagination
    next: function (component, event, helper) {
        var sObjectList = component.get("v.takeoffList");
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
    },

    previous: function (component, event, helper) {
        var sObjectList = component.get("v.takeoffList");
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
    },

    // Handle search result
    onSearch: function (component, event, helper) {
        helper.doSearchHelper(component, event, helper);
    },
})