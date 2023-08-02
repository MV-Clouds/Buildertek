({
    getTableRows: function (component, event, helper, pageNumber, pageSize) {
        component.set('v.isLoading', true);
        var action = component.get("c.getWarrantyItems");

        action.setParams({
            recordId: component.get('v.recordId'),
            pageNumber: pageNumber,
            pageSize: pageSize
        });
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                
                        var focusedTabId = event.getParam('currentTabId');
        var workspaceAPI = component.find("workspace");

        workspaceAPI.getEnclosingTabId().then(function (tabId) {
            if (tabId == focusedTabId) {
                setTimeout(function () {
                    location.reload()
                }, 1000);
            }
        }).catch(function (error) {
            console.log(error);
        });
                
                var list = response.getReturnValue();
                component.set("v.listOfRecords", list.records);
                component.set("v.cloneListOfRecords", list.records);
                component.set('v.numberOfItems', list.records.length);
                component.set('v.fieldSetValues', JSON.parse(list.fieldSet));
                component.set("v.pageNumber", pageNumber);
                component.set("v.RecordStart", (pageNumber - 1) * pageSize + 1);
                component.set("v.RecordEnd", (list.length + 3) * pageNumber);
                component.set("v.TotalPages", Math.ceil(list.length / list.recordCount));
                component.set('v.isLoading', false);
                component.set('v.TotalRecords', list.recordCount)
                if (list.recordCount < pageNumber * pageSize) {
                    component.set("v.isNextDisabled", true);
                } else {
                    component.set("v.isNextDisabled", false);
                }
            } else {
                component.set("v.listOfRecords", []);
                component.set("v.cloneListOfRecords", []);
                component.set('v.numberOfItems', 0);
                component.set("v.pageNumber", 1);
                component.set("v.RecordStart", 0);
                component.set("v.RecordEnd", 0);
                component.set("v.TotalPages", 0);
                component.set("v.isNextVisible", true);
                component.set('v.isLoading', false);
            }
        })
        $A.enqueueAction(action);
    },

    updateMassRecords: function (component, event, helper) {
        component.set('v.isLoading', true);
        var listOfRecords = component.get('v.listOfRecords');
        console.log('List Of Records:0:',listOfRecords);
        console.log('List Of Records:1:',JSON.stringify(listOfRecords));
        var action = component.get("c.updateRecords");
        var pageNumber = component.get("v.pageNumber");
        var pageSize = component.get("v.pageSize");
        action.setParams({
            recordId: component.get('v.recordId'),
            updatedRecords: JSON.stringify(listOfRecords),
            pageNumber: pageNumber,
            pageSize: pageSize
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var focusedTabId = event.getParam('currentTabId');
        var workspaceAPI = component.find("workspace");

        workspaceAPI.getEnclosingTabId().then(function (tabId) {
            if (tabId == focusedTabId) {
                setTimeout(function () {
                    location.reload()
                }, 1000);
            }
        }).catch(function (error) {
            console.log(error);
        });
                var list = response.getReturnValue();
                component.set("v.listOfRecords", list.records);
                component.set("v.cloneListOfRecords", list.records);
                component.set('v.numberOfItems', list.records.length);
                component.set('v.fieldSetValues', JSON.parse(list.fieldSet));
                component.set("v.pageNumber", pageNumber);
                component.set("v.RecordStart", (pageNumber - 1) * pageSize + 1);
                component.set("v.RecordEnd", (list.length + 3) * pageNumber);
                component.set("v.TotalPages", Math.ceil(list.length / list.recordCount));
                component.set('v.isLoading', false);
                component.set('v.TotalRecords', list.recordCount)
                component.set('v.massUpdateEnable', false);
                if (list.recordCount < pageNumber * pageSize) {
                    component.set("v.isNextDisabled", true);
                } else {
                    component.set("v.isNextDisabled", false);
                }
            } else {
                component.set("v.listOfRecords", []);
                component.set("v.cloneListOfRecords", []);
                component.set('v.numberOfItems', 0);
                component.set("v.pageNumber", 1);
                component.set("v.RecordStart", 0);
                component.set("v.RecordEnd", 0);
                component.set("v.TotalPages", 0);
                component.set("v.isNextVisible", true);
                component.set('v.isLoading', false);
            }
        });
        $A.enqueueAction(action);
    },

    deleteRecord: function (component, event, helper, deleteRecordId) {
        component.set('v.isLoading', true);
        var pageNumber = component.get("v.pageNumber");
        var pageSize = component.get("v.pageSize");
        var action = component.get("c.deleteWarrantyRecord");
        action.setParams({
            deleteRecordId: deleteRecordId,
            recordId: component.get('v.recordId'),
            pageNumber: pageNumber,
            pageSize: pageSize
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                        var focusedTabId = event.getParam('currentTabId');
        var workspaceAPI = component.find("workspace");

        workspaceAPI.getEnclosingTabId().then(function (tabId) {
            if (tabId == focusedTabId) {
                setTimeout(function () {
                    location.reload()
                }, 1000);
            }
        }).catch(function (error) {
            console.log(error);
        });
                
                var list = response.getReturnValue();
                component.set("v.listOfRecords", list.records);
                component.set("v.cloneListOfRecords", list.records);
                component.set('v.numberOfItems', list.records.length);
                component.set('v.fieldSetValues', JSON.parse(list.fieldSet));
                component.set("v.pageNumber", pageNumber);
                component.set("v.RecordStart", (pageNumber - 1) * pageSize + 1);
                component.set("v.RecordEnd", (list.length + 3) * pageNumber);
                component.set("v.TotalPages", Math.ceil(list.length / list.recordCount));
                component.set('v.TotalRecords', list.recordCount);
                component.set('v.isLoading', false);
                component.set('v.isModalOpen', false);
                if (list.recordCount < pageNumber * pageSize) {
                    component.set("v.isNextDisabled", true);
                } else {
                    component.set("v.isNextDisabled", false);
                }
            } else {
                component.set("v.listOfRecords", []);
                component.set("v.cloneListOfRecords", []);
                component.set('v.numberOfItems', 0);
                component.set("v.pageNumber", 1);
                component.set("v.RecordStart", 0);
                component.set("v.RecordEnd", 0);
                component.set("v.TotalPages", 0);
                component.set("v.isNextVisible", true);
                component.set('v.isLoading', false);
                component.set('v.isModalOpen', false);
            }
        });
        $A.enqueueAction(action);
    },
})