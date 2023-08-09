({
    retrieveTakeOffLines: function (component, event, helper, pageNumber, pageSize, tradeType, category, productType) {
        component.set('v.isLoading', true);
        var action = component.get("c.getTakeOffLines");
        action.setParams({
            pageNumber: pageNumber,
            pageSize: pageSize,
            tradeType: tradeType,
            category: category,
            productType: productType
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                for (var i in result.records) {
                    result.records[i].isSelected = false;
                }
                component.set('v.listOfRecords', groupRecords(result.records));
                component.set("v.pageNumber", pageNumber);
                component.set("v.recordStart", (pageNumber - 1) * pageSize + 1);
                component.set("v.recordEnd", (result.records.length + 3) * pageNumber);
                component.set('v.totalRecords', result.totalRecords);
                component.set("v.totalPages", Math.ceil(result.records.length / result.totalRecords));
                if (result.totalRecords < pageNumber * pageSize) {
                    component.set("v.isNextDisabled", true);
                } else {
                    component.set("v.isNextDisabled", false);
                }

                function groupRecords(data) {
                    var listOfRecords = [];
                    let recordMap = new Map();
                    for (var i in data) {
                        //Created Key with (#*&)
                        if (data[i].buildertek__Trade_Type__c != undefined) {
                            if (!recordMap.has(data[i].buildertek__Trade_Type__c + '(#*&)' + data[i].buildertek__Trade_Type__r.Name)) {
                                recordMap.set(data[i].buildertek__Trade_Type__c + '(#*&)' + data[i].buildertek__Trade_Type__r.Name, []);
                            }
                            recordMap.get(data[i].buildertek__Trade_Type__c + '(#*&)' + data[i].buildertek__Trade_Type__r.Name).push(data[i]);
                        } else {
                            if (!recordMap.has('No Grouping' + '(#*&)' + 'No Grouping')) {
                                recordMap.set('No Grouping' + '(#*&)' + 'No Grouping', []);
                            }
                            recordMap.get('No Grouping' + '(#*&)' + 'No Grouping').push(data[i]);
                        }
                    }
                    var result = Array.from(recordMap.entries());
                    for (var i in result) {
                        var obj = {};
                        obj.groupId = result[i][0].split('(#*&)')[0];
                        obj.groupName = result[i][0].split('(#*&)')[1];
                        obj.groupedRecords = result[i][1];
                        for (var j in obj.groupedRecords) {
                            obj.groupedRecords[j].isSelected = false;
                        }
                        listOfRecords.push(obj);
                    }
                    return listOfRecords;
                }
                component.set('v.isLoading', false);
            }
        });
        $A.enqueueAction(action);
    },

    importTakeOffLineRecords: function (component, event, helper, importTakeOffLineRecords) {
        component.set('v.isLoading', true);
        debugger;
        var action = component.get("c.importRecords");
        action.setParams({
            importTakeOffLineRecords: (importTakeOffLineRecords),
            recordId: component.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.isLoading', false);
                $A.get("e.force:closeQuickAction").fire();
                helper.showToast(component, event, helper, 'Success!', 'Selection Sheet Takeoff Lines Created Successfully!', 'success');
            } else {
                helper.showToast(component, event, helper, 'Error!', 'Something went wrong!', 'error');
            }
        });
        $A.enqueueAction(action);
    },

    showToast: function (component, event, helper, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            mode: 'sticky',
            message: message,
            type: type
        });
        toastEvent.fire();
    }
})