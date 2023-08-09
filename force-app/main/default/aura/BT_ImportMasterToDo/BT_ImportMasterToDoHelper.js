({
    getAllMasterSelection: function (component, event, helper) {
        var action = component.get('c.getAllMaseterRecords');
        action.setParams({
            "recordId": component.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS" && response.getReturnValue()) {
                var records = response.getReturnValue();
                var pageSize = component.get("v.pageSize");

                if (records != undefined) {
                    for (var i in records) {
                        if (records[i].Id != undefined) {
                            records[i].buildertek__Is_Selected__c = false;
                        }
                    }
                    component.set('v.recordList', records);
                    component.set('v.totalRecords', records.length);
                    component.set("v.startPage", 0);
                    component.set("v.endPage", pageSize - 1);
                    var PaginationList = [];
                    for (var i = 0; i < pageSize; i++) {
                        if (component.get("v.recordList").length > i)
                            PaginationList.push(records[i]);
                    }
                    component.set('v.PaginationList', PaginationList);
                }
            }
        });
        $A.enqueueAction(action);
    },

    importMasterToDo: function (component, event, helper, selectedRecords) {
        var toastEvent = $A.get("e.force:showToast");
        var action = component.get('c.importToDoRecords');
        action.setParams({
            "recordId": component.get('v.recordId'),
            "selectedRecordId": selectedRecords
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.loading', false);
                toastEvent.setParams({
                    "type": 'success',
                    "title": "Success!",
                    "message": "Master To Do's Imported!"
                });
                toastEvent.fire();
                component.find("overlayLib").notifyClose();
                window.location.reload();
            } else {
                component.set('v.loading', false);
                toastEvent.setParams({
                    "type": 'error',
                    "title": "Error!",
                    "message": "Something Went Wrong!"
                });
                toastEvent.fire();
                component.find("overlayLib").notifyClose();
            }
        });
        $A.enqueueAction(action);
    },
})