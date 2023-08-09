({
    getRecords: function (component, event, helper, start) {
        var pageNumber = component.get('v.PageNumber');
        var pageSize = component.get('v.pageSize');
        var action = component.get("c.getQuoteItems");
        action.setParams({
            recordId: component.get("v.recordId"),
            pageNumber: pageNumber,
            pageSize: pageSize
        });
        action.setCallback(this, function (response) {
            component.set('v.isLoading', true);
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('Result::', result);
                var data = result.records;
                var formulaFields = result.formulaFields;
                var fieldSetValue = JSON.parse(JSON.stringify(JSON.parse(result.fieldSet)));
                component.set('v.formulaFields', formulaFields);
                component.set('v.fieldSet', fieldSetValue);
                component.set("v.fieldSetCount", fieldSetValue.length / 2);
                component.set('v.listOfRecords', groupRecords(data, fieldSetValue));
                component.set('v.listOfRecordsClone', data);
                component.set("v.PageNumber", pageNumber);
                component.set("v.RecordStart", (pageNumber - 1) * pageSize + 1);
                //component.set("v.RecordEnd", (scheduleItemsListClone.length + 3) * pageNumber);
                //component.set("v.TotalPages", Math.ceil(scheduleItemsListClone.length / component.get('v.TotalRecords')));
                component.set('v.isLoading', false);

                if (component.get('v.TotalRecords') < pageNumber * pageSize) {
                    component.set("v.isNextDisabled", true);
                } else {
                    component.set("v.isNextDisabled", false);
                }

                //Create Parent-Child Hierarchy.
                function groupRecords(data, fieldSetValue) {
                    var listOfRecords = [];
                    let recordMap = new Map();
                    for (var i in data) {
                        //Created Key with (#*&)
                        if (!recordMap.has(data[i].buildertek__Grouping__c + '(#*&)' + data[i].buildertek__Grouping__r.Name)) {
                            recordMap.set(data[i].buildertek__Grouping__c + '(#*&)' + data[i].buildertek__Grouping__r.Name, []);
                        }
                        recordMap.get(data[i].buildertek__Grouping__c + '(#*&)' + data[i].buildertek__Grouping__r.Name).push(data[i]);
                    }
                    var result = Array.from(recordMap.entries());
                    for (var i in result) {
                        var obj = {};
                        var recordValue = [];
                        obj.groupId = result[i][0].split('(#*&)')[0];
                        obj.groupName = result[i][0].split('(#*&)')[1];
                        obj.groupedRecords = result[i][1];
                        obj.footerRecords = [];
                        var sum = 0;
                        for (var k in fieldSetValue) {
                            sum = 0;
                            if (fieldSetValue[k].type == 'DOUBLE' || fieldSetValue[k].type == 'NUMBER' || fieldSetValue[k].type == 'CURRENCY') {
                                for (var j in obj.groupedRecords) {
                                    sum += obj.groupedRecords[j][fieldSetValue[k].name] != undefined ? obj.groupedRecords[j][fieldSetValue[k].name] : 0;
                                }
                                obj.footerRecords.push(sum);
                            } else {
                                obj.footerRecords.push('""');
                            }
                        }
                        listOfRecords.push(obj);
                    }
                    return listOfRecords;
                }
                console.log('Result::', groupRecords(data));
                component.set('v.isLoading', false);
                var end = new Date().getTime();
                console.log(end - start);
            }
        });
        $A.enqueueAction(action);
    },

    updateQuoteItems: function (component, event, helper, records, start) {
        var pageNumber = component.get('v.PageNumber');
        var pageSize = component.get('v.pageSize');
        var action = component.get("c.updateRecords");
        action.setParams({
            recordId: component.get("v.recordId"),
            records: JSON.stringify(records),
            pageNumber: pageNumber,
            pageSize: pageSize
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var data = result.records;
                var fieldSetValue = JSON.parse(JSON.stringify(JSON.parse(result.fieldSet)));
                component.set('v.fieldSet', fieldSetValue);
                component.set("v.fieldSetCount", fieldSetValue.length / 2);
                component.set('v.listOfRecords', groupRecords(data));
                component.set("v.PageNumber", pageNumber);
                component.set("v.RecordStart", (pageNumber - 1) * pageSize + 1);
                component.set('v.isLoading', false);

                if (component.get('v.TotalRecords') < pageNumber * pageSize) {
                    component.set("v.isNextDisabled", true);
                } else {
                    component.set("v.isNextDisabled", false);
                }
                //Create Parent-Child Hierarchy.
                function groupRecords(data) {
                    var listOfRecords = [];
                    let recordMap = new Map();
                    for (var i in data) {
                        //Created Key with (#*&)
                        if (!recordMap.has(data[i].buildertek__Grouping__c + '(#*&)' + data[i].buildertek__Grouping__r.Name)) {
                            recordMap.set(data[i].buildertek__Grouping__c + '(#*&)' + data[i].buildertek__Grouping__r.Name, []);
                        }
                        recordMap.get(data[i].buildertek__Grouping__c + '(#*&)' + data[i].buildertek__Grouping__r.Name).push(data[i]);
                    }
                    var result = Array.from(recordMap.entries());
                    for (var i in result) {
                        var obj = {};
                        obj.groupId = result[i][0].split('(#*&)')[0];
                        obj.groupName = result[i][0].split('(#*&)')[1];
                        obj.groupedRecords = result[i][1];
                        listOfRecords.push(obj);
                    }
                    return listOfRecords;
                }
                var end = new Date().getTime();
                console.log(end - start);
            }
        });
        $A.enqueueAction(action);
    }
})