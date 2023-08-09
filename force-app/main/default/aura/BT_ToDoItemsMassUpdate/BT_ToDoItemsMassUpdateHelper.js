({
    getToDoName: function (component, event, helper) {
        var action = component.get("c.getName");
        action.setParams({
            recordId: component.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            component.set('v.toDo', response.getReturnValue());
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

    getTableRows: function (component, event, helper) {
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
            parentRecordId: component.get("v.recordId"),
            fieldNameJson: JSON.stringify(arrfieldNames)
        });
        action.setCallback(this, function (response) {
            var list = JSON.parse(response.getReturnValue());
            component.set("v.listOfToDoItems", list);
            component.set("v.cloneListOfToDoItems", list);
            component.set('v.numberOfItems', list.length);
        })
        $A.enqueueAction(action);
    },

    updateMassToDo: function (component, event, helper) {
        var listOfToDoItems = component.get('v.listOfToDoItems');
        var listOfToDoItemsClone = component.get('v.listOfToDoItems');
        var action = component.get("c.updateToDoItems");
        console.log('listOfToDoItems before==>');
        console.log({ listOfToDoItemsClone });
        console.log({ listOfToDoItems });
        for (var i in listOfToDoItems) {
            var obj = listOfToDoItems[i];
            if (obj.buildertek__Due_Date__c != undefined && obj.buildertek__Due_Date__c == '') {
                delete obj['buildertek__Due_Date__c'];
            }
            if (obj.buildertek__Date_Completed__c != undefined && obj.buildertek__Date_Completed__c == '') {
                delete obj['buildertek__Date_Completed__c'];
            }
            if (obj.Id == undefined) {
                obj.buildertek__To_Do__c = component.get('v.recordId');
            }
            if (obj.buildertek__Assigned_To__c != undefined && obj.buildertek__Assigned_To__c != '' && obj.buildertek__Assigned_To__c != null) {
                // console.log('buildertek__Assigned_To__c ==>' + JSON.parse(JSON.stringify(obj.buildertek__Assigned_To__c)));
                if (obj.buildertek__Assigned_To__c[0] != 0) {
                    obj.buildertek__Assigned_To__c = obj.buildertek__Assigned_To__c[0];
                }

            }
            if (obj.buildertek__Assigned_Vendor__c != undefined && obj.buildertek__Assigned_Vendor__c != '' && obj.buildertek__Assigned_Vendor__c != null) {
                // console.log('buildertek__Assigned_Vendor__c ==>' + JSON.parse(JSON.stringify(obj.buildertek__Assigned_Vendor__c)));
                if (obj.buildertek__Assigned_Vendor__c[0] != 0) {
                    obj.buildertek__Assigned_Vendor__c = obj.buildertek__Assigned_Vendor__c[0];
                }
            }
            delete obj['attributes'];
            delete obj['buildertek__Assigned_To__r'];
            delete obj['buildertek__Assigned_Vendor__r'];
        }
        console.log('listOfToDoItems after ==>');
        console.log({ listOfToDoItems });
        action.setParams({
            recordId: component.get('v.recordId'),
            updatedToDoItems: JSON.stringify(listOfToDoItems),
            fieldSetName: JSON.stringify(component.get('v.arrfieldNames'))
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var list = JSON.parse(response.getReturnValue());
                component.set('v.listOfToDoItems', list);
                component.set('v.numberOfItems', list.length);
                component.set('v.cloneListOfToDoItems', list);
                component.set('v.isLoading', false);
            } else if (state === "ERROR") {
                component.set('v.isLoading', false);
                console.log('A Problem Occurred: ' + JSON.stringify(response.error));
            }
        });
        $A.enqueueAction(action);
    },
})