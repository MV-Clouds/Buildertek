({
    getTableFieldSet: function (component, event, helper) {
        debugger;
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        var action = component.get("c.getFieldSet");
        action.setCallback(this, function (response) {
            var fieldSetObj = JSON.parse(response.getReturnValue());
            component.set("v.fieldSetValues", fieldSetObj);
            
        })
        $A.enqueueAction(action);
        var action1 = component.get("c.getSOVName");
        action1.setParams({
            "recordId": component.get("v.recordId"),
        });
        action1.setCallback(this, function (response) {
            component.set("v.SovName", response.getReturnValue())
            
        })
        $A.enqueueAction(action1);
        
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
            debugger;
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                var list = JSON.parse(response.getReturnValue());
                if (list.length > 0) {
                    component.set("v.listOfRecords", list);
                    console.log(list)
                    
                    
                    component.set("v.cloneListOfRecords", list);
                    component.set('v.numberOfItems', list.length);
                    component.set("v.PageNumber", pageNumber);
                    component.set("v.RecordStart", (pageNumber - 1) * pageSize + 1);
                    component.set("v.RecordEnd", (list.length + 3) * pageNumber);
                    component.set("v.TotalPages", Math.ceil(list.length / component.get('v.TotalRecords')));
                    component.set('v.isLoading', false);
                    
                    if (component.get('v.TotalRecords') <= pageNumber * pageSize) {
                        component.set("v.isNextDisabled", true);
                        console.log('isNextDisabled:::', component.get("v.isNextDisabled"));
                    } else {
                        component.set("v.isNextDisabled", false);
                    }
                } else {
                    component.set('v.isLoading', false);
                    component.set("v.isNextDisabled", true);
                }
            } else {
                component.set("v.cloneListOfRecords", []);
            }
        })
        $A.enqueueAction(action);
    },
    
    getTotalRecord: function (component, event, helper) {
        debugger;
        var action = component.get("c.getCount");
        action.setParams({
            recordId: component.get('v.recordId'),
        });
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                component.set("v.TotalRecords", response.getReturnValue());
                helper.getTableRows(component, event, helper, component.get("v.PageNumber"),  component.get("v.pageSize"));
            }
        })
        $A.enqueueAction(action);
    },
    
    updateMassRecords: function (component, event, helper) {
        component.set("v.Spinner", true);
        component.set("v.showMessage", true);
        debugger;
        component.set('v.isLoading', true);
        var listOfRecords = component.get('v.listOfRecords');
        var action = component.get("c.updateRecords");
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        var fieldSetValues = component.get('v.fieldSetValues');
        for (var i in listOfRecords) {
            var record = listOfRecords[i];
            if (record != undefined) {
                for (var j in fieldSetValues) {
                    if (record.buildertek__Schedule_of_Values__c === undefined || record.buildertek__Schedule_of_Values__c === '') {
                        record.buildertek__Schedule_of_Values__c = component.get('v.recordId');
                   
                        
                    } else if (record[fieldSetValues[j].name] === '' || record[fieldSetValues[j].name] === undefined) {
                        record[fieldSetValues[j].name] = null;
                        record[fieldSetValues[j].name] = fieldSetValues[j].name.includes('__r') ? null : record[fieldSetValues[j].name];
                        
                    }
                }
            } else {
                listOfRecords.splice(i, 1);
                i--;
            }
        }
        console.log('Records To Update::', JSON.stringify(listOfRecords));
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
            updatedRecords: JSON.stringify(listOfRecords),
            fieldSetName: JSON.stringify(component.get('v.arrfieldNames')),
            pageNumber: pageNumber,
            pageSize: pageSize
        });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.Spinner", false);
                component.set("v.showMessage", false);
                var list = JSON.parse(response.getReturnValue());
                component.set('v.listOfRecords', list);
                component.set('v.numberOfItems', list.length);
                component.set('v.cloneListOfRecords', list);
                component.set('v.isLoading', false);
                component.set("v.PageNumber", pageNumber);
                component.set("v.RecordStart", (pageNumber - 1) * pageSize + 1);
                component.set("v.RecordEnd", (list.length + 1) * pageNumber);
                component.set("v.TotalPages", Math.ceil(list.length / component.get('v.TotalRecords')));
                component.set('v.massUpdateEnable', false);
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : "Success",
                    message : 'SOV Lines are Updated Successfully',
                    type: 'Success',
                    duration: '1000',
                    key: 'info_alt',
                    mode: 'pester'
                });
                toastEvent.fire(); 
                
                //$A.get('e.force:refreshView').fire();
                
            } else if (state === "ERROR") {
                component.set("v.Spinner", false);
                component.set("v.showMessage", false);
                var errorMessage = response.getError();
                var message = 'Something went wrong!';
                if (errorMessage[0].message != undefined && errorMessage[0].message.includes('Start Date') && errorMessage[0].message.includes('REQUIRED_FIELD_MISSING')) {
                    message = 'Required field missing, Start Date!';
                } else if (errorMessage[0].message != undefined && errorMessage[0].message.includes('Finish Date cannot be less than Start Date')) {
                    message = 'Finish Date cannot be less than Start Date!';
                }else  if (errorMessage[0].message != undefined && errorMessage[0].message.includes('REQUIRED_FIELD_MISSING') && errorMessage[0].message.includes('Description of Work')) {
                    message = 'Description of Work is Required!';
                } 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'sticky',
                    message: message,
                    type: 'error',
                    duration: '10000',
                    mode: 'dismissible'
                });
                toastEvent.fire();
                component.set('v.isLoading', false);
                console.log('A Problem Occurred: ' + response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    massDeleteRecord: function (component, event, helper, recordIdsToDelete) {
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        
        var action = component.get("c.massDeleteProjectTask");
        action.setParams({
            deleteRecordId: recordIdsToDelete,
            recordId: component.get('v.recordId'),
            fieldSetName: JSON.stringify(component.get('v.arrfieldNames')),
            pageNumber: pageNumber,
            pageSize: pageSize
            
        });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS" && response.getReturnValue()) {
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