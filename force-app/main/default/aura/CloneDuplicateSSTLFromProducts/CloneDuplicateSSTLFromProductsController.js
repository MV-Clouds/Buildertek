({
    //In Use call Do Init.
    doInit: function (component, event, helper) {
        component.set("v.isSpinner", true);
        //component.set('v.divHeight', 'height:' + screen.height + 'px !important;');
        /*setTimeout(function () {
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
        }, 100);*/
        var action = component.get("c.getBOMRec");
        action.setParams({
            recordId: component.get('v.recordId'),
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var strTest = result;
                var resultArray;
                if(strTest.indexOf('#-') > -1){
                    resultArray  = strTest.split('#-');
                }else if(strTest.indexOf('-') > -1){
                    resultArray  = strTest.split('-');
                }else if(strTest.indexOf('#')>-1){
                    resultArray  = strTest.split('#');
                }
                
                
                component.set("v.isSpinner", true);
                //component.set('v.divHeight', 'height:' + screen.height + 'px !important;');
                setTimeout(function () {
                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then(function (response) {
                        var focusedTabId = response.tabId;
                        workspaceAPI.setTabLabel({
                            tabId: focusedTabId,
                            label: 'BOM# - '+ resultArray[1]
                        });
                        workspaceAPI.setTabIcon({
                            tabId: focusedTabId,
                            icon: "custom:custom70"
                        });
                    }).catch(function (error) {
                        console.log('sub tab error::', error);
                        //alert(error);
                    });
                }, 100);
            } 
        });
        $A.enqueueAction(action);
        helper.getProjectTakeOffRec(component, event, helper);
        helper.fetchTakeOffLinesData(component, event, helper);
        helper.getRecords(component, event, helper);
        helper.fetchpricebooks(component, event, helper);
        
    },
    
    handleImportNext: function (component, event, helper) {
        var oppList = component.get("v.packageTakeOffList");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var paginationList = [];
        var counter = 0;
        for(var i=end+1; i<end+pageSize+1; i++){
            if(oppList.length > end){   
                paginationList.push(oppList[i]);
                counter ++ ;
            }
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set("v.paginationList", paginationList);

    },   

    handleImportPrev: function (component, event, helper) {
        var oppList = component.get("v.packageTakeOffList");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var paginationList = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++){
            if(i > -1){
                paginationList.push(oppList[i]);
                counter ++;
            }
            else {
                start++;
            }
        }
        start = start - counter;
        end = end - counter; 
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set("v.paginationList", paginationList);
        
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
        var packageLinesSearchTradeType = '';
        var packageLinesSearchCategory = '';
        var packageLinesSearchProductType = '';
        var collection ='';
        
        /* var packageLinesSearchTradeType = component.find('packageLinesTradeType').get('v.value');
        var packageLinesSearchCategory = component.find('packageLinesCategory').get('v.value');
        var packageLinesSearchProductType = component.find('packageLinesProductType').get('v.value');
        var collection = component.find('collection').get('v.value');*/
        
        // TakeOff Lines Search
        var tradeType
        var category
        var locationSearch
        var productType
        /*  var tradeType = component.find('tradeType').get('v.value');
        var category = component.find('category').get('v.value');
        var productType = component.find('productType').get('v.value');
        var locationSearch = component.find('locationSearch').get('v.value');*/
        // SSTL
        // 
        var tradeTypeSSTL = ''
        var categorySSTL = ''
        var productTypeSSTL = ''
        /* var tradeTypeSSTL = component.find('tradeTypeSSTL').get('v.value');
        var categorySSTL = component.find('categorySSTL').get('v.value');
        var productTypeSSTL = component.find('productTypeSSTL').get('v.value');*/
        
        var filteredTakeOffLineList = [];
        
        takeOffLinesList[groupIndex].groupedRecords[recordIndex].isSelected ?
            filteredTakeOffLines.push(takeOffLinesList[groupIndex].groupedRecords[recordIndex]) :
        filteredTakeOffLines.pop(takeOffLinesList[groupIndex].groupedRecords[recordIndex]);
        /*for (var i in takeOffLinesList) {
            for (var j in takeOffLinesList[i].groupedRecords) {
                takeOffLinesList[i].groupedRecords[j].isSelected ?
                    filteredTakeOffLineList.push(takeOffLinesList[i].groupedRecords[j]) : '';


            }

        }*/
        
        for (var i in takeOffLinesList) {
            for (var j in takeOffLinesList[i]['groupedRecordsTmp']) {
                takeOffLinesList[i].groupedRecordsTmp[j].isSelected ?
                    filteredTakeOffLineList.push(takeOffLinesList[i].groupedRecords[j]) : '';
                
                
            }
            
        }
        
        
        ///  takeOffLinesList[0]['groupedRecordsTmp'][0]['isSelected']
        
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
        debugger;
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
        var packageLinesSearchTradeType = '';
        var packageLinesSearchCategory = '';
        var packageLinesSearchProductType = '';
        var collection ='';
        
        /* var packageLinesSearchTradeType = component.find('packageLinesTradeType').get('v.value');
        var packageLinesSearchCategory = component.find('packageLinesCategory').get('v.value');
        var packageLinesSearchProductType = component.find('packageLinesProductType').get('v.value');
        var collection = component.find('collection').get('v.value');*/
        
        // TakeOff Lines Search
        var tradeType
        var category
        var locationSearch
        var productType
        /*  var tradeType = component.find('tradeType').get('v.value');
        var category = component.find('category').get('v.value');
        var productType = component.find('productType').get('v.value');
        var locationSearch = component.find('locationSearch').get('v.value');*/
        // SSTL
        // 
        var tradeTypeSSTL = ''
        var categorySSTL = ''
        var productTypeSSTL = ''
        /* var tradeTypeSSTL = component.find('tradeTypeSSTL').get('v.value');
        var categorySSTL = component.find('categorySSTL').get('v.value');
        var productTypeSSTL = component.find('productTypeSSTL').get('v.value');*/
        
        var productIdList = [];
        var takeOffLineList = [];
        /* for (var i in productsList) {
            for (var j in productsList[i].groupedRecords) {
                if (productsList[i].groupedRecords[j].isSelected) {
                    productIdList.push(productsList[i].groupedRecords[j].Id);
                }
            }
        }*/
        
        for (var i in productsList) {
            for (var j in productsList[i]['groupedRecordsTmp']) {
                if (productsList[i].groupedRecordsTmp[j].isSelected) {
                    productIdList.push(productsList[i].groupedRecords[j].Id);
                }
            }
        }
        
        for (var i in takeOffLinesList) {
            for (var j in takeOffLinesList[i]['groupedRecordsTmp']) {
                if (takeOffLinesList[i].groupedRecordsTmp[j].isSelected) {
                    takeOffLineList.push(takeOffLinesList[i].groupedRecords[j].Id);
                }
            }
        }
        
        
        
        if(takeOffLineList.length > 0 ){
            productIdList.length > 0 ?
                helper.createTakeOffLines(component, event, helper, productPageNumber, productPageSize, pageNumber, pageSize, SSTLPageNumber, SSTLPageSize, packageLinesSearchTradeType, packageLinesSearchCategory, packageLinesSearchProductType, collection, tradeType, category, productType, locationSearch, tradeTypeSSTL, categorySSTL, productTypeSSTL, productIdList, takeOffLineList) :
            helper.showToast(component, event, helper, 'Warning!', 'Please select a Product.', 'warning');
        }else{
            helper.showToast(component, event, helper, 'Warning!', 'You need to select Takeoff Line to associate this Product with.', 'warning'); 
        }
        
        
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
        
        var packageLinesSearchTradeType = '';
        var packageLinesSearchCategory = '';
        var packageLinesSearchProductType = '';
        var collection = '';
        
        /*var packageLinesSearchTradeType = component.find('packageLinesTradeType').get('v.value');
        var packageLinesSearchCategory = component.find('packageLinesCategory').get('v.value');
        var packageLinesSearchProductType = component.find('packageLinesProductType').get('v.value');
        var collection = component.find('collection').get('v.value');*/
        // TakeOff Lines Search
        var buildPhase = '';
        var tradeType = '';
        var category = '';
        var productType = '';
        var locationSearch = ''
        /* var buildPhase = component.find('buildPhase').get('v.value');
        var tradeType = component.find('tradeType').get('v.value');
        var category = component.find('category').get('v.value');
        var productType = component.find('productType').get('v.value');
        var locationSearch = component.find('locationSearch').get('v.value');*/
        // SSTL
        /* var tradeTypeSSTL = component.find('tradeTypeSSTL').get('v.value');
        var categorySSTL = component.find('categorySSTL').get('v.value');
        var productTypeSSTL = component.find('productTypeSSTL').get('v.value');*/
        
        var tradeTypeSSTL = ''
        var categorySSTL = ''
        var productTypeSSTL = ''
        
        
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
        var packageLinesSearchTradeType = '';
        var packageLinesSearchCategory = '';
        var packageLinesSearchProductType = '';
        var collection = '';
        
        /*var packageLinesSearchTradeType = component.find('packageLinesTradeType').get('v.value');
        var packageLinesSearchCategory = component.find('packageLinesCategory').get('v.value');
        var packageLinesSearchProductType = component.find('packageLinesProductType').get('v.value');
        var collection = component.find('collection').get('v.value');*/
        
        // TakeOff Lines Search
        var buildPhase = ''
        var tradeType = ''
        var category =''
        var productType = ''
        var locationSearch =  ''
        
        /* var buildPhase = component.find('buildPhase').get('v.value');
        var tradeType = component.find('tradeType').get('v.value');
        var category = component.find('category').get('v.value');
        var productType = component.find('productType').get('v.value');
        var locationSearch = component.find('locationSearch').get('v.value');*/
        // SSTL
        // 
        var tradeTypeSSTL = ''
        var categorySSTL = ''
        var productTypeSSTL = ''
        
        /* var tradeTypeSSTL = component.find('tradeTypeSSTL').get('v.value');
        var categorySSTL = component.find('categorySSTL').get('v.value');
        var productTypeSSTL = component.find('productTypeSSTL').get('v.value');*/
        
      
        
        
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
        var packageLinesSearchTradeType = '';
        var packageLinesSearchCategory = '';
        var packageLinesSearchProductType = '';
        var collection ='';
        
        /* var packageLinesSearchTradeType = component.find('packageLinesTradeType').get('v.value');
        var packageLinesSearchCategory = component.find('packageLinesCategory').get('v.value');
        var packageLinesSearchProductType = component.find('packageLinesProductType').get('v.value');
        var collection = component.find('collection').get('v.value');*/
        
        // TakeOff Lines Search
        var tradeType
        var category
        var locationSearch
        var productType
        /*  var tradeType = component.find('tradeType').get('v.value');
        var category = component.find('category').get('v.value');
        var productType = component.find('productType').get('v.value');
        var locationSearch = component.find('locationSearch').get('v.value');*/
        // SSTL
        // 
        var tradeTypeSSTL = ''
        var categorySSTL = ''
        var productTypeSSTL = ''
        /* var tradeTypeSSTL = component.find('tradeTypeSSTL').get('v.value');
        var categorySSTL = component.find('categorySSTL').get('v.value');
        var productTypeSSTL = component.find('productTypeSSTL').get('v.value');*/
        
        /* var tradeTypeSSTL = component.find('tradeTypeSSTL').get('v.value');
        var categorySSTL = component.find('categorySSTL').get('v.value');
        var productTypeSSTL = component.find('productTypeSSTL').get('v.value');*/
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
        var packageLinesSearchTradeType = '';
        var packageLinesSearchCategory = '';
        var packageLinesSearchProductType = '';
        var collection ='';
        
        /* var packageLinesSearchTradeType = component.find('packageLinesTradeType').get('v.value');
        var packageLinesSearchCategory = component.find('packageLinesCategory').get('v.value');
        var packageLinesSearchProductType = component.find('packageLinesProductType').get('v.value');
        var collection = component.find('collection').get('v.value');*/
        
        // TakeOff Lines Search
        var tradeType
        var category
        var locationSearch
        var productType
        /*  var tradeType = component.find('tradeType').get('v.value');
        var category = component.find('category').get('v.value');
        var productType = component.find('productType').get('v.value');
        var locationSearch = component.find('locationSearch').get('v.value');*/
        // SSTL
        // 
        var tradeTypeSSTL = ''
        var categorySSTL = ''
        var productTypeSSTL = ''
        /* var tradeTypeSSTL = component.find('tradeTypeSSTL').get('v.value');
        var categorySSTL = component.find('categorySSTL').get('v.value');
        var productTypeSSTL = component.find('productTypeSSTL').get('v.value');*/
        
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
        var packageLinesSearchTradeType = '';
        var packageLinesSearchCategory = '';
        var packageLinesSearchProductType = '';
        var collection ='';
        
        /* var packageLinesSearchTradeType = component.find('packageLinesTradeType').get('v.value');
        var packageLinesSearchCategory = component.find('packageLinesCategory').get('v.value');
        var packageLinesSearchProductType = component.find('packageLinesProductType').get('v.value');
        var collection = component.find('collection').get('v.value');*/
        
        // TakeOff Lines Search
        var tradeType
        var category
        var locationSearch
        var productType
        /*  var tradeType = component.find('tradeType').get('v.value');
        var category = component.find('category').get('v.value');
        var productType = component.find('productType').get('v.value');
        var locationSearch = component.find('locationSearch').get('v.value');*/
        // SSTL
        // 
        var tradeTypeSSTL = ''
        var categorySSTL = ''
        var productTypeSSTL = ''
        /* var tradeTypeSSTL = component.find('tradeTypeSSTL').get('v.value');
        var categorySSTL = component.find('categorySSTL').get('v.value');
        var productTypeSSTL = component.find('productTypeSSTL').get('v.value');*/
        
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
        var packageLinesSearchTradeType = '';
        var packageLinesSearchCategory = '';
        var packageLinesSearchProductType = '';
        var collection ='';
        
        /* var packageLinesSearchTradeType = component.find('packageLinesTradeType').get('v.value');
        var packageLinesSearchCategory = component.find('packageLinesCategory').get('v.value');
        var packageLinesSearchProductType = component.find('packageLinesProductType').get('v.value');
        var collection = component.find('collection').get('v.value');*/
        
        // TakeOff Lines Search
        var tradeType
        var category
        var locationSearch
        var productType
        /*  var tradeType = component.find('tradeType').get('v.value');
        var category = component.find('category').get('v.value');
        var productType = component.find('productType').get('v.value');
        var locationSearch = component.find('locationSearch').get('v.value');*/
        // SSTL
        // 
        var tradeTypeSSTL = ''
        var categorySSTL = ''
        var productTypeSSTL = ''
        /* var tradeTypeSSTL = component.find('tradeTypeSSTL').get('v.value');
        var categorySSTL = component.find('categorySSTL').get('v.value');
        var productTypeSSTL = component.find('productTypeSSTL').get('v.value');*/
        
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
        var packageLinesSearchTradeType = '';
        var packageLinesSearchCategory = '';
        var packageLinesSearchProductType = '';
        var collection ='';
        
        /* var packageLinesSearchTradeType = component.find('packageLinesTradeType').get('v.value');
        var packageLinesSearchCategory = component.find('packageLinesCategory').get('v.value');
        var packageLinesSearchProductType = component.find('packageLinesProductType').get('v.value');
        var collection = component.find('collection').get('v.value');*/
        
        // TakeOff Lines Search
        var tradeType
        var category
        var locationSearch
        var productType
        /*  var tradeType = component.find('tradeType').get('v.value');
        var category = component.find('category').get('v.value');
        var productType = component.find('productType').get('v.value');
        var locationSearch = component.find('locationSearch').get('v.value');*/
        // SSTL
        // 
        var tradeTypeSSTL = ''
        var categorySSTL = ''
        var productTypeSSTL = ''
        /* var tradeTypeSSTL = component.find('tradeTypeSSTL').get('v.value');
        var categorySSTL = component.find('categorySSTL').get('v.value');
        var productTypeSSTL = component.find('productTypeSSTL').get('v.value');*/
        
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
        var packageLinesSearchTradeType = '';
        var packageLinesSearchCategory = '';
        var packageLinesSearchProductType = '';
        var collection ='';
        
        /* var packageLinesSearchTradeType = component.find('packageLinesTradeType').get('v.value');
        var packageLinesSearchCategory = component.find('packageLinesCategory').get('v.value');
        var packageLinesSearchProductType = component.find('packageLinesProductType').get('v.value');
        var collection = component.find('collection').get('v.value');*/
        
        // TakeOff Lines Search
        var tradeType
        var category
        var locationSearch
        var productType
        /*  var tradeType = component.find('tradeType').get('v.value');
        var category = component.find('category').get('v.value');
        var productType = component.find('productType').get('v.value');
        var locationSearch = component.find('locationSearch').get('v.value');*/
        // SSTL
        // 
        var tradeTypeSSTL = ''
        var categorySSTL = ''
        var productTypeSSTL = ''
        /* var tradeTypeSSTL = component.find('tradeTypeSSTL').get('v.value');
        var categorySSTL = component.find('categorySSTL').get('v.value');
        var productTypeSSTL = component.find('productTypeSSTL').get('v.value');*/
        
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
            var packageLinesSearchTradeType = '';
            var packageLinesSearchCategory = '';
            var packageLinesSearchProductType = '';
            var collection ='';
            
            /* var packageLinesSearchTradeType = component.find('packageLinesTradeType').get('v.value');
        var packageLinesSearchCategory = component.find('packageLinesCategory').get('v.value');
        var packageLinesSearchProductType = component.find('packageLinesProductType').get('v.value');
        var collection = component.find('collection').get('v.value');*/
            
            // TakeOff Lines Search
            var tradeType
            var category
            var locationSearch
            var productType
            /*  var tradeType = component.find('tradeType').get('v.value');
        var category = component.find('category').get('v.value');
        var productType = component.find('productType').get('v.value');
        var locationSearch = component.find('locationSearch').get('v.value');*/
            // SSTL
            // 
            var tradeTypeSSTL = ''
            var categorySSTL = ''
            var productTypeSSTL = ''
            /* var tradeTypeSSTL = component.find('tradeTypeSSTL').get('v.value');
        var categorySSTL = component.find('categorySSTL').get('v.value');
        var productTypeSSTL = component.find('productTypeSSTL').get('v.value');*/
        
        
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
        debugger;
        var productsList = component.get("v.productsList");
        var groupIndex = event.getSource().get("v.name"); 
        var isSelected = event.getSource().get('v.checked');
        for(var i in productsList[groupIndex].groupedRecords){
            productsList[groupIndex].groupedRecords[i].isSelected = isSelected ? 
                true : false;
        }
        component.set("v.productsList",productsList);
        
        
        debugger;
        var checkStatus = event.getSource().get("v.checked");
        var rfqRecordList = JSON.parse(JSON.stringify(component.get("v.productsList")));
        var getAllId = component.find("checkRFQ");
        var groupIndex = event.getSource().get("v.name")
        
        var recData = rfqRecordList[groupIndex]['groupedRecords']
        var recData1 = rfqRecordList[groupIndex]['groupedRecordsTmp']
        //var indexVal = component.get("v.selectedIndexValues")
        var indexVal = [];
        var recordIds =  component.get("v.selectedProdIds");
        if(checkStatus){
            if(rfqRecordList.length){
                
                for (var i = 0; i < recData.length; i++) {
                    //   component.find("checkRFQ")[i].set("v.checked", true);
                    var Id = recData[i].Id;
                    recData[i]['isSelected'] = true;
                    rfqRecordList[groupIndex]['isSelected'] = true;
                    
                    if(recordIds.indexOf(Id) == -1){
                        recordIds.push(Id)
                    }
                    recData1[i]['isSelected'] = true
                    /* var singleTempRec = recData1[i];
                    for(var j =0 ;j<singleTempRec.length;j++){
                        recData1[i]['isSelected'] = true
                    }*/
                }
                
                
                rfqRecordList[groupIndex]['groupedRecordsTmp'] = recData1
                rfqRecordList[groupIndex]['groupedRecords'] = recData
                component.set("v.productsList",rfqRecordList)
                component.set("v.productIdList",recordIds);
            }
        }else{
           /*  var empty = [];
            component.set("v.selectedProdIds",empty);*/
            if(rfqRecordList.length){
                
                for (var i = 0; i < recData.length; i++) {
                    //   component.find("checkRFQ")[i].set("v.checked", true);
                    var Id = recData[i].Id;
                    recData[i]['isSelected'] = false;
                    rfqRecordList[groupIndex]['isSelected'] = false;
                    if(recordIds.indexOf(Id) == -1){
                        recordIds.splice(Id)
                    }
                    var singleTempRec = recData1[i];
                    for(var j =0 ;j<singleTempRec.length;j++){
                        recData1[i][j]['isSelected'] = false
                    }
                }
                rfqRecordList[groupIndex]['groupedRecordsTmp'] = recData1
                rfqRecordList[groupIndex]['groupedRecords'] = recData
                component.set("v.productsList",rfqRecordList)
                component.set("v.productIdList",recordIds);
            }
            
        }
          console.log(recordIds); 
          
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
    
    redirect :  function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            var recId = component.get("v.projectSelectionTakeOffRec").Id
            workspaceAPI.closeTab({tabId: focusedTabId}).then(function(response) {
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": component.get("v.projectSelectionTakeOffRec").Id,
                    "slideDevName": "related"
                });
                navEvt.fire();
            })
        })
        .catch(function(error) {
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": component.get("v.projectSelectionTakeOffRec").Id,
                "slideDevName": "related"
            });
            navEvt.fire();
            console.log(error);
        });
        
    },
    
    viewRecord : function(component, event, helper) {
        var recId = event.currentTarget.dataset.name //event.getSource().get("v.name");
        
        
        $A.get("e.force:navigateToSObject").setParams({
            "recordId": recId,
            "slideDevName": "related"
        }).fire();
    },
    
    
    CreateNewTakeOfLine : function(component, event, helper) {
        debugger;
        component.set("v.isNewTakeoffLine",true);
        
        
        var action = component.get("c.getTakeoffId");
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                
                var result = response.getReturnValue();
                
                
                if(result.Id){
                    component.set("v.isNewTakeoffLine",true);
                    component.set("v.parentRecordId", result.Id);
                    
                    component.set("v.selectedprojecttakeoff", response.getReturnValue());
                    component.find('projtakeoffid').set("v.value", result.Id);
                    component.set("v.TakeOffRecordId", result.Id);
                    
                }else{
                    component.set("v.isNewTakeoffLine",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : "Error!",
                        message : 'There is no Takeoff for this BOM',
                        type: 'error',
                        duration: '1000',
                        key: 'info_alt',
                        mode: 'pester'
                    });
                    toastEvent.fire(); 
                }
                
            } 
        });
        $A.enqueueAction(action);
        
        
        component.find('quantityId').set("v.value", 1);
        
        helper.fetchpricebooks(component, event, helper);
        
    },
    
    
    handleComponentEvent: function (component, event, helper) {
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        // component.set("v.newprojecttakeoffline.buildertek__Item_Name__c",selectedAccountGetFromEvent.Name);
        component.set("v.newprojecttakeoffline.buildertek__Product__c", selectedAccountGetFromEvent.Id);
        component.set("v.productId", selectedAccountGetFromEvent.Id);
        component.set("v.productName", selectedAccountGetFromEvent.Name);
        helper.getProductDetails(component, event, helper);
    },
    
    handleComponentEvents: function (component, event, helper) {
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        // component.set("v.newprojecttakeoffline.buildertek__Item_Name__c",selectedAccountGetFromEvent.Name);
        component.set("v.newprojecttakeoffline.buildertek__Product__c", selectedAccountGetFromEvent.Id);
        component.set("v.productId", selectedAccountGetFromEvent.Id);
        component.set("v.productName", selectedAccountGetFromEvent.Name);
        helper.getProductDetails(component, event, helper);
    },
    
    
    
    save: function (component, event, helper) {
        
        var selectedTradeType = component.get("v.selectedTradeType");
        var selTradeType;
        if (selectedTradeType != undefined) {
            selTradeType = selectedTradeType.Id;
        } else {
            selTradeType = null;
        }
        
        var selectedprojecttakeoff = component.get("v.selectedprojecttakeoff");
        var parentRecordId = component.get("v.parentRecordId");
        var selectedPToff;
        if (parentRecordId != undefined) {
            selectedPToff = component.get("v.parentRecordId");
        } else {
            if (selectedprojecttakeoff != undefined) {
                selectedPToff = selectedprojecttakeoff.Id;
            } else {
                selectedPToff = null;
            }
        }
        
        
        
        component.set("v.newprojecttakeoffline.buildertek__Trade_Type__c", selTradeType);
        
        //component.set("v.newprojecttakeoffline.buildertek__Project_Takeoff__c", selectedPToff);
        var ProjtakeoffLineToInsert = JSON.stringify(component.get("v.newprojecttakeoffline"));
        if (selectedPToff != undefined) {
            component.set("v.Spinner", true);
            var action = component.get("c.savePToffline");
            action.setParams({
                takeoffLines: ProjtakeoffLineToInsert,
                PtoffId: selectedPToff
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.Spinner", false);
                    var url = location.href;
                    var baseURL = url.substring(0, url.indexOf('/', 14));
                    var result = response.getReturnValue();
                    $A.get("e.force:closeQuickAction").fire();
                    component.set("v.isNewTakeoffLine",false);
                    
                    $A.get('e.force:refreshView').fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        message: ' Takeoff Line Created Succussfully',
                        messageTemplate: "Takeoff Line {0} was created",
                        /*   messageTemplateData: [{
                           url: baseURL+'/lightning/r/buildertek__Project_Takeoff_Lines__c/'+escape(result.Id)+'/view',
                           label: result.Name,
                           }],*/
                        type: 'success',
                        duration: '10000',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    
                    
                }
            });
            $A.enqueueAction(action);
        } else {
            var pillTarget = component.find("errorId");
            $A.util.addClass(pillTarget, 'showErrorMessage');
        }
        
    },
    
    
    ImportPackages : function(component, event, helper) {
        debugger;
        component.set("v.isImportPackage",true);
        component.set("v.Spinner", true);
        helper.getPackageRecords(component, event, helper);
    },
    
    handleCheck: function (component, event, helper) {
        var checkbox = event.getSource();
        var packageTakeOffList = component.get("v.packageTakeOffList");
        for (var i = 0; i < packageTakeOffList.length; i++) {
            if (packageTakeOffList[i].packageRecord != null) {
                if (packageTakeOffList[i].packageRecord.Id == checkbox.get("v.text") && packageTakeOffList[i].packageTakeOffCheck == false) {
                    packageTakeOffList[i].packageTakeOffCheck = true;
                } else if (packageTakeOffList[i].packageRecord.Id == checkbox.get("v.text") && packageTakeOffList[i].packageTakeOffCheck == true) {
                    packageTakeOffList[i].packageTakeOffCheck = false;
                }
            }
        }
    },
    
    selectAll: function (component, event, helper) {
        var selectedHeaderCheck = event.getSource().get("v.value");
        var packageTakeOffList = component.get("v.packageTakeOffList");
        var getAllId = component.find("checkContractor");
        if (packageTakeOffList != null) {
            if (packageTakeOffList.length > 1) {
                if (!Array.isArray(getAllId)) {
                    if (selectedHeaderCheck == true) {
                        component.find("checkContractor").set("v.value", true);
                    } else {
                        component.find("checkContractor").set("v.value", false);
                    }
                } else {
                    if (selectedHeaderCheck == true) {
                        for (var i = 0; i < getAllId.length; i++) {
                            component.find("checkContractor")[i].set("v.value", true);
                            var checkbox = component.find("checkContractor")[i].get("v.text");
                            packageTakeOffList[i].packageTakeOffCheck = true;
                        }
                    } else {
                        for (var i = 0; i < getAllId.length; i++) {
                            component.find("checkContractor")[i].set("v.value", false);
                            var checkbox = component.find("checkContractor")[i].get("v.text");
                            var packageTakeOffList = component.get("v.packageTakeOffList");
                            packageTakeOffList[i].packageTakeOffCheck = false;
                        }
                    }
                }
            } else {
                var i = 0;
                if (selectedHeaderCheck == true) {
                    component.find("checkContractor").set("v.value", true);
                    var checkbox = component.find("checkContractor").get("v.text");
                    packageTakeOffList[i].packageTakeOffCheck = true;
                } else {
                    component.find("checkContractor").set("v.value", false);
                    var checkbox = component.find("checkContractor").get("v.text");
                    var packageTakeOffList = component.get("v.packageTakeOffList");
                    packageTakeOffList[i].packageTakeOffCheck = false;
                }
            }
        }
        
    },
    
    
    importTakeoffLinesFromPackage : function(component, event, helper) {
        debugger;
        var takeOffList = component.get("v.packageTakeOffList");
        var takeOffLinesIds = [];
        for (var i = 0; i < takeOffList.length; i++) {
            if (takeOffList[i].packageTakeOffCheck == true) {
                if (takeOffList[i].packageRecord != null) {
                    takeOffLinesIds.push(takeOffList[i].packageRecord.Id);
                }
            }
        }
        if (takeOffLinesIds.length > 0) {
            component.set('v.isModalOpen', true);
            component.set("v.Spinner", false);
            component.set('v.takeOffLinesIds', takeOffLinesIds);
            debugger;
            
            var action = component.get("c.getTakeoffId");
            action.setParams({
                "recordId": component.get("v.recordId")
            });
            action.setCallback(this, function (response) {
                if (response.getState() == "SUCCESS") {
                    var result = response.getReturnValue();
                    component.set("v.parentRecordId", result.Id);
                    helper.importTOffLinesPackage(component, event, helper, takeOffLinesIds);
                    
                } 
            });
            $A.enqueueAction(action);
            
            
        }
    },
    closeModel: function (component, event, helper) {
        component.set('v.isReplaceAll', false);
        component.set("v.isNewTakeoffLine",false);
        component.set("v.isImportPackage",false);
    },
    
    deletePopUp : function(component, event, helper){
        var checkLines =  component.get("v.selectedProdIds"); 
        if(checkLines.length >= 1){
            component.set("v.isDeletePopUp", true);
            
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'ERROR',
                message: 'Please select Products',
                duration: "5000",
                key: "info_alt",
                type: "error",
            });
            toastEvent.fire();   
        }
    },
    
    cancelDelete : function(component, event, helper){
        component.set("v.isDeletePopUp", false);
    },
    
    deleteSelectedRightLines : function(component, event, helper){
        debugger;
        
        var checkLines =  component.get("v.selectedProdIds");
        if(checkLines.length >= 1){
            var action = component.get("c.deleteSelectedProducts");
            action.setParams({
                "prodIds": checkLines          
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state == "SUCCESS") {
                    
                    var result = response.getReturnValue();
                    
                    if(result == 'Success'){
                        component.set("v.isDeletePopUp", false);
                        
                        $A.get('e.force:refreshView').fire();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Success',
                            message: 'The Selected Products are Successfully Deleted',
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'success',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                    }
                    
                    
                }
                
            });
            $A.enqueueAction(action);
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'ERROR',
                message: 'Please select Products',
                duration: "5000",
                key: "info_alt",
                type: "error",
            });
            toastEvent.fire();   
        }
    },    
    
    
    selectRfq: function (component, event, helper) {
        var checkbox = event.getSource();
        var takeOffLinesList = component.get('v.selectionSheetTakeOffLines');
        console.log('takeOffLinesList', takeOffLinesList);
        
        
        var groupIndex = event.getSource().get("v.name").split('-')[0];
        var recordIndex = event.getSource().get("v.name").split('-')[1];
        console.log('recordIndex', recordIndex);
        console.log('groupIndex', groupIndex);
        console.log('groupIndex', groupIndex);
        var recId = takeOffLinesList[groupIndex].groupedRecords[recordIndex].Id
        //component.set("v.selectedIndexValues",indexVal);
        var selectedRfqIds = component.get("v.selectedProdIds");
        var getAllId = component.find("checkRFQ");
        if(checkbox.get("v.checked")){
            if(selectedRfqIds.indexOf(recId) == -1){
                selectedRfqIds.push(recId);
            }
            
        }else{
            /*if(component.find("headCheckRFQ").get("v.checked")){
                component.find("headCheckRFQ").set("v.checked",false);
            }*/
            if(selectedRfqIds.indexOf(recId) > -1){
                var index = selectedRfqIds.indexOf(recId);
                selectedRfqIds.splice(index,1);
                
            }
        }
        console.log(selectedRfqIds);
        component.set("v.selectedProdIds",selectedRfqIds);
    },
    
    
    selectAllRfq : function (component, event, helper) {
        debugger;
        var checkStatus = event.getSource().get("v.checked");
        var rfqRecordList = JSON.parse(JSON.stringify(component.get("v.selectionSheetTakeOffLines")));
        var getAllId = component.find("checkRFQ");
        var groupIndex = event.getSource().get("v.name")
        
        var recData = rfqRecordList[groupIndex]['groupedRecords']
        var recData1 = rfqRecordList[groupIndex]['groupedRecordsTmp']
        //var indexVal = component.get("v.selectedIndexValues")
        var indexVal = [];
        var recordIds =  component.get("v.selectedProdIds");
        if(checkStatus){
            if(rfqRecordList.length){
                
                for (var i = 0; i < recData.length; i++) {
                    //   component.find("checkRFQ")[i].set("v.checked", true);
                    var Id = recData[i].Id;
                    recData[i]['isSelected'] = true;
                    rfqRecordList[groupIndex]['isSelected'] = true;
                    if(recordIds.indexOf(Id) == -1){
                        recordIds.push(Id)
                    }
                    var singleTempRec = recData1[i];
                    for(var j =0 ;j<singleTempRec.length;j++){
                        recData1[i][j]['isSelected'] = true
                    }
                }
                
                rfqRecordList[groupIndex]['groupedRecordsTmp'] = recData1
                rfqRecordList[groupIndex]['groupedRecords'] = recData
                component.set("v.selectionSheetTakeOffLines",rfqRecordList)
                component.set("v.selectedProdIds",recordIds);
            }
        }else{
             var empty = [];
            component.set("v.selectedProdIds",empty);
            if(rfqRecordList.length){
                
                for (var i = 0; i < recData.length; i++) {
                    //   component.find("checkRFQ")[i].set("v.checked", true);
                    var Id = recData[i].Id;
                    recData[i]['isSelected'] = false;
                    rfqRecordList[groupIndex]['isSelected'] = false;
                    if(recordIds.indexOf(Id) > -1){
                        recordIds.splice(recordIds.indexOf(Id),1)
                    }
                    var singleTempRec = recData1[i];
                    for(var j =0 ;j<singleTempRec.length;j++){
                        recData1[i][j]['isSelected'] = false
                    }
                }
                rfqRecordList[groupIndex]['groupedRecordsTmp'] = recData1
                rfqRecordList[groupIndex]['groupedRecords'] = recData
                component.set("v.selectionSheetTakeOffLines",rfqRecordList)
                component.set("v.selectedProdIds",recordIds);
            }
            
        }
        console.log(recordIds);
    },
    
    editRecord : function(component, event, helper) {
        var recId = event.currentTarget.dataset.name //event.getSource().get("v.name");
        var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            "recordId":recId
        });
        editRecordEvent.fire();
        
        component.addEventHandler("force:recordChange", component.getReference("c.refreshComp"));
    },
    
    refreshComp : function(component, event, helper) {
        component.removeEventHandler('force:recordChange',component.getReference("c.refreshComp"))
        
        $A.get('e.force:refreshView').fire();
        
    },



    
})