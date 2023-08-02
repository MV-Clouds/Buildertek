({
    //In Use call Do Init.
    doInit: function (component, event, helper) {
        component.set("v.isSpinner", true);
        //component.set('v.divHeight', 'height:' + screen.height + 'px !important;');
        setTimeout(function () {
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function (response) {
                var focusedTabId = response.tabId;
                workspaceAPI.setTabLabel({
                    tabId: focusedTabId,
                    label: "Create Master SOV"
                });
                workspaceAPI.setTabIcon({
                    tabId: focusedTabId,
                    icon: "custom:custom70"
                });
            }).catch(function (error) {
                console.log('sub tab error::', error);
               // alert(error);
            });
        }, 100);
        helper.getProjectTakeOffRec(component, event, helper);
        helper.getRecords(component, event, helper);
    },

    onTakeOffCheckBoxChange: function (component, event, helper) {
        var takeOffLinesList = component.get('v.takeOffLinesList');
        console.log('takeOffLinesList', takeOffLinesList);
        var groupIndex = event.getSource().get("v.name").split('-')[0];
        var recordIndex = event.getSource().get("v.name").split('-')[1];
        console.log('recordIndex', recordIndex);
        console.log('groupIndex', groupIndex);
        var filteredTakeOffLines = component.get('v.filteredTakeOffLines');
        console.log('filteredTakeOffLines', filteredTakeOffLines);
        var productPageSize = component.get("v.productPageSize");
        var pageNumber = component.get("v.pageNumber");
        var pageSize = component.get("v.pageSize");
        var SSTLPageSize = component.get("v.SSTLPageSize");
        // Product Search
        var packageLinesSearchTradeType = component.find('packageLinesTradeType').get('v.value');
        var packageLinesSearchCategory = component.find('packageLinesCategory').get('v.value');
        var packageLinesSearchProductType = component.find('packageLinesProductType').get('v.value');
        var collection = component.find('collection').get('v.value');
        // TakeOff Lines Search
        var tradeType = component.find('tradeType').get('v.value');
        var category = component.find('category').get('v.value');
        var productType = component.find('productType').get('v.value');
        var locationSearch = component.find('locationSearch').get('v.value');
        // SSTL
        var tradeTypeSSTL = component.find('tradeTypeSSTL').get('v.value');
        var categorySSTL = component.find('categorySSTL').get('v.value');
        var productTypeSSTL = component.find('productTypeSSTL').get('v.value');

        var filteredTakeOffLineList = [];

        takeOffLinesList[groupIndex].groupedRecords[recordIndex].isSelected ?
            filteredTakeOffLines.push(takeOffLinesList[groupIndex].groupedRecords[recordIndex]) :
            filteredTakeOffLines.pop(takeOffLinesList[groupIndex].groupedRecords[recordIndex]);
        for (var i in takeOffLinesList) {
            for (var j in takeOffLinesList[i].groupedRecords) {
                takeOffLinesList[i].groupedRecords[j].isSelected ?
                    filteredTakeOffLineList.push(takeOffLinesList[i].groupedRecords[j]) : '';


            }

        }
        component.set('v.filteredTakeOffLines', filteredTakeOffLineList);
        console.log('filteredTakeOffLineList::::::',filteredTakeOffLineList);
        filteredTakeOffLineList.length > 0 ?
            helper.retrieveProducts(component, event, helper, 1, productPageSize, pageNumber, pageSize, 1, SSTLPageSize, packageLinesSearchTradeType, packageLinesSearchCategory, packageLinesSearchProductType, collection, tradeType, category, productType, locationSearch, tradeTypeSSTL, categorySSTL, productTypeSSTL, filteredTakeOffLineList) :
            helper.getRecords(component, event, helper);
    },

    //In Use - on Product Selection
    onProductSelect: function (component, event, helper) {
        var productsList = component.get('v.productsList');
        var productId = '';
        var filteredTakeOffLines = [];
        var obj = {};
        for (var i in productsList) {
            for (var j in productsList[i].groupedRecords) {
                if (productsList[i].groupedRecords[j].isSelected) {
                    obj = {};
                    productId = productsList[i].groupedRecords[j].Id;
                    obj.buildertek__Trade_Type__c = productsList[i].groupedRecords[j].buildertek__Trade_Type__c != undefined ? productsList[i].groupedRecords[j].buildertek__Trade_Type__c : null;
                    obj.buildertek__Product_Type__c = productsList[i].groupedRecords[j].buildertek__Product_Type__c != undefined ? productsList[i].groupedRecords[j].buildertek__Product_Type__c : null;
                    obj.buildertek__Category__c = productsList[i].groupedRecords[j].buildertek__Category__c != undefined ? productsList[i].groupedRecords[j].buildertek__Category__c : null;
                    filteredTakeOffLines.push(obj);
                }
            }
        }
        if (filteredTakeOffLines.length > 0) {
            component.set('v.isProductSelected', true);
            component.set('v.filteredTakeOffLines', filteredTakeOffLines);
            if (filteredTakeOffLines.length == 1) {
                component.set('v.productId', productId);
                component.set('v.isMoreProductSelected', false);
            } else {
                component.set('v.productId', '');
                component.set('v.isMoreProductSelected', true);
            }
        } else {
            helper.getRecords(component, event, helper);
            component.set('v.isProductSelected', false);
            component.set('v.filteredTakeOffLines', []);
            component.set('v.productId', '');
            component.set('v.isMoreProductSelected', false);
        }
    },

    //Adds Assigned Products
    /*assignProduct: function (component, event, helper) {
        var groupIndex = event.getSource().get("v.title");
        var selectedSSTL = [];
        if (component.get('v.isMoreProductSelected') && component.get('v.isProductSelected')) {
            helper.showToast(component, event, helper, 'Warning!', 'Select Only 1 Product!', 'warning');
        } else if (!component.get('v.isProductSelected')) {
            helper.showToast(component, event, helper, 'Warning!', 'Select at least 1 Product!', 'warning');
        } else if (!component.get('v.isMoreProductSelected') && component.get('v.isProductSelected')) {
            var selectionSheetTakeOffLines = component.get('v.selectionSheetTakeOffLines');
            for (var i in selectionSheetTakeOffLines[groupIndex].groupedRecords) {
                if (selectionSheetTakeOffLines[groupIndex].groupedRecords[i].isSelected) {
                    selectedSSTL.push(selectionSheetTakeOffLines[groupIndex].groupedRecords[i].Id);
                }
            }
            selectedSSTL.length > 0 ? helper.assignProductToSSTL(component, event, helper, selectedSSTL) :
                helper.showToast(component, event, helper, 'Warning!', 'Select at least 1 Selection Sheet TakeOff Lines!', 'warning');
        }
    },*/

    //Add Selected Products into SSTL.
    addSSTL: function (component, event, helper) {
        component.set("v.isSpinner", true);
        var takeOffLinesList = component.get('v.takeOffLinesList');
        var productsList = component.get('v.productsList');
        var productPageNumber = component.get("v.productPageNumber");
        var productPageSize = component.get("v.productPageSize");
        var pageNumber = component.get("v.pageNumber");
        var pageSize = component.get("v.pageSize");
        var SSTLPageNumber = component.get("v.SSTLPageNumber");
        var SSTLPageSize = component.get("v.SSTLPageSize");
        // Product Search

        var packageLinesSearchTradeType = component.find('packageLinesTradeType').get('v.value');
        var packageLinesSearchCategory = component.find('packageLinesCategory').get('v.value');
        var packageLinesSearchProductType = component.find('packageLinesProductType').get('v.value');
        var collection = component.find('collection').get('v.value');
        // TakeOff Lines Search
        var tradeType = component.find('tradeType').get('v.value');
        var category = component.find('category').get('v.value');
        var productType = component.find('productType').get('v.value');
        var locationSearch = component.find('locationSearch').get('v.value');
        // SSTL
        var tradeTypeSSTL = component.find('tradeTypeSSTL').get('v.value');
        var categorySSTL = component.find('categorySSTL').get('v.value');
        var productTypeSSTL = component.find('productTypeSSTL').get('v.value');

        var productIdList = [];
        var takeOffLineList = [];
        for (var i in productsList) {
            for (var j in productsList[i].groupedRecords) {
                if (productsList[i].groupedRecords[j].isSelected) {
                    productIdList.push(productsList[i].groupedRecords[j].Id);
                }
            }
        }
        for (var i in takeOffLinesList) {
            for (var j in takeOffLinesList[i].groupedRecords) {
                if (takeOffLinesList[i].groupedRecords[j].isSelected) {
                    takeOffLineList.push(takeOffLinesList[i].groupedRecords[j].Id);
                }
            }
        }
        productIdList.length > 0 ?
            helper.createTakeOffLines(component, event, helper, productPageNumber, productPageSize, pageNumber, pageSize, SSTLPageNumber, SSTLPageSize, packageLinesSearchTradeType, packageLinesSearchCategory, packageLinesSearchProductType, collection, tradeType, category, productType, locationSearch, tradeTypeSSTL, categorySSTL, productTypeSSTL, productIdList, takeOffLineList) :
            helper.showToast(component, event, helper, 'Warning!', 'Please select at least one Product!', 'warning');
    },

    //Search
    onInputChange: function (component, event, helper) {
        component.set("v.isSpinner", true);
        var productPageNumber = component.get("v.productPageNumber");
        var productPageSize = component.get("v.productPageSize");
        var pageNumber = component.get("v.pageNumber");
        var pageSize = component.get("v.pageSize");
        var SSTLPageNumber = component.get("v.SSTLPageNumber");
        var SSTLPageSize = component.get("v.SSTLPageSize");
        // Product Search

        var packageLinesSearchTradeType = component.find('packageLinesTradeType').get('v.value');
        var packageLinesSearchCategory = component.find('packageLinesCategory').get('v.value');
        var packageLinesSearchProductType = component.find('packageLinesProductType').get('v.value');
        var collection = component.find('collection').get('v.value');
        // TakeOff Lines Search
        var buildPhase = component.find('buildPhase').get('v.value');
        var tradeType = component.find('tradeType').get('v.value');
        var category = component.find('category').get('v.value');
        var productType = component.find('productType').get('v.value');
        var locationSearch = component.find('locationSearch').get('v.value');
        // SSTL
        var tradeTypeSSTL = component.find('tradeTypeSSTL').get('v.value');
        var categorySSTL = component.find('categorySSTL').get('v.value');
        var productTypeSSTL = component.find('productTypeSSTL').get('v.value');
        helper.getSearchRecords(component, event, helper, productPageNumber, productPageSize, 1, pageSize, SSTLPageNumber, SSTLPageSize, packageLinesSearchTradeType, packageLinesSearchCategory, packageLinesSearchProductType, collection,buildPhase, tradeType, category, productType, locationSearch, tradeTypeSSTL, categorySSTL, productTypeSSTL);
    },
    // On Product Input Change
    onProductInputChange: function (component, event, helper) {
        component.set("v.isSpinner", true);
        var productPageNumber = component.get("v.productPageNumber");
        var productPageSize = component.get("v.productPageSize");
        var pageNumber = component.get("v.pageNumber");
        var pageSize = component.get("v.pageSize");
        var SSTLPageNumber = component.get("v.SSTLPageNumber");
        var SSTLPageSize = component.get("v.SSTLPageSize");
        // Product Search

        var packageLinesSearchTradeType = component.find('packageLinesTradeType').get('v.value');
        var packageLinesSearchCategory = component.find('packageLinesCategory').get('v.value');
        var packageLinesSearchProductType = component.find('packageLinesProductType').get('v.value');
        var collection = component.find('collection').get('v.value');
        // TakeOff Lines Search
         
        var buildPhase = component.find('buildPhase').get('v.value');
        var tradeType = component.find('tradeType').get('v.value');
        var category = component.find('category').get('v.value');
        var productType = component.find('productType').get('v.value');
        var locationSearch = component.find('locationSearch').get('v.value');
        // SSTL
        var tradeTypeSSTL = component.find('tradeTypeSSTL').get('v.value');
        var categorySSTL = component.find('categorySSTL').get('v.value');
        var productTypeSSTL = component.find('productTypeSSTL').get('v.value');
        helper.getSearchRecords(component, event, helper, 1, productPageSize, 1, pageSize, 1, SSTLPageSize, packageLinesSearchTradeType, packageLinesSearchCategory, packageLinesSearchProductType, collection, tradeType, category, productType, locationSearch, tradeTypeSSTL, categorySSTL, productTypeSSTL);
    },
    handleNext: function (component, event, helper) {
        component.set("v.isSpinner", true);
        var productPageNumber = component.get("v.productPageNumber");
        var productPageSize = component.get("v.productPageSize");
        var pageNumber = component.get("v.pageNumber");
        var pageSize = component.get("v.pageSize");
        var SSTLPageNumber = component.get("v.SSTLPageNumber");
        var SSTLPageSize = component.get("v.SSTLPageSize");
        // Product Search

        var packageLinesSearchTradeType = component.find('packageLinesTradeType').get('v.value');
        var packageLinesSearchCategory = component.find('packageLinesCategory').get('v.value');
        var packageLinesSearchProductType = component.find('packageLinesProductType').get('v.value');
        var collection = component.find('collection').get('v.value');
        // TakeOff Lines Search
        var tradeType = component.find('tradeType').get('v.value');
        var category = component.find('category').get('v.value');
        var productType = component.find('productType').get('v.value');
        var locationSearch = component.find('locationSearch').get('v.value');
        // SSTL
        var tradeTypeSSTL = component.find('tradeTypeSSTL').get('v.value');
        var categorySSTL = component.find('categorySSTL').get('v.value');
        var productTypeSSTL = component.find('productTypeSSTL').get('v.value');
        pageNumber++;
        helper.getSearchRecords(component, event, helper, 1, productPageSize, pageNumber, pageSize, 1, SSTLPageSize, packageLinesSearchTradeType, packageLinesSearchCategory, packageLinesSearchProductType, collection, tradeType, category, productType, locationSearch, tradeTypeSSTL, categorySSTL, productTypeSSTL);
    },
    handlePrev: function (component, event, helper) {
        component.set("v.isSpinner", true);
        var productPageNumber = component.get("v.productPageNumber");
        var productPageSize = component.get("v.productPageSize");
        var pageNumber = component.get("v.pageNumber");
        var pageSize = component.get("v.pageSize");
        var SSTLPageNumber = component.get("v.SSTLPageNumber");
        var SSTLPageSize = component.get("v.SSTLPageSize");
        // Product Search

        var packageLinesSearchTradeType = component.find('packageLinesTradeType').get('v.value');
        var packageLinesSearchCategory = component.find('packageLinesCategory').get('v.value');
        var packageLinesSearchProductType = component.find('packageLinesProductType').get('v.value');
        var collection = component.find('collection').get('v.value');
        // TakeOff Lines Search
        var tradeType = component.find('tradeType').get('v.value');
        var category = component.find('category').get('v.value');
        var productType = component.find('productType').get('v.value');
        var locationSearch = component.find('locationSearch').get('v.value');
        // SSTL
        var tradeTypeSSTL = component.find('tradeTypeSSTL').get('v.value');
        var categorySSTL = component.find('categorySSTL').get('v.value');
        var productTypeSSTL = component.find('productTypeSSTL').get('v.value');
        pageNumber--;
        helper.getSearchRecords(component, event, helper, 1, productPageSize, pageNumber, pageSize, 1, SSTLPageSize, packageLinesSearchTradeType, packageLinesSearchCategory, packageLinesSearchProductType, collection, tradeType, category, productType, locationSearch, tradeTypeSSTL, categorySSTL, productTypeSSTL);
    },
    //Handle Next on Product
    handleProductNext: function (component, event, helper) {
        component.set("v.isSpinner", true);
        var productPageNumber = component.get("v.productPageNumber");
        var productPageSize = component.get("v.productPageSize");
        var pageNumber = component.get("v.pageNumber");
        var pageSize = component.get("v.pageSize");
        var SSTLPageNumber = component.get("v.SSTLPageNumber");
        var SSTLPageSize = component.get("v.SSTLPageSize");
        // Product Search

        var packageLinesSearchTradeType = component.find('packageLinesTradeType').get('v.value');
        var packageLinesSearchCategory = component.find('packageLinesCategory').get('v.value');
        var packageLinesSearchProductType = component.find('packageLinesProductType').get('v.value');
        var collection = component.find('collection').get('v.value');
        // TakeOff Lines Search
        var tradeType = component.find('tradeType').get('v.value');
        var category = component.find('category').get('v.value');
        var productType = component.find('productType').get('v.value');
        var locationSearch = component.find('locationSearch').get('v.value');
        // SSTL
        var tradeTypeSSTL = component.find('tradeTypeSSTL').get('v.value');
        var categorySSTL = component.find('categorySSTL').get('v.value');
        var productTypeSSTL = component.find('productTypeSSTL').get('v.value');
        productPageNumber++;
        helper.getSearchRecords(component, event, helper, productPageNumber, productPageSize, pageNumber, pageSize, 1, SSTLPageSize, packageLinesSearchTradeType, packageLinesSearchCategory, packageLinesSearchProductType, collection, tradeType, category, productType, locationSearch, tradeTypeSSTL, categorySSTL, productTypeSSTL);
    },
    //Handle Prev on Product
    handleProductPrev: function (component, event, helper) {
        component.set("v.isSpinner", true);
        var productPageNumber = component.get("v.productPageNumber");
        var productPageSize = component.get("v.productPageSize");
        var pageNumber = component.get("v.pageNumber");
        var pageSize = component.get("v.pageSize");
        var SSTLPageNumber = component.get("v.SSTLPageNumber");
        var SSTLPageSize = component.get("v.SSTLPageSize");
        // Product Search

        var packageLinesSearchTradeType = component.find('packageLinesTradeType').get('v.value');
        var packageLinesSearchCategory = component.find('packageLinesCategory').get('v.value');
        var packageLinesSearchProductType = component.find('packageLinesProductType').get('v.value');
        var collection = component.find('collection').get('v.value');
        // TakeOff Lines Search
        var tradeType = component.find('tradeType').get('v.value');
        var category = component.find('category').get('v.value');
        var productType = component.find('productType').get('v.value');
        var locationSearch = component.find('locationSearch').get('v.value');
        // SSTL
        var tradeTypeSSTL = component.find('tradeTypeSSTL').get('v.value');
        var categorySSTL = component.find('categorySSTL').get('v.value');
        var productTypeSSTL = component.find('productTypeSSTL').get('v.value');
        productPageNumber--;
        helper.getSearchRecords(component, event, helper, productPageNumber, productPageSize, 1, pageSize, SSTLPageNumber, SSTLPageSize, packageLinesSearchTradeType, packageLinesSearchCategory, packageLinesSearchProductType, collection, tradeType, category, productType, locationSearch, tradeTypeSSTL, categorySSTL, productTypeSSTL);
    },
    handleSSTLNext: function (component, event, helper) {
        component.set("v.isSpinner", true);
        var productPageNumber = component.get("v.productPageNumber");
        var productPageSize = component.get("v.productPageSize");
        var pageNumber = component.get("v.pageNumber");
        var pageSize = component.get("v.pageSize");
        var SSTLPageNumber = component.get("v.SSTLPageNumber");
        var SSTLPageSize = component.get("v.SSTLPageSize");
        // Product Search

        var packageLinesSearchTradeType = component.find('packageLinesTradeType').get('v.value');
        var packageLinesSearchCategory = component.find('packageLinesCategory').get('v.value');
        var packageLinesSearchProductType = component.find('packageLinesProductType').get('v.value');
        var collection = component.find('collection').get('v.value');
        // TakeOff Lines Search
        var tradeType = component.find('tradeType').get('v.value');
        var category = component.find('category').get('v.value');
        var productType = component.find('productType').get('v.value');
        var locationSearch = component.find('locationSearch').get('v.value');
        // SSTL
        var tradeTypeSSTL = component.find('tradeTypeSSTL').get('v.value');
        var categorySSTL = component.find('categorySSTL').get('v.value');
        var productTypeSSTL = component.find('productTypeSSTL').get('v.value');
        SSTLPageNumber++;
        helper.getSearchRecords(component, event, helper, productPageNumber, productPageSize, pageNumber, pageSize, SSTLPageNumber, SSTLPageSize, packageLinesSearchTradeType, packageLinesSearchCategory, packageLinesSearchProductType, collection, tradeType, category, productType, locationSearch, tradeTypeSSTL, categorySSTL, productTypeSSTL);
    },
    handleSSTLPrev: function (component, event, helper) {
        component.set("v.isSpinner", true);
        var productPageNumber = component.get("v.productPageNumber");
        var productPageSize = component.get("v.productPageSize");
        var pageNumber = component.get("v.pageNumber");
        var pageSize = component.get("v.pageSize");
        var SSTLPageNumber = component.get("v.SSTLPageNumber");
        var SSTLPageSize = component.get("v.SSTLPageSize");
        // Product Search

        var packageLinesSearchTradeType = component.find('packageLinesTradeType').get('v.value');
        var packageLinesSearchCategory = component.find('packageLinesCategory').get('v.value');
        var packageLinesSearchProductType = component.find('packageLinesProductType').get('v.value');
        var collection = component.find('collection').get('v.value');
        // TakeOff Lines Search
        var tradeType = component.find('tradeType').get('v.value');
        var category = component.find('category').get('v.value');
        var productType = component.find('productType').get('v.value');
        var locationSearch = component.find('locationSearch').get('v.value');
        // SSTL
        var tradeTypeSSTL = component.find('tradeTypeSSTL').get('v.value');
        var categorySSTL = component.find('categorySSTL').get('v.value');
        var productTypeSSTL = component.find('productTypeSSTL').get('v.value');
        SSTLPageNumber--;
        helper.getSearchRecords(component, event, helper, productPageNumber, productPageSize, pageNumber, pageSize, SSTLPageNumber, SSTLPageSize, packageLinesSearchTradeType, packageLinesSearchCategory, packageLinesSearchProductType, collection, tradeType, category, productType, locationSearch, tradeTypeSSTL, categorySSTL, productTypeSSTL);
    },

    onClickOpenDeleteModal: function (component, event, helper) {
        component.set('v.deleteConfirmationBody', 'Are you sure you want Delete takeOff Lines?');
        component.set('v.isDeleteModal', !component.get('v.isDeleteModal'));
        if (component.get('v.isDeleteModal')) {
            var selectionSheetTakeOffLines = component.get('v.selectionSheetTakeOffLines');
            var groupIndex = event.getSource().get("v.alternativeText").split('-')[0];
            var index = event.getSource().get("v.alternativeText").split('-')[1];
            component.set('v.selectionSheetTakeOffLinesToDelete', selectionSheetTakeOffLines[groupIndex].groupedRecords[index].Id);
        } else {
            component.set("v.isSpinner", true);
            var productPageNumber = component.get("v.productPageNumber");
            var productPageSize = component.get("v.productPageSize");
            var pageNumber = component.get("v.pageNumber");
            var pageSize = component.get("v.pageSize");
            var SSTLPageNumber = component.get("v.SSTLPageNumber");
            var SSTLPageSize = component.get("v.SSTLPageSize");
            // Product Search

            var packageLinesSearchTradeType = component.find('packageLinesTradeType').get('v.value');
            var packageLinesSearchCategory = component.find('packageLinesCategory').get('v.value');
            var packageLinesSearchProductType = component.find('packageLinesProductType').get('v.value');
            var collection = component.find('collection').get('v.value');
            // TakeOff Lines Search
            var tradeType = component.find('tradeType').get('v.value');
            var category = component.find('category').get('v.value');
            var productType = component.find('productType').get('v.value');
            var locationSearch = component.find('locationSearch').get('v.value');
            // SSTL
            var tradeTypeSSTL = component.find('tradeTypeSSTL').get('v.value');
            var categorySSTL = component.find('categorySSTL').get('v.value');
            var productTypeSSTL = component.find('productTypeSSTL').get('v.value');
            helper.deleteSelectedSSTL(component, event, helper, productPageNumber, productPageSize, pageNumber, pageSize, SSTLPageNumber, SSTLPageSize, packageLinesSearchTradeType, packageLinesSearchCategory, packageLinesSearchProductType, collection, tradeType, locationSearch, category, productType, tradeTypeSSTL, categorySSTL, productTypeSSTL);
        }
    },

    onClickOpenEditModal: function (component, event, helper) {

        var selectionSheetTakeOffLines = component.get('v.selectionSheetTakeOffLines');
        var groupIndex = event.getSource().get("v.alternativeText").split('-')[0];
        var index = event.getSource().get("v.alternativeText").split('-')[1];
        component.set('v.SSTLId', selectionSheetTakeOffLines[groupIndex].groupedRecords[index].Id);

        var modalBody;
        var modalFooter;
        $A.createComponents([
                ["c:DuplicateSSTLEditForm", {
                    "recordId": selectionSheetTakeOffLines[groupIndex].groupedRecords[index].Id,
                }]
            ],
            function (components, status) {
                if (status === "SUCCESS") {
                    modalBody = components[0];
                    component.find('overlayLib').showCustomModal({
                        header: "Edit SSTL",
                        body: modalBody,
                        showCloseButton: true,
                        cssClass: "my-modal,my-custom-class,my-other-class",
                        closeCallback: function () {
                            component.find("overlayLib").notifyClose();
                            $A.get('e.force:refreshView').fire();
                        }
                    });
                }
            }
        );
    },
    onProductGroupSelect: function (component, event, helper) {
        var productsList = component.get("v.productsList");
        var groupIndex = event.getSource().get("v.name"); 
        var isSelected = event.getSource().get('v.checked');
        for(var i in productsList[groupIndex].groupedRecords){
            productsList[groupIndex].groupedRecords[i].isSelected = isSelected ? 
                true : false;
        }
        component.set("v.productsList",productsList);
    },
    
    onClickOpenProductImageModal: function (component, event, helper) {

        var productsList = component.get('v.productsList');
        var groupIndex = event.getSource().get("v.alternativeText").split('-')[0];
        var index = event.getSource().get("v.alternativeText").split('-')[1];
        var modalBody;
        var modalFooter;
        $A.createComponents([
                ["c:ProductImageModal", {
                    "recordId": productsList[groupIndex].groupedRecords[index].Id,
                }]
            ],
            function (components, status) {
                if (status === "SUCCESS") {
                    modalBody = components[0];
                    component.find('overlayLib').showCustomModal({
                        header: "Product Images",
                        body: modalBody,
                        showCloseButton: true,
                        cssClass: "my-modal,my-custom-class,my-other-class",
                        closeCallback: function () {
                            component.find("overlayLib").notifyClose();
                        }
                    });
                }
            }
        );
    },

    closeDeleteModel: function (component, event, helper) {
        component.set('v.isDeleteModal', false);
    },
    closeModel: function (component, event, helper) {
        component.set('v.isReplaceAll', false);
    },
    manageProductLines: function (component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
    evt.setParams({
        componentDef : "c:BT_ManagePOLines",
        componentAttributes: {
            recordId : component.get("v.recordId")
        }
    });
    evt.fire();
        
        
    },
    
})