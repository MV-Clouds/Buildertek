({
    doInit: function (component, event, helper) {
        component.get('v.recordId') != undefined ? helper.getAllMasterSelection(component, event, helper) : '';
    },

    onChangeHandler: function (component, event, helper) {
        var selectedId = event.getSource().get("v.text");
        var records = component.get('v.recordList');
        for (var i in records) {
            if (records[i].Id == selectedId) {
                records[i].buildertek__Is_Selected__c = !records[i].buildertek__Is_Selected__c;
            }
        }
        component.set('v.recordList', records);
    },

    selectionChange: function (component, event, helper) {},

    selectAll: function (component, event, helper) {
        var selectedHeaderCheck = event.getSource().get("v.value");
        var records = component.get("v.recordList");
        var getAllId = component.find("checkSelected");
        if (records != null) {
            if (records.length > 1) {
                if (!Array.isArray(getAllId)) {
                    if (selectedHeaderCheck == true) {
                        component.find("checkSelected").set("v.value", true);
                    } else {
                        component.find("checkSelected").set("v.value", false);
                    }
                } else {
                    if (selectedHeaderCheck == true) {
                        for (var i = 0; i < getAllId.length; i++) {
                            component.find("checkSelected")[i].set("v.value", true);
                            var checkbox = component.find("checkSelected")[i].get("v.text");
                            records[i].buildertek__Is_Selected__c = true;
                        }
                    } else {
                        for (var i = 0; i < getAllId.length; i++) {
                            component.find("checkSelected")[i].set("v.value", false);
                            var checkbox = component.find("checkSelected")[i].get("v.text");
                            var records = component.get("v.selectionList");
                            records[i].buildertek__Is_Selected__c = false;
                        }
                    }
                }
            } else {
                var i = 0;
                if (selectedHeaderCheck == true) {
                    component.find("checkSelected").set("v.value", true);
                    var checkbox = component.find("checkSelected").get("v.text");
                    records[i].buildertek__Is_Selected__c = true;
                } else {
                    component.find("checkSelected").set("v.value", false);
                    var checkbox = component.find("checkSelected").get("v.text");
                    var records = component.get("v.selectionList");
                    records[i].buildertek__Is_Selected__c = false;
                }
            }
        }
        component.set('v.recordList', records);
    },

    next: function (component, event, helper) {
        var records = component.get("v.recordList");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var Paginationlist = [];
        var counter = 0;
        for (var i = end + 1; i < end + pageSize + 1; i++) {
            if (records.length > i) {
                Paginationlist.push(records[i]);
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
        var records = component.get("v.recordList");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var Paginationlist = [];
        var counter = 0;
        for (var i = start - pageSize; i < start; i++) {
            if (i > -1) {
                Paginationlist.push(records[i]);
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

    closeModel: function (component, event, helper) {
        component.find("overlayLib").notifyClose();
    },

    importRecords: function (component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        component.set('v.loading', true);
        var selectedRecords = [];
        var records = component.get('v.recordList');
        if (records != undefined) {
            for (var i in records) {
                if (records[i].buildertek__Is_Selected__c) {
                    selectedRecords.push(records[i].Id);
                }
            }
        }
        if (selectedRecords.length > 0) {
            helper.importMasterToDo(component, event, helper, selectedRecords);
        } else {
            component.set('v.loading', false);
            toastEvent.setParams({
                "type": 'error',
                "title": "Error!",
                "message": "Select To Do's"
            });
            toastEvent.fire();
        }
    },
})