({
    getRecords: function (component, event, helper, pageNumber, pageSize, packageLinesSearchTradeType, packageLinesSearchCategory, packageLinesSearchProductType, tradeType, category, productType) {
        var action = component.get("c.getPackageTakeoffRecords");
        debugger;
        var addedTakeOffLinesList = component.get('v.addedTakeOffLinesList');
        action.setParams({
            takeOffLinesIds: component.get('v.takeOffLinesIds'),
            recordId: component.get('v.recordId'),
            pageNumber: pageNumber,
            pageSize: pageSize,
            packageLinesSearchTradeType: packageLinesSearchTradeType,
            packageLinesSearchCategory: packageLinesSearchCategory,
            packageLinesSearchProductType: packageLinesSearchProductType,
            searchTradeType: tradeType,
            searchCategory: category,
            searchProductType: productType
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result != null) {
                    component.set('v.packageLinesList', helper.groupRecords(result.packageLinesRecord, new Set()));
                    component.set('v.takeOffLinesList', helper.groupRecords(result.takeOffLinesList, addedTakeOffLinesList));
                    component.set('v.projectTakeOffRec', result.projectTakeOffRec);
                    if (result.takeOffLinesList != undefined) {
                        component.set("v.pageNumber", pageNumber);
                        component.set("v.recordStart", (pageNumber - 1) * pageSize + 1);
                        component.set("v.recordEnd", (result.takeOffLinesList.length + 3) * pageNumber);
                        component.set('v.totalRecords', result.totalRecords);
                        component.set("v.totalPages", Math.ceil(result.takeOffLinesList.length / result.totalRecords));
                        if (result.totalRecords < pageNumber * pageSize) {
                            component.set("v.isNextDisabled", true);
                        } else {
                            component.set("v.isNextDisabled", false);
                        }
                    }
                }
                component.set("v.isSpinner", false);
            } else {
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
    },

    getFilteredTakeOffLines: function (component, event, helper, pageNumber, pageSize, packageLinesSearchTradeType, packageLinesSearchCategory, packageLinesSearchProductType, tradeType, category, productType, filteredTakeOffLines) {
        component.set("v.isSpinner", true);
        var addedTakeOffLinesList = component.get('v.addedTakeOffLinesList');
        var action = component.get("c.getFilteredTakeoffRecords");
        action.setParams({
            takeOffLinesIds: component.get('v.takeOffLinesIds'),
            recordId: component.get('v.recordId'),
            pageNumber: pageNumber,
            pageSize: pageSize,
            packageLinesSearchTradeType: packageLinesSearchTradeType,
            packageLinesSearchCategory: packageLinesSearchCategory,
            packageLinesSearchProductType: packageLinesSearchProductType,
            searchTradeType: tradeType,
            searchCategory: category,
            searchProductType: productType,
            filteredTakeOffLines: JSON.stringify(filteredTakeOffLines)
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result != null) {
                    if (result.insertedTakeOffLines != undefined) {
                        addedTakeOffLinesList = addedTakeOffLinesList.length == 0 ? new Set() : addedTakeOffLinesList;
                        addedTakeOffLinesList = helper.unionLines(component, addedTakeOffLinesList, result.insertedTakeOffLines);
                    }
                    component.set('v.takeOffLinesList', helper.groupRecords(result.takeOffLinesList, addedTakeOffLinesList));
                    component.set('v.projectTakeOffRec', result.projectTakeOffRec);
                    component.set("v.pageNumber", pageNumber);
                    component.set("v.recordStart", (pageNumber - 1) * pageSize + 1);
                    component.set("v.recordEnd", (result.takeOffLinesList.length + 3) * pageNumber);
                    component.set('v.totalRecords', result.totalRecords);
                    component.set("v.totalPages", Math.ceil(result.takeOffLinesList.length / result.totalRecords));
                    if (result.totalRecords < pageNumber * pageSize) {
                        component.set("v.isNextDisabled", true);
                    } else {
                        component.set("v.isNextDisabled", false);
                    }
                }
                component.set("v.isSpinner", false);
            } else {
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
    },

    addGroupedLines: function (component, event, helper, pageNumber, pageSize, packageLinesSearchTradeType, packageLinesSearchCategory, packageLinesSearchProductType, tradeType, category, productType, listOfIdsToInsert, groupName) {
        var action = component.get('c.addGroupedLinesRecords');
        var addedTakeOffLinesList = component.get('v.addedTakeOffLinesList');
        action.setParams({
            takeOffLinesIds: component.get('v.takeOffLinesIds'),
            recordId: component.get('v.recordId'),
            pageNumber: pageNumber,
            pageSize: pageSize,
            packageLinesSearchTradeType: packageLinesSearchTradeType,
            packageLinesSearchCategory: packageLinesSearchCategory,
            packageLinesSearchProductType: packageLinesSearchProductType,
            searchTradeType: tradeType,
            searchCategory: category,
            searchProductType: productType,
            listOfIdsToInsert: listOfIdsToInsert
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == 'SUCCESS' && response.getReturnValue()) {
                var result = response.getReturnValue();
                if (result != null) {
                    if (result.insertedTakeOffLines != undefined) {
                        addedTakeOffLinesList = addedTakeOffLinesList.length == 0 ? new Set() : addedTakeOffLinesList;
                        addedTakeOffLinesList = helper.unionLines(component, addedTakeOffLinesList, result.insertedTakeOffLines);
                    }
                    component.set('v.packageLinesList', helper.groupRecords(result.packageLinesRecord, new Set()));
                    component.set('v.takeOffLinesList', helper.groupRecords(result.takeOffLinesList, addedTakeOffLinesList));
                    component.set('v.projectTakeOffRec', result.projectTakeOffRec);
                    component.set("v.pageNumber", pageNumber);
                    component.set("v.recordStart", (pageNumber - 1) * pageSize + 1);
                    component.set("v.recordEnd", (result.takeOffLinesList.length + 3) * pageNumber);
                    component.set('v.totalRecords', result.totalRecords);
                    component.set("v.totalPages", Math.ceil(result.takeOffLinesList.length / result.totalRecords));
                    if (result.totalRecords < pageNumber * pageSize) {
                        component.set("v.isNextDisabled", true);
                    } else {
                        component.set("v.isNextDisabled", false);
                    }
                }
                component.set("v.isSpinner", false);
            } else {
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
    },

    addIndividualTakeOffLine: function (component, event, helper, pageNumber, pageSize, packageLinesSearchTradeType, packageLinesSearchCategory, packageLinesSearchProductType, tradeType, category, productType, packageLineId) {
        var action = component.get('c.addIndividualTakeOffLinesRecords');
        var addedTakeOffLinesList = component.get('v.addedTakeOffLinesList');
        action.setParams({
            takeOffLinesIds: component.get('v.takeOffLinesIds'),
            recordId: component.get('v.recordId'),
            pageNumber: pageNumber,
            pageSize: pageSize,
            packageLinesSearchTradeType: packageLinesSearchTradeType,
            packageLinesSearchCategory: packageLinesSearchCategory,
            packageLinesSearchProductType: packageLinesSearchProductType,
            searchTradeType: tradeType,
            searchCategory: category,
            searchProductType: productType,
            packageLineId: packageLineId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == 'SUCCESS' && response.getReturnValue()) {
                var result = response.getReturnValue();
                if (result != null) {
                    debugger;
                    if (result.insertedTakeOffLines != undefined) {
                        addedTakeOffLinesList = addedTakeOffLinesList.length == 0 ? new Set() : addedTakeOffLinesList;
                        addedTakeOffLinesList = helper.unionLines(component, addedTakeOffLinesList, result.insertedTakeOffLines);
                    }
                    component.set('v.packageLinesList', helper.groupRecords(result.packageLinesRecord, new Set()));
                    component.set('v.takeOffLinesList', helper.groupRecords(result.takeOffLinesList, addedTakeOffLinesList));
                    component.set('v.projectTakeOffRec', result.projectTakeOffRec);
                    component.set("v.pageNumber", pageNumber);
                    component.set("v.recordStart", (pageNumber - 1) * pageSize + 1);
                    component.set("v.recordEnd", (result.takeOffLinesList.length + 3) * pageNumber);
                    component.set('v.totalRecords', result.totalRecords);
                    component.set("v.totalPages", Math.ceil(result.takeOffLinesList.length / result.totalRecords));
                    if (result.totalRecords < pageNumber * pageSize) {
                        component.set("v.isNextDisabled", true);
                    } else {
                        component.set("v.isNextDisabled", false);
                    }
                }
                component.set("v.isSpinner", false);
            } else {
                component.set("v.isSpinner", false);
                helper.showToast(component, event, helper, 'Error!', 'Something went wrong!', 'error');
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
    },
    deleteTakeOffLine: function (component, event, helper, pageNumber, pageSize, packageLinesSearchTradeType, packageLinesSearchCategory, packageLinesSearchProductType, tradeType, category, productType) {
        var action = component.get('c.deleteTakeOffLinesRecords');
        var addedTakeOffLinesList = component.get('v.addedTakeOffLinesList');
        action.setParams({
            takeOffLinesIds: component.get('v.takeOffLinesIds'),
            recordId: component.get('v.recordId'),
            pageNumber: pageNumber,
            pageSize: pageSize,
            packageLinesSearchTradeType: packageLinesSearchTradeType,
            packageLinesSearchCategory: packageLinesSearchCategory,
            packageLinesSearchProductType: packageLinesSearchProductType,
            searchTradeType: tradeType,
            searchCategory: category,
            searchProductType: productType,
            takeOffLinesToDeleteList: component.get('v.takeOffLinesToDeleteList')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == 'SUCCESS' && response.getReturnValue()) {
                var result = response.getReturnValue();
                if (result != null) {
                    addedTakeOffLinesList = addedTakeOffLinesList.length == 0 ? new Set() : addedTakeOffLinesList;
                    component.set('v.packageLinesList', helper.groupRecords(result.packageLinesRecord, new Set()));
                    component.set('v.takeOffLinesList', helper.groupRecords(result.takeOffLinesList, addedTakeOffLinesList));
                    component.set('v.projectTakeOffRec', result.projectTakeOffRec);
                    component.set("v.pageNumber", pageNumber);
                    component.set("v.recordStart", (pageNumber - 1) * pageSize + 1);
                    component.set("v.recordEnd", (result.takeOffLinesList.length + 3) * pageNumber);
                    component.set('v.totalRecords', result.totalRecords);
                    component.set("v.totalPages", Math.ceil(result.takeOffLinesList.length / result.totalRecords));
                    if (result.totalRecords < pageNumber * pageSize) {
                        component.set("v.isNextDisabled", true);
                    } else {
                        component.set("v.isNextDisabled", false);
                    }
                }
                component.set("v.isSpinner", false);
            } else {
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
    },

    updateTakeOffLines: function (component, event, helper) {
        component.set("v.isSpinner", true);
        var action = component.get("c.replaceTakeOffLinesRecords2");
        action.setParams({
            takeOffLinesIdsToDelete: component.get('v.takeOffLinesToDelete'),
            takeOffLinesIds: component.get('v.packageLinesToAdd'),
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result.Status === 'Success') {
                    helper.showToast(component, event, helper, 'Success!', result.Message, 'success');
                    //helper.closeTab(component, event, helper);
                    helper.getRecords(component, event, helper, component.get('v.pageNumber'), component.get('v.pageSize'), '', '', '', '', '', '');
                    component.set("v.isSpinner", false);
                } else {
                    component.set("v.isSpinner", false);
                    //helper.showToast(component, event, helper, 'Error!', result.Message, 'error');
                }
            }
        });
        $A.enqueueAction(action);
    },

    importPackage: function (component, event, helper) {
        component.set("v.isSpinner", true);
        var pageNumber = component.get("v.pageNumber");
        var pageSize = component.get("v.pageSize");
        var addedTakeOffLinesList = component.get('v.addedTakeOffLinesList');
        var action = component.get("c.importPackageLinesRecords");
        action.setParams({
            takeOffLinesIds: component.get('v.takeOffLinesIds'),
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result != null) {
                    if (result.insertedTakeOffLines != undefined) {
                        addedTakeOffLinesList = addedTakeOffLinesList.length == 0 ? new Set() : addedTakeOffLinesList;
                        addedTakeOffLinesList = helper.unionLines(component, addedTakeOffLinesList, result.insertedTakeOffLines);
                    }
                    component.set('v.packageLinesList', helper.groupRecords(result.packageLinesRecord, new Set()));
                    component.set('v.takeOffLinesList', helper.groupRecords(result.takeOffLinesList, addedTakeOffLinesList));
                    component.set('v.projectTakeOffRec', result.projectTakeOffRec);
                    if (result.takeOffLinesList != undefined) {
                        component.set("v.pageNumber", pageNumber);
                        component.set("v.recordStart", (pageNumber - 1) * pageSize + 1);
                        component.set("v.recordEnd", (result.takeOffLinesList.length + 3) * pageNumber);
                        component.set('v.totalRecords', result.totalRecords);
                        component.set("v.totalPages", Math.ceil(result.takeOffLinesList.length / result.totalRecords));
                        if (result.totalRecords < pageNumber * pageSize) {
                            component.set("v.isNextDisabled", true);
                        } else {
                            component.set("v.isNextDisabled", false);
                        }
                    }
                }
                component.set("v.isSpinner", false);
                helper.showToast(component, event, helper, 'Success!', result.Message, 'success');
            } else {
                helper.showToast(component, event, helper, 'Warning!', result.Message, 'warning');
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
    },

    replaceTakeOffLines: function (component, event, helper, takeOffListIdsToDelete) {
        component.set("v.isSpinner", true);
        console.log('takeOffListIdsToDelete::', takeOffListIdsToDelete);
        var action = component.get("c.replaceTakeOffLinesRecords");
        action.setParams({
            takeOffLinesIdsToDelete: takeOffListIdsToDelete,
            takeOffLinesIds: component.get('v.takeOffLinesIds'),
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result.Status === 'Success') {
                    component.set("v.isSpinner", false);
                    helper.showToast(component, event, helper, 'Success!', result.Message, 'success');
                    helper.closeTab(component, event, helper);
                } else {
                    component.set("v.isSpinner", false);
                    helper.showToast(component, event, helper, 'Error!', result.Message, 'error');
                }
            }
        });
        $A.enqueueAction(action);
    },

    showToast: function (component, event, helper, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            mode: 'dismissible',
            message: message,
            type: type,
            duration: 5
        });
        toastEvent.fire();
    },

    closeTab: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({
                tabId: focusedTabId
            });
        }).catch(function (error) {
            console.log(error);
        });
    },

    groupRecords: function (data, addedTakeOffLinesList) {
        addedTakeOffLinesList = addedTakeOffLinesList.length == 0 ? new Set() : addedTakeOffLinesList;
        var listOfRecords = [];
        let recordMap = new Map();
        for (var i in data) {
            //Created Key with (#*&)
            if (data[i].buildertek__Trade_Type__c != undefined) {
                if (!recordMap.has(data[i].buildertek__Trade_Type__c + '(#*&)' + data[i].buildertek__Trade_Type__r.Name)) {
                    recordMap.set(data[i].buildertek__Trade_Type__c + '(#*&)' + data[i].buildertek__Trade_Type__r.Name, []);
                }
                recordMap.get(data[i].buildertek__Trade_Type__c + '(#*&)' + data[i].buildertek__Trade_Type__r.Name).push(data[i]);
            }
        }
        var result = Array.from(recordMap.entries());
        for (var i in result) {
            var obj = {};
            obj.groupId = result[i][0].split('(#*&)')[0];
            obj.groupName = result[i][0].split('(#*&)')[1];
            obj.isSelected = false;
            obj.isAllSelected = false;
            obj.groupedRecords = result[i][1];
            for (var j in obj.groupedRecords) {
                if (addedTakeOffLinesList.has(obj.groupedRecords[j].Id)) {
                    obj.groupedRecords[j].isAdded = true;
                }
                obj.groupedRecords[j].isSelected = false;
            }
            listOfRecords.push(obj);
        }
        return listOfRecords;
    },

    unionLines: function (component, addedTakeOffLinesList, data) {
        let setValues = new Set();

        function union(sets) {
            return sets.reduce((combined, list) => {
                return new Set([...combined, ...list]);
            }, new Set());
        }
        setValues = union([addedTakeOffLinesList, data]);
        component.set('v.addedTakeOffLinesList', setValues);
        return setValues;
    }
})