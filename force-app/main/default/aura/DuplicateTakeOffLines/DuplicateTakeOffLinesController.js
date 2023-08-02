({
    doInit: function (component, event, helper) {
        component.set("v.isSpinner", true);
        setTimeout(function () {
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function (response) {
                var focusedTabId = response.tabId;
                workspaceAPI.setTabLabel({
                    tabId: focusedTabId,
                    label: "Duplicate TakeOff Lines"
                });
                workspaceAPI.setTabIcon({
                    tabId: focusedTabId,
                    icon: "custom:custom70"
                });
            }).catch(function (error) {
                console.log('sub tab error::', error);
            });
        }, 100);

        var pageSize = component.get("v.pageSize");
        helper.getRecords(component, event, helper, 1, pageSize, '', '', '', '', '', '');
    },

    onGroupCheckBoxChange: function (component, event, helper) {
        var pageSize = component.get("v.pageSize");
        var packageLinesList = component.get('v.packageLinesList');
        var groupIndex = event.getSource().get("v.name");
        var packageLinesSearchTradeType = component.find('packageLinesTradeType').get('v.value');
        var packageLinesSearchCategory = component.find('packageLinesCategory').get('v.value');
        var packageLinesSearchProductType = component.find('packageLinesProductType').get('v.value');
        // TakeOff Lines Search
        var tradeType = component.find('tradeType').get('v.value');
        var category = component.find('category').get('v.value');
        var productType = component.find('productType').get('v.value');
        var filteredTakeOffLines = [];

        for (var i in packageLinesList[groupIndex].groupedRecords) {
            packageLinesList[groupIndex].groupedRecords[i].isSelected = packageLinesList[groupIndex].isSelected;
        }
        //Check UnCheck All
        for (var i in packageLinesList) {
            for (var j in packageLinesList[i].groupedRecords) {
                if (packageLinesList[i].groupedRecords[j].isSelected) {
                    var obj = {};
                    obj.buildertek__Trade_Type__c = packageLinesList[i].groupedRecords[j].buildertek__Trade_Type__c != undefined ? packageLinesList[i].groupedRecords[j].buildertek__Trade_Type__c : null;
                    obj.buildertek__Product_Type__c = packageLinesList[i].groupedRecords[j].buildertek__Product_Type__c != undefined ? packageLinesList[i].groupedRecords[j].buildertek__Product_Type__c : null;
                    obj.buildertek__Category__c = packageLinesList[i].groupedRecords[j].buildertek__Category__c != undefined ? packageLinesList[i].groupedRecords[j].buildertek__Category__c : null;
                    obj.buildertek__Location__c = packageLinesList[i].groupedRecords[j].buildertek__Location__c != undefined ? packageLinesList[i].groupedRecords[j].buildertek__Location__c : null;
                    filteredTakeOffLines.push(obj);
                }
            }
        }
        component.set('v.takeOffLinesList', []);
        component.set('v.packageLinesList', packageLinesList);
        //Filter records
        helper.getFilteredTakeOffLines(component, event, helper, 1, pageSize, packageLinesSearchTradeType, packageLinesSearchCategory, packageLinesSearchProductType, tradeType, category, productType, filteredTakeOffLines);
    },

    onTakeOffGroupCheckBoxChange: function (component, event, helper) {
        var takeOffLinesList = component.get('v.takeOffLinesList');
        var groupIndex = event.getSource().get("v.name");
        for (var i in takeOffLinesList[groupIndex].groupedRecords) {
            takeOffLinesList[groupIndex].groupedRecords[i].isSelected = takeOffLinesList[groupIndex].isSelected;
        }
        component.set('v.takeOffLinesList', takeOffLinesList);
    },

    onCheckBoxChange: function (component, event, helper) {
        var packageLinesList = component.get('v.packageLinesList');
        var groupIndex = event.getSource().get("v.name").split('-')[0];
        var selectedRecordCount = 0;

        //Check UnCheck All
        for (var j in packageLinesList[groupIndex].groupedRecords) {
            packageLinesList[groupIndex].groupedRecords[j].isSelected ?
                selectedRecordCount++ : '';
        }
        packageLinesList[groupIndex].isSelected = selectedRecordCount == packageLinesList[groupIndex].groupedRecords.length ? true : false;
        component.set('v.packageLinesList', packageLinesList);
    },

    onTakeOffCheckBoxChange: function (component, event, helper) {
        var takeOffLinesList = component.get('v.takeOffLinesList');
        var groupIndex = event.getSource().get("v.name").split('-')[0];
        var selectedRecordCount = 0;

        //Check UnCheck All
        for (var j in takeOffLinesList[groupIndex].groupedRecords) {
            takeOffLinesList[groupIndex].groupedRecords[j].isSelected ?
                selectedRecordCount++ : '';
        }
        takeOffLinesList[groupIndex].isSelected = selectedRecordCount == takeOffLinesList[groupIndex].groupedRecords.length ? true : false;
        component.set('v.takeOffLinesList', takeOffLinesList);
    },

    createTakeOffLines: function (component, event, helper) {
        component.get('v.takeOffLinesIds').length > 0 ?
            helper.importPackage(component, event, helper) :
            helper.showToast(component, event, helper, 'Warning!', 'Something went wrong!', 'warning');
    },

    onClickOpenDeleteModal: function (component, event, helper) {
        component.set('v.deleteConfirmationBody', 'Are you sure you want Delete takeOff Lines?');
        component.set('v.isDeleteModal', !component.get('v.isDeleteModal'));
        if (component.get('v.isDeleteModal')) {
            var takeOffLinesList = component.get('v.takeOffLinesList');
            var groupIndex = event.getSource().get("v.alternativeText").split('-')[0];
            var index = event.getSource().get("v.alternativeText").split('-')[1];
            var selectedTakeOffLines = [];
            selectedTakeOffLines.push(takeOffLinesList[groupIndex].groupedRecords[index].Id);
            component.set('v.takeOffLinesToDeleteList', selectedTakeOffLines);
        }
    },

    onClickAddPackageLine: function (component, event, helper) {
        component.set("v.isSpinner", true);
        var packageLinesList = component.get('v.packageLinesList');
        var groupIndex = event.getSource().get("v.alternativeText").split('-')[0];
        var index = event.getSource().get("v.alternativeText").split('-')[1];
        var pageNumber = component.get("v.pageNumber");
        var pageSize = component.get("v.pageSize");
        //Package Lines
        var packageLinesSearchTradeType = component.find('packageLinesTradeType').get('v.value');
        var packageLinesSearchCategory = component.find('packageLinesCategory').get('v.value');
        var packageLinesSearchProductType = component.find('packageLinesProductType').get('v.value');
        // TakeOff Lines Search
        var tradeType = component.find('tradeType').get('v.value');
        var category = component.find('category').get('v.value');
        var productType = component.find('productType').get('v.value');
        helper.addIndividualTakeOffLine(component, event, helper, pageNumber, pageSize, packageLinesSearchTradeType, packageLinesSearchCategory, packageLinesSearchProductType, tradeType, category, productType, packageLinesList[groupIndex].groupedRecords[index].Id);
    },
    deleteAllTakeOffLines: function (component, event, helper) {
        if (!component.get('v.isDeleteModal')) {
            var takeOffLinesList = component.get('v.takeOffLinesList');
            var groupIndex = event.getSource().get("v.title");
            var selectedTakeOffLines = [];
            for (var i in takeOffLinesList[groupIndex].groupedRecords) {
                if (takeOffLinesList[groupIndex].groupedRecords[i].isSelected) {
                    selectedTakeOffLines.push(takeOffLinesList[groupIndex].groupedRecords[i].Id);
                }
            }
            if (selectedTakeOffLines != undefined && selectedTakeOffLines.length > 0) {
                component.set('v.takeOffLinesToDeleteList', selectedTakeOffLines);
                component.set('v.deleteConfirmationBody', 'Are you sure you want Delete All takeOff Lines?');
                component.set('v.isDeleteModal', !component.get('v.isDeleteModal'));
            } else {
                helper.showToast(component, event, helper, 'Warning!', 'Select at least one TakeOff Lines', 'warning');
                component.set('v.isDeleteModal', false);
            }
        } else {
            component.set('v.isDeleteModal', false);
        }
    },

    deleteSelectedTakeOffLine: function (component, event, helper) {
        component.set('v.isSpinner', true);
        component.set('v.isDeleteModal', false);
        var pageNumber = component.get("v.pageNumber");
        var pageSize = component.get("v.pageSize");
        //Package Lines
        var packageLinesSearchTradeType = component.find('packageLinesTradeType').get('v.value');
        var packageLinesSearchCategory = component.find('packageLinesCategory').get('v.value');
        var packageLinesSearchProductType = component.find('packageLinesProductType').get('v.value');
        // TakeOff Lines Search
        var tradeType = component.find('tradeType').get('v.value');
        var category = component.find('category').get('v.value');
        var productType = component.find('productType').get('v.value');
        helper.deleteTakeOffLine(component, event, helper, pageNumber, pageSize, packageLinesSearchTradeType, packageLinesSearchCategory, packageLinesSearchProductType, tradeType, category, productType);
    },

    addSelectedLines: function (component, event, helper) {
        component.set("v.isSpinner", true);
        var pageSize = component.get("v.pageSize");
        var pageNumber = component.get('v.pageNumber');
        // Package Lines Search
        var packageLinesSearchTradeType = component.find('packageLinesTradeType').get('v.value');
        var packageLinesSearchCategory = component.find('packageLinesCategory').get('v.value');
        var packageLinesSearchProductType = component.find('packageLinesProductType').get('v.value');
        // TakeOff Lines Search
        var tradeType = component.find('tradeType').get('v.value');
        var category = component.find('category').get('v.value');
        var productType = component.find('productType').get('v.value');
        var packageLinesList = component.get('v.packageLinesList');
        var groupIndex = event.getSource().get("v.title");
        var listOfIdsToInsert = [];
        for (var i in packageLinesList[groupIndex].groupedRecords) {
            if (packageLinesList[groupIndex].groupedRecords[i].isSelected) {
                listOfIdsToInsert.push(packageLinesList[groupIndex].groupedRecords[i].Id);
            }
        }
        if (listOfIdsToInsert != undefined && listOfIdsToInsert.length > 0) {
            helper.addGroupedLines(component, event, helper, pageNumber, pageSize, packageLinesSearchTradeType, packageLinesSearchCategory, packageLinesSearchProductType, tradeType, category, productType, listOfIdsToInsert);
        } else {
            component.set('v.isSpinner', false);
            helper.showToast(component, event, helper, 'Warning!', 'Please select the Line you would like to add.', 'warning');
        }
    },

    replaceTakeOffLine: function (component, event, helper) {
        var packageLinesList = component.get('v.packageLinesList');
        var takeOffLinesList = component.get('v.takeOffLinesList');
        var packageCount = 0;
        var takeOffCount = 0;
        var packageLineId = [];
        var takeOffLineId = [];
        for (var i in packageLinesList) {
            for (var j in packageLinesList[i].groupedRecords) {
                if (packageLinesList[i].groupedRecords[j].isSelected) {
                    packageCount++;
                    packageLineId.push(packageLinesList[i].groupedRecords[j].Id);
                }
            }
        }

        for (var i in takeOffLinesList) {
            for (var j in takeOffLinesList[i].groupedRecords) {
                if (takeOffLinesList[i].groupedRecords[j].isSelected) {
                    takeOffLinesList[i].groupedRecords[j].isReplaced = true;
                    takeOffLinesList[i].groupedRecords[j].isSelected = false;
                    takeOffCount++;
                    takeOffLineId.push(takeOffLinesList[i].groupedRecords[j].Id);
                }
            }
        }

        packageCount > 1 ?
            helper.showToast(component, event, helper, 'Warning!', 'Select only one Package Lines', 'warning') :
            '';


        takeOffCount > 1 ?
            helper.showToast(component, event, helper, 'Warning!', 'Select only one TakeOff Lines', 'warning') :
            '';

        packageCount == 0 ?
            helper.showToast(component, event, helper, 'Warning!', 'Select at least one Package Lines', 'warning') :
            '';


        takeOffCount == 0 ?
            helper.showToast(component, event, helper, 'Warning!', 'Select at least one TakeOff Lines', 'warning') :
            '';

        if (packageCount == 1 && takeOffCount == 1) {
            component.set('v.takeOffLinesToDelete', takeOffLineId);
            component.set('v.packageLinesToAdd', packageLineId);
            component.set('v.takeOffLinesList', takeOffLinesList);
            helper.updateTakeOffLines(component, event, helper);
            component.set('v.takeOffLinesToDelete', []);
            component.set('v.packageLinesToAdd', []);
        }
    },

    closeModel: function (component, event, helper) {
        component.set('v.isReplaceAll', false);
    },

    replaceAllTakeOffLines: function (component, event, helper) {
        component.set('v.isReplaceAll', !component.get('v.isReplaceAll'));
        if (!component.get('v.isReplaceAll')) {
            var takeOffLinesList = component.get('v.takeOffLinesList');
            var takeOffListIdsToDelete = [];
            for (var i in takeOffLinesList) {
                for (var j in takeOffLinesList[i].groupedRecords) {
                    takeOffListIdsToDelete.push(takeOffLinesList[i].groupedRecords[j].Id);
                }
            }
            component.get('v.takeOffLinesIds').length > 0 && takeOffListIdsToDelete.length > 0 ?
                helper.replaceTakeOffLines(component, event, helper, takeOffListIdsToDelete) :
                helper.showToast(component, event, helper, 'Warning!', 'Something went wrong!', 'warning');
        }
    },

    onInputChange: function (component, event, helper) {
        component.set("v.isSpinner", true);
        var pageSize = component.get("v.pageSize");
        // Package Lines Search
        var packageLinesSearchTradeType = component.find('packageLinesTradeType').get('v.value');
        var packageLinesSearchCategory = component.find('packageLinesCategory').get('v.value');
        var packageLinesSearchProductType = component.find('packageLinesProductType').get('v.value');
        // TakeOff Lines Search
        var tradeType = component.find('tradeType').get('v.value');
        var category = component.find('category').get('v.value');
        var productType = component.find('productType').get('v.value');
        helper.getRecords(component, event, helper, 1, pageSize, packageLinesSearchTradeType, packageLinesSearchCategory, packageLinesSearchProductType, tradeType, category, productType);
    },

    onPackageLineInputChange: function (component, event, helper) {
        component.set("v.isSpinner", true);
        var pageSize = component.get("v.pageSize");
        // Package Lines Search
        var packageLinesSearchTradeType = component.find('packageLinesTradeType').get('v.value');
        var packageLinesSearchCategory = component.find('packageLinesCategory').get('v.value');
        var packageLinesSearchProductType = component.find('packageLinesProductType').get('v.value');
        // TakeOff Lines Search
        var tradeType = component.find('tradeType').get('v.value');
        var category = component.find('category').get('v.value');
        var productType = component.find('productType').get('v.value');
        helper.getRecords(component, event, helper, 1, pageSize, packageLinesSearchTradeType, packageLinesSearchCategory, packageLinesSearchProductType, tradeType, category, productType);
    },

    handlePrev: function (component, event, helper) {
        component.set('v.isSpinner', true);
        var pageNumber = component.get("v.pageNumber");
        var pageSize = component.get("v.pageSize");

        var packageLinesList = component.get('v.packageLinesList');
        var packageLinesSearchTradeType = component.find('packageLinesTradeType').get('v.value');
        var packageLinesSearchCategory = component.find('packageLinesCategory').get('v.value');
        var packageLinesSearchProductType = component.find('packageLinesProductType').get('v.value');
        // TakeOff Lines Search
        var tradeType = component.find('tradeType').get('v.value');
        var category = component.find('category').get('v.value');
        var productType = component.find('productType').get('v.value');
        var filteredTakeOffLines = [];

        //Check UnCheck All
        for (var i in packageLinesList) {
            for (var j in packageLinesList[i].groupedRecords) {
                if (packageLinesList[i].groupedRecords[j].isSelected) {
                    var obj = {};
                    obj.buildertek__Trade_Type__c = packageLinesList[i].groupedRecords[j].buildertek__Trade_Type__c != undefined ? packageLinesList[i].groupedRecords[j].buildertek__Trade_Type__c : null;
                    obj.buildertek__Product_Type__c = packageLinesList[i].groupedRecords[j].buildertek__Product_Type__c != undefined ? packageLinesList[i].groupedRecords[j].buildertek__Product_Type__c : null;
                    obj.buildertek__Category__c = packageLinesList[i].groupedRecords[j].buildertek__Category__c != undefined ? packageLinesList[i].groupedRecords[j].buildertek__Category__c : null;
                    obj.buildertek__Location__c = packageLinesList[i].groupedRecords[j].buildertek__Location__c != undefined ? packageLinesList[i].groupedRecords[j].buildertek__Location__c : null;
                    filteredTakeOffLines.push(obj);
                }
            }
        }
        component.set('v.takeOffLinesList', []);
        component.set('v.packageLinesList', packageLinesList);
        //Filter records
        pageNumber--;
        helper.getFilteredTakeOffLines(component, event, helper, pageNumber, pageSize, packageLinesSearchTradeType, packageLinesSearchCategory, packageLinesSearchProductType, tradeType, category, productType, filteredTakeOffLines);
    },

    handleNext: function (component, event, helper) {
        component.set('v.isSpinner', true);
        var pageNumber = component.get("v.pageNumber");
        var pageSize = component.get("v.pageSize");

        var packageLinesList = component.get('v.packageLinesList');
        //var groupIndex = event.getSource().get("v.name");
        var packageLinesSearchTradeType = component.find('packageLinesTradeType').get('v.value');
        var packageLinesSearchCategory = component.find('packageLinesCategory').get('v.value');
        var packageLinesSearchProductType = component.find('packageLinesProductType').get('v.value');
        // TakeOff Lines Search
        var tradeType = component.find('tradeType').get('v.value');
        var category = component.find('category').get('v.value');
        var productType = component.find('productType').get('v.value');
        var filteredTakeOffLines = [];

        //Check UnCheck All
        for (var i in packageLinesList) {
            for (var j in packageLinesList[i].groupedRecords) {
                if (packageLinesList[i].groupedRecords[j].isSelected) {
                    var obj = {};
                    obj.buildertek__Trade_Type__c = packageLinesList[i].groupedRecords[j].buildertek__Trade_Type__c != undefined ? packageLinesList[i].groupedRecords[j].buildertek__Trade_Type__c : null;
                    obj.buildertek__Product_Type__c = packageLinesList[i].groupedRecords[j].buildertek__Product_Type__c != undefined ? packageLinesList[i].groupedRecords[j].buildertek__Product_Type__c : null;
                    obj.buildertek__Category__c = packageLinesList[i].groupedRecords[j].buildertek__Category__c != undefined ? packageLinesList[i].groupedRecords[j].buildertek__Category__c : null;
                    obj.buildertek__Location__c = packageLinesList[i].groupedRecords[j].buildertek__Location__c != undefined ? packageLinesList[i].groupedRecords[j].buildertek__Location__c : null;
                    filteredTakeOffLines.push(obj);
                }
            }
        }
        component.set('v.takeOffLinesList', []);
        component.set('v.packageLinesList', packageLinesList);
        //Filter records
        pageNumber++;
        helper.getFilteredTakeOffLines(component, event, helper, pageNumber, pageSize, packageLinesSearchTradeType, packageLinesSearchCategory, packageLinesSearchProductType, tradeType, category, productType, filteredTakeOffLines);
    },
})