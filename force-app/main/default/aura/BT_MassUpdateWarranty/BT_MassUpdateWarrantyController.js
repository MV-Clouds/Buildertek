({
    doInit: function (component, event, helper) {
        var pageNumber = component.get("v.pageNumber");
        var pageSize = component.get("v.pageSize");
        helper.getTableRows(component, event, helper, pageNumber, pageSize);
    },
    refreshPage: function (component, event, helper) {
        var focusedTabId = event.getParam('currentTabId');
        var workspaceAPI = component.find("workspace");

        workspaceAPI.getEnclosingTabId().then(function (tabId) {
            if (tabId == focusedTabId) {
                setTimeout(function () {
                    //location.reload()
                }, 1000);
            }
        }).catch(function (error) {
            console.log(error);
        });
    },
    onAddClick: function (component, event, helper) {
        var fields = component.get('v.fieldSetValues');
        var list = component.get('v.listOfRecords');
        var obj = {};
        for (var i in fields) {
            obj[fields[i].name] = null;
            if (fields[i].type == 'BOOLEAN') {
                obj[fields[i].name] = false;
            }
        }
        list.unshift(obj);
        component.set('v.listOfRecords', list);
    },
    closeScreen: function (component, event, helper) {
        component.set('v.isCancelModalOpen', false);
        var redirectUrl = '/one/one.app?#/sObject/' + component.get('v.recordId') + '/view';
        window.open(redirectUrl, '_self');
    },
    closeCancelModal: function (component, event, helper) {
        component.set('v.isCancelModalOpen', false);
    },
    onMassUpdate: function (component, event, helper) {
        component.set('v.isLoading', true);
        if (!component.get('v.massUpdateEnable')) {
            component.set('v.massUpdateEnable', true);
            component.set('v.isLoading', false);
        } else if (component.get('v.massUpdateEnable')) {
            helper.updateMassRecords(component, event, helper);
        }
    },

    onMassUpdateCancel: function (component, event, helper) {
        component.get('v.massUpdateEnable') ? component.set('v.isCancelModalOpen', true) : '';
    },

    deleteRecord: function (component, event, helper) {
        var target = event.target;
        var index = target.getAttribute("data-index");
        var records = component.get('v.listOfRecords');
        if (records[index].Id != undefined) {
            component.set('v.selectedRecordIndex', index);
            component.set('v.warrantyItemName', records[index].Name);
            component.set('v.isModalOpen', true);
        } else if (records[index].Id == undefined) {
            records.splice(index, 1);
            component.set('v.isModalOpen', false);
            component.set('v.listOfRecords', records);
        }
    },

    handleCancel: function (component, event, helper) {
        component.set('v.isModalOpen', false);
    },

    handleDelete: function (component, event, helper) {
        var records = component.get('v.listOfRecords');
        var index = component.get('v.selectedRecordIndex');
        if (records[index].Id != undefined) {
            helper.deleteRecord(component, event, helper, records[index].Id);
        }
    },

    handleNext: function (component, event, helper) {
        var pageNumber = component.get("v.pageNumber");
        var pageSize = component.get("v.pageSize");
        pageNumber++;
        helper.getTableRows(component, event, helper, pageNumber, pageSize);
    },

    handlePrev: function (component, event, helper) {
        var pageNumber = component.get("v.pageNumber");
        var pageSize = component.get("v.pageSize");
        pageNumber--;
        helper.getTableRows(component, event, helper, pageNumber, pageSize);
    },

    redirectWarranty: function (component, event, helper) {
        var evt = $A.get("e.force:navigateToRelatedList");
        evt.setParams({
            "relatedListId": "buildertek__Warranty_s__r",
            "parentRecordId": component.get('v.parentId')
        });
        evt.fire();
    },

    gotoURL: function (component, event, helper) {
        var recordId = component.get("v.recordId");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": '/one/one.app?#/sObject/' + recordId + '/view'
        });
        urlEvent.fire();
    }
})