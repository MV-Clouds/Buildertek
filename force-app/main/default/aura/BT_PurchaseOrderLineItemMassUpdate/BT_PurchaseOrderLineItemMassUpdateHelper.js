({
    getTotalRecord: function (component, event, helper) {
        var action = component.get("c.getCount");
        action.setParams({
            recordId: component.get('v.recordId'),
        });
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                // debugger;
                component.set("v.TotalRecords", response.getReturnValue());
            }
        })
        $A.enqueueAction(action);
    },

    getTableFieldSet: function (component, event, helper) {
        var action = component.get("c.getFieldSet");
        action.setCallback(this, function (response) {
            var fieldSetObj = JSON.parse(response.getReturnValue());
            component.set("v.fieldSetValues", fieldSetObj);
        })
        $A.enqueueAction(action);
    },

    getTableRows: function (component, event, helper, pageNumber, pageSize) {
        component.set('v.isLoading', true);
        var action = component.get("c.getRecords");
        var fieldSetValues = component.get("v.fieldSetValues");
        var setfieldNames = new Set();

        for (var c = 0, clang = fieldSetValues.length; c < clang; c++) {
            if (!setfieldNames.has(fieldSetValues[c].name)) {
                setfieldNames.add(fieldSetValues[c].name);
                if (fieldSetValues[c].type == 'REFERENCE') {
                    if (fieldSetValues[c].name.indexOf('__c') == -1) {
                        setfieldNames.add(fieldSetValues[c].name.substring(0, fieldSetValues[c].name.indexOf('Id')) + '.Name');
                    } else {
                        setfieldNames.add(fieldSetValues[c].name.substring(0, fieldSetValues[c].name.indexOf('__c')) + '__r.Name');
                    }
                }
            }
        }

        var arrfieldNames = [];
        setfieldNames.forEach(v => arrfieldNames.push(v));
        component.set('v.arrfieldNames', arrfieldNames);
        action.setParams({
            recordId: component.get('v.recordId'),
            fieldNameJson: JSON.stringify(arrfieldNames),
            pageNumber: pageNumber,
            pageSize: pageSize
        });
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                var list = JSON.parse(response.getReturnValue());
                if (list.length > 0) {
                    component.set("v.listOfRecords", list);
                    component.set("v.cloneListOfRecords", list);
                    component.set('v.numberOfItems', list.length);
                    component.set("v.PageNumber", pageNumber);
                    component.set("v.RecordStart", (pageNumber - 1) * pageSize + 1);
                    component.set("v.RecordEnd", (list.length + 3) * pageNumber);
                    component.set("v.TotalPages", Math.ceil(list.length / component.get('v.TotalRecords')));
                    component.set('v.isLoading', false);
                    if (component.get('v.TotalRecords') < pageNumber * pageSize) {
                        component.set("v.isNextDisabled", true);
                    } else {
                        component.set("v.isNextDisabled", false);
                    }
                } else {
                    component.set("v.listOfRecords", []);
                    component.set("v.cloneListOfRecords", []);
                    component.set('v.numberOfItems', 0);
                    component.set("v.PageNumber", 1);
                    component.set("v.RecordStart", 0);
                    component.set("v.RecordEnd", 0);
                    component.set("v.TotalPages", 0);
                    component.set("v.isNextVisible", true);
                    component.set('v.isLoading', false);
                }
            } else {
                component.set("v.listOfRecords", []);
                component.set("v.cloneListOfRecords", []);
            }
        })
        $A.enqueueAction(action);
    },

    updateMassRecords: function (component, event, helper) {
        try {
            component.set('v.isLoading', true);
            var restrictUpdate = false;
            var listOfRecords = component.get('v.listOfRecords');
            listOfRecords.forEach(ele => {
                if(!restrictUpdate){
                    // Only show Error msg when Remaining Quantity exced Available Quantity First time....
                    if(ele.buildertek__Quantity__c && ele.buildertek__Quantity_Received__c){
                        // If Recived Quantities are more than Available Quantities then show error msg and restrict update
                        if(parseInt(ele.buildertek__Quantity_Received__c) > ele.buildertek__Quantity__c){
                            restrictUpdate = true;
                            
                            window.onload = showToast();        // Show  toast message on VF page --> Aura
                            function showToast() {
                                sforce.one.showToast({
                                    "title": "Error!",
                                    "message": "Received value should be less than the Remaining value.",
                                    "type": "error"
                                });
                            }                            
                            component.set('v.isLoading', false);
                        }
                    }
                }
            });
            console.log("updatedRecords >> " , JSON.parse(JSON.stringify(listOfRecords)));
            if(!restrictUpdate){
                var pageNumber = component.get("v.PageNumber");
                var pageSize = component.get("v.pageSize");
                var action = component.get("c.updateRecords");
                action.setParams({
                    recordId: component.get('v.recordId'),
                    updatedRecords: JSON.stringify(JSON.parse(JSON.stringify(listOfRecords))),
                    fieldSetName: JSON.stringify(component.get('v.arrfieldNames')),
                    pageNumber: pageNumber,
                    pageSize: pageSize
                });
        
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var list = JSON.parse(response.getReturnValue());
                        console.log('Return List >> ', list);
                        component.set('v.listOfRecords', list);
                        component.set('v.numberOfItems', list.length);
                        component.set('v.cloneListOfRecords', list);
                        component.set('v.isLoading', false);
                        component.set("v.PageNumber", pageNumber);
                        component.set("v.RecordStart", (pageNumber - 1) * pageSize + 1);
                        component.set("v.RecordEnd", (list.length + 1) * pageNumber);
                        component.set("v.TotalPages", Math.ceil(list.length / component.get('v.TotalRecords')));
                        component.set("v.massUpdateEnable", false);
                    } else if (state === "ERROR") {
                        component.set('v.isLoading', false);
                        console.log('A Problem Occurred: ' + JSON.stringify(response.error));
                        window.onload = showToast();        // Show  toast message on VF page --> Aura
                            function showToast() {
                                sforce.one.showToast({
                                    "title": "Error!",
                                    "message": "Something Went Wrong!",
                                    "type": "error"
                                });
                            }     
                    }
                });
                $A.enqueueAction(action);
            }
            
        } catch (error) {
            console.log(" error on update  >> ", error.message);
        }
    },

    deleteRecord: function (component, event, helper, deleteRecordId) {
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");

        var action = component.get("c.deleteProject");
        action.setParams({
            deleteRecordId: deleteRecordId,
            recordId: component.get('v.recordId'),
            fieldSetName: JSON.stringify(component.get('v.arrfieldNames')),
            pageNumber: pageNumber,
            pageSize: pageSize
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var list = JSON.parse(response.getReturnValue());
                component.set('v.listOfRecords', list);
                component.set('v.numberOfItems', list.length);
                component.set('v.cloneListOfRecords', list);
                component.set('v.isLoading', false);
                component.set("v.PageNumber", pageNumber);
                component.set("v.RecordStart", (pageNumber - 1) * pageSize + 1);
                component.set("v.RecordEnd", (list.length + 3) * pageNumber);
                component.set("v.TotalPages", Math.ceil(list.length / component.get('v.TotalRecords')));
            } else if (state === "ERROR") {
                component.set('v.isLoading', false);
                console.log('A Problem Occurred: ' + JSON.stringify(response.error));
            }
        });
        $A.enqueueAction(action);
    },
})