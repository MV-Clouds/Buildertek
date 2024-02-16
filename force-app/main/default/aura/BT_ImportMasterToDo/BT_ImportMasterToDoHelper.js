({
    getAllMasterSelection: function (component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
        var action = component.get('c.getAllMaseterRecords');
        action.setParams({
            "recordId": component.get('v.recordId'),
            'searchKeyword' : ''
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var result = response.getReturnValue();
            $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
            if (state === "SUCCESS") {
                if (result.Status === 'Success') {
                    var records = result.returnToDoList;
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
                } else {
                    toastEvent.setParams({
                        "type": 'error',
                        "title": "Error!",
                        "message": result.Message
                    });
                    toastEvent.fire();
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
            $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === "SUCCESS") {
                if (result.Status === 'Success') {
                    toastEvent.setParams({
                        "type": 'success',
                        "title": "Success!",
                        "message": "Master To Do's Imported!"
                    });
                    toastEvent.fire();
                    component.find("overlayLib").notifyClose();
                    window.location.reload();
                } else {
                    toastEvent.setParams({
                        "type": 'error',
                        "title": "Error!",
                        "message": result.Message
                    });
                    toastEvent.fire();
                    component.find("overlayLib").notifyClose();
                }
            } else {
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

    doSearchHelper : function(component, event, helper) {
        var searchKeyword = component.get('v.searchKeyword');
        var action = component.get("c.getAllMaseterRecords");
        action.setParams({	
			'recordId': component.get("v.recordId"),		
            'searchKeyword' : searchKeyword
        });
		action.setCallback(this, function(response){
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === "SUCCESS") {
                if (result.Status === 'Success') {
                    var records = result.returnToDoList;
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
                } else {
                    toastEvent.setParams({
                        "type": 'error',
                        "title": "Error!",
                        "message": result.Message
                    });
                    toastEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
    },
})