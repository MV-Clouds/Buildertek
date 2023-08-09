({
    getProjectTakeOffRec: function (component, event, helper) {
        var action = component.get("c.getProjectDetails");
        action.setParams({
            recordId: component.get('v.recordId'),
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result != null && result != undefined) {
                    component.set('v.projectSelectionTakeOffRec', result.projectRec);
                }
            } else {
                helper.showToast(component, event, helper, 'Error!', 'Something went wrong!', 'error');
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
    },

    getRecords: function (component, event, helper) {
        debugger;
        var productPageNumber = component.get("v.productPageNumber");
        var productPageSize = component.get("v.productPageSize");
        var pageNumber = component.get("v.pageNumber");
        var pageSize = component.get("v.pageSize");
        var SSTLPageNumber = component.get("v.SSTLPageNumber");
        var SSTLPageSize = component.get("v.SSTLPageSize");
        var action = component.get("c.getAllProductsAndTakeOffLines");
        action.setParams({
            recordId: component.get('v.recordId'),
            productPageNumber: productPageNumber,
            productPageSize: productPageSize,
            pageNumber: pageNumber,
            pageSize: pageSize,
            SSTLPageNumber: SSTLPageNumber,
            SSTLPageSize: SSTLPageSize
        });
        action.setCallback(this, function (response) {
            debugger;
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result != null) {
                    result.productsRecord = result.productsRecord == undefined ? [] : result.productsRecord;
                    result.takeOffLinesList = result.takeOffLinesList == undefined ? [] : result.takeOffLinesList;
                    result.selectionSheetTakeOffLines = result.selectionSheetTakeOffLines == undefined ? [] : result.selectionSheetTakeOffLines;
                    if (result.productsRecord != undefined) {
                        helper.setProductRecords(component, productPageNumber, productPageSize, result.productsRecord.length, result.productTotalRecords);
                        component.set('v.productsList', helper.groupRecords(result.productsRecord));
                    }
                    if (result.takeOffLinesList != undefined) { 
                        helper.setTakeOffLinesRecords(component, pageNumber, pageSize, result.takeOffLinesList.length, result.totalRecords)
                        component.set('v.takeOffLinesList', helper.groupRecords(result.takeOffLinesList));
                    }
                    if (result.selectionSheetTakeOffLines != undefined) {
                        debugger;
                        console.log('result.selectionSheetTakeOffLines::::',result.selectionSheetTakeOffLines);
                        console.log('result.SSTLTotalRecords::::',result.SSTLTotalRecords);
                        result.selectionSheetTakeOffLines != undefined ? helper.setSSTLRecords(component, SSTLPageNumber, SSTLPageSize, result.selectionSheetTakeOffLines.length, result.SSTLTotalRecords) : '';
                        component.set('v.selectionSheetTakeOffLines', helper.groupRecords(result.selectionSheetTakeOffLines));
                    }
                }
                component.set("v.isSpinner", false);
            } else {
                helper.showToast(component, event, helper, 'Error!', 'Something went wrong!', 'error');
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
    },

    getSelectedProductsTakeOffLines: function (component, event, helper, filteredTakeOffLines) {
        var productPageNumber = component.get("v.productPageNumber");
        var productPageSize = component.get("v.productPageSize");
        var pageNumber = component.get("v.pageNumber");
        var pageSize = component.get("v.pageSize");
        var SSTLPageNumber = component.get("v.SSTLPageNumber");
        var SSTLPageSize = component.get("v.SSTLPageSize");
        var action = component.get("c.getAllProductsAndSelectedTakeOffLines");
        action.setParams({
            recordId: component.get('v.recordId'),
            productPageNumber: productPageNumber,
            productPageSize: productPageSize,
            pageNumber: pageNumber,
            pageSize: pageSize,
            SSTLPageNumber: SSTLPageNumber,
            SSTLPageSize: SSTLPageSize,
            filteredTakeOffLines: JSON.stringify(filteredTakeOffLines)
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result != null) {
                    result.takeOffLinesList = result.takeOffLinesList == undefined ? [] : result.takeOffLinesList;
                    result.selectionSheetTakeOffLines = result.selectionSheetTakeOffLines == undefined ? [] : result.selectionSheetTakeOffLines;
                    if (result.takeOffLinesList != undefined) {
                        helper.setTakeOffLinesRecords(component, pageNumber, pageSize, result.takeOffLinesList.length, result.totalRecords)
                        component.set('v.takeOffLinesList', helper.groupRecords(result.takeOffLinesList));
                    }
                    if (result.selectionSheetTakeOffLines != undefined) {
                        result.selectionSheetTakeOffLines != undefined ? helper.setSSTLRecords(component, SSTLPageNumber, SSTLPageSize, result.selectionSheetTakeOffLines.length, result.SSTLTotalRecords) : '';
                        component.set('v.selectionSheetTakeOffLines', helper.groupRecords(result.selectionSheetTakeOffLines));
                    }
                }
                component.set("v.isSpinner", false);
            } else {
                helper.showToast(component, event, helper, 'Error!', 'Something went wrong!', 'error');
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
    },

    // Set Product Response records
    setProductRecords: function (component, pageNumber, pageSize, recordLength, totalRecords) {
        //Product
        component.set("v.productIsNextDisabled", true);
        component.set("v.productPageNumber", pageNumber);
        component.set("v.productRecordStart", (pageNumber - 1) * pageSize + 1);
        component.set("v.productRecordEnd", (recordLength + 3) * pageNumber);
        component.set('v.productTotalRecords', totalRecords);
        component.set("v.productTotalPages", Math.ceil(recordLength / totalRecords));
        if (totalRecords < pageNumber * pageSize) {
            component.set("v.productIsNextDisabled", true);
        } else {
            component.set("v.productIsNextDisabled", false);
        }
    },

    // Set TakeOff Lines Response records
    setTakeOffLinesRecords: function (component, pageNumber, pageSize, recordLength, totalRecords) {
        // TakeOff Lines
        component.set("v.isNextDisabled", true);
        component.set("v.pageNumber", pageNumber);
        component.set("v.recordStart", (pageNumber - 1) * pageSize + 1);
        component.set("v.recordEnd", (recordLength + 3) * pageNumber);
        component.set('v.totalRecords', totalRecords);
        component.set("v.totalPages", Math.ceil(recordLength / totalRecords));
        if (totalRecords < pageNumber * pageSize) {
            component.set("v.isNextDisabled", true);
        } else {
            component.set("v.isNextDisabled", false);
        }
    },

    //Set SSTL Response
    setSSTLRecords: function (component, pageNumber, pageSize, recordLength, totalRecords) {
        // SSTL
        component.set("v.SSTLIsNextDisabled", true);
        component.set("v.SSTLPageNumber", pageNumber);
        component.set("v.SSTLRecordStart", (pageNumber - 1) * pageSize + 1);
        component.set("v.SSTLRecordEnd", (recordLength + 3) * pageNumber);
        component.set('v.SSTLTotalRecords', totalRecords);
        component.set("v.SSTLTotalPages", Math.ceil(recordLength / totalRecords));
        if (totalRecords < pageNumber * pageSize) {
            component.set("v.SSTLIsNextDisabled", true);
        } else {
            component.set("v.SSTLIsNextDisabled", false);
        }
    },

    //Group by Trade Type
    groupRecords: function (data) {
        debugger;
        var listOfRecords = [];
        let recordMap = new Map();
        for (var i in data) {
            //Created Key with (#*&)
            if (data[i].buildertek__Trade_Type__r != undefined) {
                if (!recordMap.has(data[i].buildertek__Trade_Type__c + '(#*&)' + data[i].buildertek__Trade_Type__r.Name)) {
                    recordMap.set(data[i].buildertek__Trade_Type__c + '(#*&)' + data[i].buildertek__Trade_Type__r.Name, []);
                }
                recordMap.get(data[i].buildertek__Trade_Type__c + '(#*&)' + data[i].buildertek__Trade_Type__r.Name).push(data[i]);
            } else {
                data[i].buildertek__Trade_Type__c = 'No Grouping';
                data[i].buildertek__Trade_Type__r = {};
                data[i].buildertek__Trade_Type__r.Name = 'No Grouping';
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
            obj.groupedRecords = result[i][1];
            obj.isSelected = false; 
            for (var j in obj.groupedRecords) {
                obj.groupedRecords[j].isSelected = false;
            }
            listOfRecords.push(obj);
        }
        console.log('listOfRecords:::::::',listOfRecords);
        return listOfRecords;
    },

    /*assignProductToSSTL: function (component, event, helper, selectedSSTL) {
        component.set("v.isSpinner", true);
        var productPageNumber = component.get("v.productPageNumber");
        var productPageSize = component.get("v.productPageSize");
        var pageNumber = component.get("v.pageNumber");
        var pageSize = component.get("v.pageSize");
        var SSTLPageNumber = component.get("v.SSTLPageNumber");
        var SSTLPageSize = component.get("v.SSTLPageSize");
        var action = component.get("c.assignProductToSSTLRecord1");
        action.setParams({
            productPageNumber: productPageNumber,
            productPageSize: productPageSize,
            pageNumber: pageNumber,
            pageSize: pageSize,
            SSTLPageNumber: SSTLPageNumber,
            SSTLPageSize: SSTLPageSize,
            filteredTakeOffLines: JSON.stringify(component.get('v.filteredTakeOffLines')),
            productId: component.get('v.productId'),
            selectedSSTL: selectedSSTL
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result != null && result == 'Success') {
                    helper.showToast(component, event, helper, 'Success!', 'Product Assigned Successfully!', 'success');
                }
                component.set("v.isSpinner", false);
            } else {
                helper.showToast(component, event, helper, 'Error!', 'Something went wrong!', 'error');
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
    },*/
    createTakeOffLines: function (component, event, helper, productPageNumber, productPageSize, pageNumber, pageSize, SSTLPageNumber, SSTLPageSize, packageLinesSearchTradeType, packageLinesSearchCategory, packageLinesSearchProductType, collection, tradeType, category, productType, locationSearch, tradeTypeSSTL, categorySSTL, productTypeSSTL, productIdList, takeOffLineList) {
        var action = component.get("c.createTakeOffLinesRecords");
        component.set("v.NewProduct",productIdList);
        action.setParams({
            productIds: component.get('v.productIds'),
            recordId: component.get('v.recordId'),
            productPageNumber: productPageNumber,
            productPageSize: productPageSize,
            pageNumber: pageNumber,
            pageSize: pageSize,
            SSTLPageNumber: SSTLPageNumber,
            SSTLPageSize: SSTLPageSize,
            packageLinesSearchTradeType: packageLinesSearchTradeType,
            packageLinesSearchCategory: packageLinesSearchCategory,
            packageLinesSearchProductType: packageLinesSearchProductType,
            collection: collection,
            tradeType: tradeType,
            category: category,
            productType: productType,
            locationSearch: locationSearch,
            tradeTypeSSTL: tradeTypeSSTL,
            categorySSTL: categorySSTL,
            productTypeSSTL: productTypeSSTL,
            productIdList: productIdList,
            takeOffLineList: takeOffLineList,
            projectId: component.get('v.projectSelectionTakeOffRec').buildertek__Project__c
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                result.selectionSheetTakeOffLines = result.selectionSheetTakeOffLines == undefined ? [] : result.selectionSheetTakeOffLines;
                if (result != null && result.selectionSheetTakeOffLines != undefined) {
                  /*  for(var i=0;i<result.productsRecord.length;i++){
                        var selectedproduct = component.get("v.NewProduct");
                        for(var j=0;j<selectedproduct.length;j++){
                            if(selectedproduct[j]==result.productsRecord[i].Id){
                                var vendorName = result.productsRecord[i].buildertek__Vendor__r.Name;
                                for(var k=0;k<result.selectionSheetTakeOffLines.length;k++){
                                    result.selectionSheetTakeOffLines[k]['vendor'] = vendorName;
                                }
                            }
                        }
                    }*/
                       // console.log(result.selectionSheetTakeOffLines);
               
                    helper.setSSTLRecords(component, SSTLPageNumber, SSTLPageSize, result.selectionSheetTakeOffLines.length, result.SSTLTotalRecords);
                    component.set('v.selectionSheetTakeOffLines', helper.groupRecords(result.selectionSheetTakeOffLines));
                }
                helper.showToast(component, event, helper, 'Success!', 'Selection Sheet TakeOff Lines created Successfully!!', 'success');
                component.set("v.isSpinner", false);

            } else {
                helper.showToast(component, event, helper, 'Error!', 'Something went wrong!', 'error');
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
    },

    //In Use Search Result
    getSearchRecords: function (component, event, helper, productPageNumber, productPageSize, pageNumber, pageSize, SSTLPageNumber, SSTLPageSize, packageLinesSearchTradeType, packageLinesSearchCategory, packageLinesSearchProductType, collection, buildPhase, tradeType, category, productType, locationSearch, tradeTypeSSTL, categorySSTL, productTypeSSTL) {
        var action = component.get("c.searchQueryResult2");
        action.setParams({
            recordId: component.get('v.recordId'),
            productPageNumber: productPageNumber,
            productPageSize: productPageSize,
            pageNumber: pageNumber,
            pageSize: pageSize,
            SSTLPageNumber: SSTLPageNumber,
            SSTLPageSize: SSTLPageSize,
            packageLinesSearchTradeType: packageLinesSearchTradeType,
            packageLinesSearchCategory: packageLinesSearchCategory,
            packageLinesSearchProductType: packageLinesSearchProductType,
            collection: collection,
            buildPhase: buildPhase,
            tradeType: tradeType,
            category: category,
            productType: productType,
            locationSearch: locationSearch,
            tradeTypeSSTL: tradeTypeSSTL,
            categorySSTL: categorySSTL,
            productTypeSSTL: productTypeSSTL
        });
        action.setCallback(this, function (response) {
            debugger;
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result != null) {
                    result.productsRecord = result.productsRecord == undefined ? [] : result.productsRecord;
                    result.takeOffLinesList = result.takeOffLinesList == undefined ? [] : result.takeOffLinesList;
                    result.selectionSheetTakeOffLines = result.selectionSheetTakeOffLines == undefined ? [] : result.selectionSheetTakeOffLines;

                    if (result.productsRecord != undefined) {
                        helper.setProductRecords(component, productPageNumber, productPageSize, result.productsRecord.length, result.productTotalRecords);
                        component.set('v.productsList', helper.groupRecords(result.productsRecord));
                    }
                    if (result.takeOffLinesList != undefined) {
                        helper.setTakeOffLinesRecords(component, pageNumber, pageSize, result.takeOffLinesList.length, result.totalRecords)
                        component.set('v.takeOffLinesList', helper.groupRecords(result.takeOffLinesList));
                    }
                    if (result.selectionSheetTakeOffLines != undefined) {
                        result.selectionSheetTakeOffLines != undefined ? helper.setSSTLRecords(component, SSTLPageNumber, SSTLPageSize, result.selectionSheetTakeOffLines.length, result.SSTLTotalRecords) : '';
                        component.set('v.selectionSheetTakeOffLines', helper.groupRecords(result.selectionSheetTakeOffLines));
                    }
                }
                component.set("v.isSpinner", false);
            } else {
                helper.showToast(component, event, helper, 'Error!', 'Something went wrong!', 'error');
                console.log('Error');
                component.set("v.isSpinner", false);
            }
        });
        $A.enqueueAction(action);
    },

    //On TakeOff Lines Select
    retrieveProducts: function (component, event, helper, productPageNumber, productPageSize, pageNumber, pageSize, SSTLPageNumber, SSTLPageSize, packageLinesSearchTradeType, packageLinesSearchCategory, packageLinesSearchProductType, collection, tradeType, category, productType, locationSearch, tradeTypeSSTL, categorySSTL, productTypeSSTL, filteredTakeOffLines) {
       console.log('filteredTakeOffLines Helper',filteredTakeOffLines);
        var action = component.get("c.retrieveProductRecords");
        action.setParams({
            recordId: component.get('v.recordId'),
            productPageNumber: productPageNumber,
            productPageSize: productPageSize,
            pageNumber: pageNumber,
            pageSize: pageSize,
            SSTLPageNumber: SSTLPageNumber,
            SSTLPageSize: SSTLPageSize,
            packageLinesSearchTradeType: packageLinesSearchTradeType,
            packageLinesSearchCategory: packageLinesSearchCategory,
            packageLinesSearchProductType: packageLinesSearchProductType,
            collection: collection,
            tradeType: tradeType,
            category: category,
            productType: productType,
            locationSearch: locationSearch,
            tradeTypeSSTL: tradeTypeSSTL,
            categorySSTL: categorySSTL,
            productTypeSSTL: productTypeSSTL,
            filteredTakeOffLines: JSON.stringify(filteredTakeOffLines)
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result != null) {
                    result.productsRecord = result.productsRecord == undefined ? [] : result.productsRecord;
                    result.selectionSheetTakeOffLines = result.selectionSheetTakeOffLines == undefined ? [] : result.selectionSheetTakeOffLines;
                    if (result.productsRecord != undefined) {
                        helper.setProductRecords(component, productPageNumber, productPageSize, result.productsRecord.length, result.productTotalRecords);
                        component.set('v.productsList', helper.groupRecords(result.productsRecord));
                    }
                    if (result.selectionSheetTakeOffLines != undefined) {
                        result.selectionSheetTakeOffLines != undefined ? helper.setSSTLRecords(component, SSTLPageNumber, SSTLPageSize, result.selectionSheetTakeOffLines.length, result.SSTLTotalRecords) : '';
                        component.set('v.selectionSheetTakeOffLines', helper.groupRecords(result.selectionSheetTakeOffLines));
                    }
                }
                component.set("v.isSpinner", false);
            } else {
                helper.showToast(component, event, helper, 'Error!', 'Something went wrong!', 'error');
                console.log('Error');
                component.set("v.isSpinner", false);
            }
        });
        $A.enqueueAction(action);
    },
    deleteSelectedSSTL: function (component, event, helper, productPageNumber, productPageSize, pageNumber, pageSize, SSTLPageNumber, SSTLPageSize, packageLinesSearchTradeType, packageLinesSearchCategory, packageLinesSearchProductType, collection, tradeType, category, productType, locationSearch, tradeTypeSSTL, categorySSTL, productTypeSSTL) {
        var action = component.get("c.deleteSelectedSSTLRecord");
        action.setParams({
            recordId: component.get('v.recordId'),
            productPageNumber: productPageNumber,
            productPageSize: productPageSize,
            pageNumber: pageNumber,
            pageSize: pageSize,
            SSTLPageNumber: SSTLPageNumber,
            SSTLPageSize: SSTLPageSize,
            packageLinesSearchTradeType: packageLinesSearchTradeType,
            packageLinesSearchCategory: packageLinesSearchCategory,
            packageLinesSearchProductType: packageLinesSearchProductType,
            collection: collection,
            tradeType: tradeType,
            category: category,
            productType: productType,
            locationSearch: locationSearch,
            tradeTypeSSTL: tradeTypeSSTL,
            categorySSTL: categorySSTL,
            productTypeSSTL: productTypeSSTL,
            deleteSSTLIds: component.get('v.selectionSheetTakeOffLinesToDelete')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                result.selectionSheetTakeOffLines = result.selectionSheetTakeOffLines == undefined ? [] : result.selectionSheetTakeOffLines;
                if (result != null) {
                    helper.setSSTLRecords(component, SSTLPageNumber, SSTLPageSize, result.selectionSheetTakeOffLines.length, result.SSTLTotalRecords);
                    component.set('v.selectionSheetTakeOffLines', helper.groupRecords(result.selectionSheetTakeOffLines));
                }
                component.set('v.selectionSheetTakeOffLinesToDelete', '');
                component.set("v.isSpinner", false);
            } else {
                component.set('v.selectionSheetTakeOffLinesToDelete', '');
                helper.showToast(component, event, helper, 'Error!', 'Something went wrong!', 'error');
                console.log('Error');
                component.set("v.isSpinner", false);
            }
        });
        $A.enqueueAction(action);
    },
    showToast: function (component, event, helper, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            mode: 'pester',
            message: message,
            type: type,
            duration: 5
        });
        toastEvent.fire();
        component.set("v.isSpinner", false);
    },
})