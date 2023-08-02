({
    getProjectTakeOffRec: function (component, event, helper) {
        var action = component.get("c.getProjectSelectionSheetTakeOffRec");
        action.setParams({
            recordId: component.get('v.recordId'),
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result != null && result != undefined) {
                    component.set('v.projectSelectionTakeOffRec', result.projectSelectionSheetTakeOffRec);
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
            SSTLPageSize: SSTLPageSize,
            selectPriceBook : component.get("v.pricebookName")
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
                       	component.set('v.productslength',result.productTotalRecords);
                        component.set('v.productsList', helper.groupRecords1(result.productsRecord,component,component.get("v.productselectedFields")));
                    }
                    if (result.takeOffLinesList != undefined) { 
                        helper.setTakeOffLinesRecords(component, pageNumber, pageSize, result.takeOffLinesList.length, result.totalRecords);
                        component.set('v.takeofflineslength',result.totalRecords);
                        //component.set('v.takeOffLinesList', helper.groupRecords(result.takeOffLinesList));
                        component.set('v.takeOffLinesList', helper.groupRecords1(result.takeOffLinesList,component,component.get("v.selectedFields")));
                      
                    }
                    if (result.selectionSheetTakeOffLines != undefined) {
                        debugger;
                        console.log('result.selectionSheetTakeOffLines::::',result.selectionSheetTakeOffLines);
                        console.log('result.SSTLTotalRecords::::',result.SSTLTotalRecords);
                        result.selectionSheetTakeOffLines != undefined ? helper.setSSTLRecords(component, SSTLPageNumber, SSTLPageSize, result.selectionSheetTakeOffLines.length, result.SSTLTotalRecords) : '';
                        component.set('v.sstlines',result.SSTLTotalRecords);
                       // component.set('v.selectionSheetTakeOffLines', helper.groupRecords(result.selectionSheetTakeOffLines));
                        component.set('v.selectionSheetTakeOffLines', helper.groupRecords1(result.selectionSheetTakeOffLines,component,component.get("v.bomLineselectedFields")));
                    }
                }
                component.set("v.isSpinner", false);
                var getFieldMapAction =  component.get("c.getFiledNameAndApi")
                component.set("v.isSpinner",true)
                getFieldMapAction.setCallback(this, function (response) {
                    debugger;
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        component.set("v.isSpinner",true)
                        var result = response.getReturnValue();
                        component.set("v.fieldNameApiMap",result)
                        var neList = []
                        neList = Object.values(result)
                        console.log(neList)
                        component.set("v.fieldNameApiList",neList)
                        component.set("v.isSpinner",false)
                    }
                })
                $A.enqueueAction(getFieldMapAction);
                
                //product
                var getProductFieldMapAction =  component.get("c.getProductFiledNameAndApi")
                component.set("v.isSpinner",true)
                getProductFieldMapAction.setCallback(this, function (response) {
                    debugger;
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        component.set("v.isSpinner",true)
                        var result = response.getReturnValue();
                        component.set("v.fieldProductNameApiMap",result)
                        var neList = []
                        neList = Object.values(result)
                        console.log(neList)
                        component.set("v.fieldProductNameApiList",neList)
                        component.set("v.isSpinner",false)
                    }
                })
                $A.enqueueAction(getProductFieldMapAction);
                
                var getBOMLineFieldMapAction =  component.get("c.getBOMLineFiledNameAndApi")
                component.set("v.isSpinner",true)
                getBOMLineFieldMapAction.setCallback(this, function (response) {
                    debugger;
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        component.set("v.isSpinner",true)
                        var result = response.getReturnValue();
                        component.set("v.fieldBOMLineNameApiMap",result)
                        var neList = []
                        neList = Object.values(result)
                        console.log(neList)
                        component.set("v.fieldBOMLineNameApiList",neList)
                        component.set("v.isSpinner",false)
                    }
                })
                $A.enqueueAction(getBOMLineFieldMapAction);
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
                       // component.set('v.takeOffLinesList', helper.groupRecords(result.takeOffLinesList));
                       // component.set('v.takeOffLinesList', helper.groupRecords1(result.takeOffLinesList,component));
                       component.set('v.takeOffLinesList', helper.groupRecords1(result.takeOffLinesList,component,component.get("v.selectedFields")));
                        
                    }
                    if (result.selectionSheetTakeOffLines != undefined) {
                        result.selectionSheetTakeOffLines != undefined ? helper.setSSTLRecords(component, SSTLPageNumber, SSTLPageSize, result.selectionSheetTakeOffLines.length, result.SSTLTotalRecords) : '';
                       // component.set('v.selectionSheetTakeOffLines', helper.groupRecords(result.selectionSheetTakeOffLines));
                        component.set('v.selectionSheetTakeOffLines', helper.groupRecords1(result.selectionSheetTakeOffLines,component,component.get("v.bomLineselectedFields")));
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
        debugger;
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

    
    groupRecords1: function (data,component,selectedFields) {
        //alert(component.get("v.selectedFields"));
       console.log('selectedFields>>>>'+selectedFields);
        var selectedFields = selectedFields;
        var selectedFieldsArray = selectedFields.split(",");         
         debugger;
         var listOfRecords = [];
         let recordMap = new Map();
        console.log('data>>>>',data);
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
             //alert(i);
             var obj = {};
             obj.groupId = result[i][0].split('(#*&)')[0];
             obj.groupName = result[i][0].split('(#*&)')[1];
             obj.groupedRecords = result[i][1];
             obj.isSelected = false; 
             //alert( result[i][0].split('(#*&)')[1]);
             //alert(obj.groupName);
             
             var mainList = [];            
             //alert('arrkeys '+i+arrkeys);
             for (var j in obj.groupedRecords) {
                 //alert(obj.groupedRecords[j].Name);
                 obj.groupedRecords[j].isSelected = false;
                 
                 let newList = [];                 
                 for(var k=0; k<selectedFieldsArray.length; k++){  
                     var AllRowListMap = new Map(Object.entries(obj.groupedRecords[j]));
                     var keyId  = Array.from(AllRowListMap.keys())[0]; 
                     var mapKey =  selectedFieldsArray[k]; 
                      
                     var strrecord = JSON.stringify(Object.entries(obj.groupedRecords[j]));                     
                     let indexObj = {};
                     if(strrecord.indexOf(mapKey)>0){
                         if(mapKey.indexOf('__c')>0){
                             indexObj.Key = mapKey;                                
                             indexObj.Value = AllRowListMap.get(mapKey); 
                             indexObj.Id  = AllRowListMap.get(keyId); 
                             indexObj.isSelected = false;
                         }
                         
                         if(mapKey.indexOf('__r')>0){
                             var AllRowListMap2 = new Map(Object.entries(AllRowListMap.get(mapKey)));
                             var mapKey2 = Array.from(AllRowListMap2.keys())[0];
                             indexObj.Key = mapKey;                                
                             indexObj.Value = AllRowListMap2.get(mapKey2); 
                             indexObj.Id  = AllRowListMap.get(keyId); 
                             indexObj.isSelected = false;
                         }
                         if(mapKey=='Name'){
                             indexObj.Key = mapKey;                                
                             indexObj.Value = AllRowListMap.get(mapKey);
                             indexObj.Id  = AllRowListMap.get(keyId); 
                             indexObj.isSelected = false;
                         }
                     }else{
                         indexObj.Key = mapKey;                                
                         indexObj.Value = '';
                         indexObj.Id  = AllRowListMap.get(keyId);   
                         indexObj.isSelected = false;
                     }  
                     
                     newList.push(indexObj);  
                    
                 }
                newList.push({'isSelected':false})
                 mainList.push(newList); 
                 
             }
             
             obj.groupedRecordsTmp = mainList;
             
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
        //TakeOff Lines Search dynamic filter option
        var optionlist = component.get("v.fieldNameApiList")
        var productOptionlist = component.get("v.fieldProductNameApiList")
        var bomLineOptionlist = component.get("v.fieldBOMLineNameApiList")
         var filter = '';
        var filter1 = '';
        var filter2 = '';
        
        //Takeoff
        for(var i=0;i<optionlist.length;i++){
            if(optionlist[i].Value){
                var fieldApiName = optionlist[i]['Name']
                if(optionlist[i].Type == 'REFERENCE'){
                     
                    var fieldApiName1 = fieldApiName.split('__c')[0];
                    var value = '\'%' + optionlist[i].Value + '%\'';
                    filter += ' AND '+fieldApiName1+'__r.Name LIKE '+value;
               
                }else if(optionlist[i].Type == 'STRING' ||optionlist[i].Type == 'PICKLIST'){
                    var STRvalue = '\'%'  + optionlist[i].Value + '%\'';
                    filter += ' AND '+fieldApiName+' LIKE '+STRvalue;
                }else if(optionlist[i].Type == 'DOUBLE'){
                    var value1 =  JSON.parse(optionlist[i].Value);
                    filter += ' AND '+fieldApiName+' ='+value1;
                }else if(optionlist[i].Type == 'DATETIME'){
                    var dateVal = optionlist[i].Value// new Date(optionlist[i].Value);
                    filter += ' AND '+fieldApiName+' >='+dateVal;
                } else if(optionlist[i].Type == 'DATE'){
                    var dateVal = optionlist[i].Value// new Date(optionlist[i].Value);
                    filter += ' AND '+fieldApiName+' >='+dateVal;
                }
                console.log(filter);
            }
        }
        
        
        for(var i=0;i<productOptionlist.length;i++){
            if(productOptionlist[i].Value){
                var fieldApiName = productOptionlist[i]['Name']
                if(productOptionlist[i].Type == 'REFERENCE'){
                     
                    var fieldApiName1 = fieldApiName.split('__c')[0];
                    var value = '\'%' + productOptionlist[i].Value + '%\'';
                    filter1 += ' AND '+fieldApiName1+'__r.Name LIKE '+value;
               
                }else if(productOptionlist[i].Type == 'STRING' ||productOptionlist[i].Type == 'PICKLIST'){
                    var STRvalue = '\'%'  + productOptionlist[i].Value + '%\'';
                    filter1 += ' AND '+fieldApiName+' LIKE '+STRvalue;
                }else if(productOptionlist[i].Type == 'DOUBLE'){
                    var value1 =  JSON.parse(productOptionlist[i].Value);
                    filter1 += ' AND '+fieldApiName+' ='+value1;
                }else if(productOptionlist[i].Type == 'DATETIME'){
                    var dateVal = productOptionlist[i].Value// new Date(optionlist[i].Value);
                    filter1 += ' AND '+fieldApiName+' >='+dateVal;
                } else if(productOptionlist[i].Type == 'DATE'){
                    var dateVal = productOptionlist[i].Value// new Date(optionlist[i].Value);
                    filter1 += ' AND '+fieldApiName+' >='+dateVal;
                }
                console.log(filter1);
            }
        }
        
        
         for(var i=0;i<bomLineOptionlist.length;i++){
            if(bomLineOptionlist[i].Value){
                var fieldApiName = bomLineOptionlist[i]['Name']
                if(bomLineOptionlist[i].Type == 'REFERENCE'){
                     
                    var fieldApiName1 = fieldApiName.split('__c')[0];
                    var value = '\'%' + bomLineOptionlist[i].Value + '%\'';
                    filter2 += ' AND '+fieldApiName1+'__r.Name LIKE '+value;
               
                }else if(bomLineOptionlist[i].Type == 'STRING' ||bomLineOptionlist[i].Type == 'PICKLIST'){
                    var STRvalue = '\'%'  + bomLineOptionlist[i].Value + '%\'';
                    filter2 += ' AND '+fieldApiName+' LIKE '+STRvalue;
                }else if(bomLineOptionlist[i].Type == 'DOUBLE'){
                    var value1 =  JSON.parse(bomLineOptionlist[i].Value);
                    filter2 += ' AND '+fieldApiName+' ='+value1;
                }else if(bomLineOptionlist[i].Type == 'DATETIME'){
                    var dateVal = bomLineOptionlist[i].Value// new Date(optionlist[i].Value);
                    filter2 += ' AND '+fieldApiName+' >='+dateVal;
                } else if(bomLineOptionlist[i].Type == 'DATE'){
                    var dateVal = bomLineOptionlist[i].Value// new Date(optionlist[i].Value);
                    filter2 += ' AND '+fieldApiName+' >='+dateVal;
                }
                console.log(filter1);
            }
        }
        
        
      
        
        
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
            /*packageLinesSearchTradeType: packageLinesSearchTradeType,
            packageLinesSearchCategory: packageLinesSearchCategory,
            packageLinesSearchProductType: packageLinesSearchProductType,
            collection: collection,
            tradeType: tradeType,
            category: category,
            productType: productType,
            locationSearch: locationSearch,
            tradeTypeSSTL: tradeTypeSSTL,
            categorySSTL: categorySSTL,
            productTypeSSTL: productTypeSSTL,*/
            filter1 : filter,
            filter2 : filter1,
            filter3 : filter2,
           /* filterProductOptionList : JSON.stringify(filterProductOption),
            filterOptionList: JSON.stringify(filterOption),
            filterBOMLineOption :JSON.stringify(filterBOMLineOption),  */
            productIdList: productIdList,
            takeOffLineList: takeOffLineList,
            projectId: component.get('v.projectSelectionTakeOffRec').buildertek__Project__c,
            selectPriceBook:  component.get("v.pricebookName"),
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
                   // component.set('v.selectionSheetTakeOffLines', helper.groupRecords(result.selectionSheetTakeOffLines));
                   component.set('v.selectionSheetTakeOffLines', helper.groupRecords1(result.selectionSheetTakeOffLines,component,component.get("v.bomLineselectedFields")));
                    
                }
                helper.showToast(component, event, helper, 'Success!', 'Selection Sheet TakeOff Lines created Successfully!!', 'success');
                component.set("v.isSpinner", false);
                $A.get('e.force:refreshView').fire();

            } else {
                helper.showToast(component, event, helper, 'Error!', 'Something went wrong!', 'error');
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
    },

    //In Use Search Result
    getSearchRecords: function (component, event, helper, productPageNumber, productPageSize, pageNumber, pageSize, SSTLPageNumber, SSTLPageSize, packageLinesSearchTradeType, packageLinesSearchCategory, packageLinesSearchProductType, collection, buildPhase, tradeType, category, productType, locationSearch, tradeTypeSSTL, categorySSTL, productTypeSSTL) {
		
        //TakeOff Lines Search dynamic filter option
        var optionlist = component.get("v.fieldNameApiList")
        /*var filterOption = []
        for(var i=0;i<optionlist.length;i++){
            var filterOptionObj = {}
            filterOptionObj['Name'] = optionlist[i]['Key']
            filterOptionObj['Value'] = optionlist[i].Value ? optionlist[i].Value:''  //''+component.find( optionlist[i]['Name']).get('v.value')
            filterOptionObj['apiName'] = optionlist[i]['Name'] //component.get("v.fieldNameApiMap")['Build Phase']['Name']
       		filterOptionObj['Type'] = optionlist[i]['Type']
            filterOption.push(filterOptionObj)
        }*/
        
        var productOptionlist = component.get("v.fieldProductNameApiList")
        /*var filterProductOption = []
        for(var i=0;i<productOptionlist.length;i++){
            var filterProdOptionObj = {}
            filterProdOptionObj['Name'] = productOptionlist[i]['Key']
            filterProdOptionObj['Value'] = productOptionlist[i].Value ? productOptionlist[i].Value:''  //''+component.find( optionlist[i]['Name']).get('v.value')
            filterProdOptionObj['apiName'] = productOptionlist[i]['Name'] //component.get("v.fieldNameApiMap")['Build Phase']['Name']
       		filterProdOptionObj['Type'] = productOptionlist[i]['Type']
            filterProductOption.push(filterProdOptionObj)
        }*/
        
        var bomLineOptionlist = component.get("v.fieldBOMLineNameApiList")
        /*var filterBOMLineOption = []
        for(var i=0;i<productOptionlist.length;i++){
            var filterBOMLineOptionObj = {}
            filterBOMLineOptionObj['Name'] = bomLineOptionlist[i]['Key']
            filterBOMLineOptionObj['Value'] = bomLineOptionlist[i].Value ? bomLineOptionlist[i].Value:''  //''+component.find( optionlist[i]['Name']).get('v.value')
            filterBOMLineOptionObj['apiName'] = bomLineOptionlist[i]['Name'] //component.get("v.fieldNameApiMap")['Build Phase']['Name']
            filterBOMLineOptionObj['Type'] = bomLineOptionlist[i]['Type']
            filterBOMLineOption.push(filterBOMLineOptionObj)
        }*/
        
        var filter = '';
        var filter1 = '';
        var filter2 = '';
        
        //Takeoff
        for(var i=0;i<optionlist.length;i++){
            if(optionlist[i].Value){
                var fieldApiName = optionlist[i]['Name']
                if(optionlist[i].Type == 'REFERENCE'){
                     
                    var fieldApiName1 = fieldApiName.split('__c')[0];
                    var value = '\'%' + optionlist[i].Value + '%\'';
                    filter += ' AND '+fieldApiName1+'__r.Name LIKE '+value;
               
                }else if(optionlist[i].Type == 'STRING' ||optionlist[i].Type == 'PICKLIST'){
                    var STRvalue = '\'%'  + optionlist[i].Value + '%\'';
                    filter += ' AND '+fieldApiName+' LIKE '+STRvalue;
                }else if(optionlist[i].Type == 'DOUBLE'){
                    var value1 =  JSON.parse(optionlist[i].Value);
                    filter += ' AND '+fieldApiName+' ='+value1;
                }else if(optionlist[i].Type == 'DATETIME'){
                    var dateVal = optionlist[i].Value// new Date(optionlist[i].Value);
                    filter += ' AND '+fieldApiName+' >='+dateVal;
                } else if(optionlist[i].Type == 'DATE'){
                    var dateVal = optionlist[i].Value// new Date(optionlist[i].Value);
                    filter += ' AND '+fieldApiName+' >='+dateVal;
                }
                console.log(filter);
            }
        }
        
        
         for(var i=0;i<productOptionlist.length;i++){
            if(productOptionlist[i].Value){
                var fieldApiName = productOptionlist[i]['Name']
                if(productOptionlist[i].Type == 'REFERENCE'){
                     
                    var fieldApiName1 = fieldApiName.split('__c')[0];
                    var value = '\'%' + productOptionlist[i].Value + '%\'';
                    filter1 += ' AND '+fieldApiName1+'__r.Name LIKE '+value;
               
                }else if(productOptionlist[i].Type == 'STRING' ||productOptionlist[i].Type == 'PICKLIST'){
                    var STRvalue = '\'%'  + productOptionlist[i].Value + '%\'';
                    filter1 += ' AND '+fieldApiName+' LIKE '+STRvalue;
                }else if(productOptionlist[i].Type == 'DOUBLE'){
                    var value1 =  JSON.parse(productOptionlist[i].Value);
                    filter1 += ' AND '+fieldApiName+' ='+value1;
                }else if(productOptionlist[i].Type == 'DATETIME'){
                    var dateVal = productOptionlist[i].Value// new Date(optionlist[i].Value);
                    filter1 += ' AND '+fieldApiName+' >='+dateVal;
                } else if(productOptionlist[i].Type == 'DATE'){
                    var dateVal = productOptionlist[i].Value// new Date(optionlist[i].Value);
                    filter1 += ' AND '+fieldApiName+' >='+dateVal;
                }
                console.log(filter1);
            }
        }
        
       
        
         for(var i=0;i<bomLineOptionlist.length;i++){
            if(bomLineOptionlist[i].Value){
                var fieldApiName = bomLineOptionlist[i]['Name']
                if(bomLineOptionlist[i].Type == 'REFERENCE'){
                     
                    var fieldApiName1 = fieldApiName.split('__c')[0];
                    var value = '\'%' + bomLineOptionlist[i].Value + '%\'';
                    filter2 += ' AND '+fieldApiName1+'__r.Name LIKE '+value;
               
                }else if(bomLineOptionlist[i].Type == 'STRING' ||bomLineOptionlist[i].Type == 'PICKLIST'){
                    var STRvalue = '\'%'  + bomLineOptionlist[i].Value + '%\'';
                    filter2 += ' AND '+fieldApiName+' LIKE '+STRvalue;
                }else if(bomLineOptionlist[i].Type == 'DOUBLE'){
                    var value1 =  JSON.parse(bomLineOptionlist[i].Value);
                    filter2 += ' AND '+fieldApiName+' ='+value1;
                }else if(bomLineOptionlist[i].Type == 'DATETIME'){
                    var dateVal = bomLineOptionlist[i].Value// new Date(optionlist[i].Value);
                    filter2 += ' AND '+fieldApiName+' >='+dateVal;
                } else if(bomLineOptionlist[i].Type == 'DATE'){
                    var dateVal = bomLineOptionlist[i].Value// new Date(optionlist[i].Value);
                    filter2 += ' AND '+fieldApiName+' >='+dateVal;
                }
                console.log(filter2);
            }
        }
        
        
      
        
        var action = component.get("c.searchQueryResult3");
        action.setParams({
            recordId: component.get('v.recordId'),
            productPageNumber: productPageNumber,
            productPageSize: productPageSize,
            pageNumber: pageNumber,
            pageSize: pageSize,
            SSTLPageNumber: SSTLPageNumber,
            SSTLPageSize: SSTLPageSize,
            /*packageLinesSearchTradeType: packageLinesSearchTradeType,
            packageLinesSearchCategory: packageLinesSearchCategory,
            packageLinesSearchProductType: packageLinesSearchProductType,
            collection: collection,*/
            filter1 : filter,
            filter2 : filter1,
            filter3 : filter2,
            selectPriceBook : component.get("v.pricebookName"),
           /* filterProductOptionList : JSON.stringify(filterProductOption),
            filterOptionList: JSON.stringify(filterOption),
             filterBOMLineOption :JSON.stringify(filterBOMLineOption), */ 
            /* buildPhase: buildPhase,
           tradeType: tradeType,
            category: category,
            productType: productType,
            locationSearch: locationSearch,
            tradeTypeSSTL: tradeTypeSSTL,
            categorySSTL: categorySSTL,
            productTypeSSTL: productTypeSSTL*/
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
                        //component.set('v.productsList', helper.groupRecords(result.productsRecord));
                    	component.set('v.productsList', helper.groupRecords1(result.productsRecord,component,component.get("v.productselectedFields")));
                    }
                    if (result.takeOffLinesList != undefined) {
                        helper.setTakeOffLinesRecords(component, pageNumber, pageSize, result.takeOffLinesList.length, result.totalRecords)
                       // component.set('v.takeOffLinesList', helper.groupRecords(result.takeOffLinesList));
                        //component.set('v.takeOffLinesList', helper.groupRecords1(result.takeOffLinesList, component));
                       component.set('v.takeOffLinesList', helper.groupRecords1(result.takeOffLinesList,component,component.get("v.selectedFields"))); 
                    }
                    if (result.selectionSheetTakeOffLines != undefined) {
                        result.selectionSheetTakeOffLines != undefined ? helper.setSSTLRecords(component, SSTLPageNumber, SSTLPageSize, result.selectionSheetTakeOffLines.length, result.SSTLTotalRecords) : '';
                        //component.set('v.selectionSheetTakeOffLines', helper.groupRecords(result.selectionSheetTakeOffLines));
                        component.set('v.selectionSheetTakeOffLines', helper.groupRecords1(result.selectionSheetTakeOffLines,component,component.get("v.bomLineselectedFields")));
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
        var optionlist = component.get("v.fieldNameApiList")
        
        var productOptionlist = component.get("v.fieldProductNameApiList")
       
         var bomLineOptionlist = component.get("v.fieldBOMLineNameApiList")
       
        
        var filter = '';
        var filter1 = '';
        var filter2 = '';
        
        //Takeoff
         for(var i=0;i<optionlist.length;i++){
            if(optionlist[i].Value){
                var fieldApiName = optionlist[i]['Name']
                if(optionlist[i].Type == 'REFERENCE'){
                     
                    var fieldApiName1 = fieldApiName.split('__c')[0];
                    var value = '\'%' + optionlist[i].Value + '%\'';
                    filter += ' AND '+fieldApiName1+'__r.Name LIKE '+value;
               
                }else if(optionlist[i].Type == 'STRING' ||optionlist[i].Type == 'PICKLIST'){
                    var STRvalue = '\'%'  + optionlist[i].Value + '%\'';
                    filter += ' AND '+fieldApiName+' LIKE '+STRvalue;
                }else if(optionlist[i].Type == 'DOUBLE'){
                    var value1 =  JSON.parse(optionlist[i].Value);
                    filter += ' AND '+fieldApiName+' ='+value1;
                }else if(optionlist[i].Type == 'DATETIME'){
                    var dateVal = optionlist[i].Value// new Date(optionlist[i].Value);
                    filter += ' AND '+fieldApiName+' >='+dateVal;
                } else if(optionlist[i].Type == 'DATE'){
                    var dateVal = optionlist[i].Value// new Date(optionlist[i].Value);
                    filter += ' AND '+fieldApiName+' >='+dateVal;
                }
                console.log(filter);
            }
        }
        
        
        for(var i=0;i<productOptionlist.length;i++){
            if(productOptionlist[i].Value){
                var fieldApiName = productOptionlist[i]['Name']
                if(productOptionlist[i].Type == 'REFERENCE'){
                     
                    var fieldApiName1 = fieldApiName.split('__c')[0];
                    var value = '\'%' + productOptionlist[i].Value + '%\'';
                    filter1 += ' AND '+fieldApiName1+'__r.Name LIKE '+value;
               
                }else if(productOptionlist[i].Type == 'STRING' ||productOptionlist[i].Type == 'PICKLIST'){
                    var STRvalue = '\'%'  + productOptionlist[i].Value + '%\'';
                    filter1 += ' AND '+fieldApiName+' LIKE '+STRvalue;
                }else if(productOptionlist[i].Type == 'DOUBLE'){
                    var value1 =  JSON.parse(productOptionlist[i].Value);
                    filter1 += ' AND '+fieldApiName+' ='+value1;
                }else if(productOptionlist[i].Type == 'DATETIME'){
                    var dateVal = productOptionlist[i].Value// new Date(optionlist[i].Value);
                    filter1 += ' AND '+fieldApiName+' >='+dateVal;
                } else if(productOptionlist[i].Type == 'DATE'){
                    var dateVal = productOptionlist[i].Value// new Date(optionlist[i].Value);
                    filter1 += ' AND '+fieldApiName+' >='+dateVal;
                }
                console.log(filter1);
            }
        }
        
        
         for(var i=0;i<bomLineOptionlist.length;i++){
            if(bomLineOptionlist[i].Value){
                var fieldApiName = bomLineOptionlist[i]['Name']
                if(bomLineOptionlist[i].Type == 'REFERENCE'){
                     
                    var fieldApiName1 = fieldApiName.split('__c')[0];
                    var value = '\'%' + bomLineOptionlist[i].Value + '%\'';
                    filter2 += ' AND '+fieldApiName1+'__r.Name LIKE '+value;
               
                }else if(bomLineOptionlist[i].Type == 'STRING' ||bomLineOptionlist[i].Type == 'PICKLIST'){
                    var STRvalue = '\'%'  + bomLineOptionlist[i].Value + '%\'';
                    filter2 += ' AND '+fieldApiName+' LIKE '+STRvalue;
                }else if(bomLineOptionlist[i].Type == 'DOUBLE'){
                    var value1 =  JSON.parse(bomLineOptionlist[i].Value);
                    filter2 += ' AND '+fieldApiName+' ='+value1;
                }else if(bomLineOptionlist[i].Type == 'DATETIME'){
                    var dateVal = bomLineOptionlist[i].Value// new Date(optionlist[i].Value);
                    filter2 += ' AND '+fieldApiName+' >='+dateVal;
                } else if(bomLineOptionlist[i].Type == 'DATE'){
                    var dateVal = bomLineOptionlist[i].Value// new Date(optionlist[i].Value);
                    filter2 += ' AND '+fieldApiName+' >='+dateVal;
                }
                console.log(filter2);
            }
        }
        
        
        var action = component.get("c.retrieveProductRecords");
        action.setParams({
            recordId: component.get('v.recordId'),
            productPageNumber: productPageNumber,
            productPageSize: productPageSize,
            pageNumber: pageNumber,
            pageSize: pageSize,
            SSTLPageNumber: SSTLPageNumber,
            SSTLPageSize: SSTLPageSize,
           /* packageLinesSearchTradeType: packageLinesSearchTradeType,
            packageLinesSearchCategory: packageLinesSearchCategory,
            packageLinesSearchProductType: packageLinesSearchProductType,*/
            filter1 : filter,
            filter2 : filter1,
            filter3 : filter2,
            /*filterProductOptionsList : JSON.stringify(filterProductOption),
            filterOptionList: JSON.stringify(filterOption),
             filterBOMLineOption :JSON.stringify(filterBOMLineOption), */ 
            /* collection: collection,
            tradeType: tradeType,
            category: category,
            productType: productType,
            locationSearch: locationSearch,
            tradeTypeSSTL: tradeTypeSSTL,
            categorySSTL: categorySSTL,
            productTypeSSTL: productTypeSSTL,*/
            filteredTakeOffLines: JSON.stringify(filteredTakeOffLines),
            selectPriceBook : component.get("v.pricebookName")
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
                        //component.set('v.productsList', helper.groupRecords(result.productsRecord));
                        component.set('v.productsList', helper.groupRecords1(result.productsRecord,component,component.get("v.productselectedFields")));
                    }
                    if (result.selectionSheetTakeOffLines != undefined) {
                        result.selectionSheetTakeOffLines != undefined ? helper.setSSTLRecords(component, SSTLPageNumber, SSTLPageSize, result.selectionSheetTakeOffLines.length, result.SSTLTotalRecords) : '';
                        //component.set('v.selectionSheetTakeOffLines', helper.groupRecords(result.selectionSheetTakeOffLines));
                        component.set('v.selectionSheetTakeOffLines', helper.groupRecords1(result.selectionSheetTakeOffLines,component,component.get("v.bomLineselectedFields")));
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
        
        var optionlist = component.get("v.fieldNameApiList")
        var productOptionlist = component.get("v.fieldProductNameApiList")
        var bomLineOptionlist = component.get("v.fieldBOMLineNameApiList")
       
         var filter = '';
        var filter1 = '';
        var filter2 = '';
        
        //Takeoff
        for(var i=0;i<optionlist.length;i++){
            if(optionlist[i].Value){
                var fieldApiName = optionlist[i]['Name']
                if(optionlist[i].Type == 'REFERENCE'){
                     
                    var fieldApiName1 = fieldApiName.split('__c')[0];
                    var value = '\'%' + optionlist[i].Value + '%\'';
                    filter += ' AND '+fieldApiName1+'__r.Name LIKE '+value;
               
                }else if(optionlist[i].Type == 'STRING' ||optionlist[i].Type == 'PICKLIST'){
                    var STRvalue = '\'%'  + optionlist[i].Value + '%\'';
                    filter += ' AND '+fieldApiName+' LIKE '+STRvalue;
                }else if(optionlist[i].Type == 'DOUBLE'){
                    var value1 =  JSON.parse(optionlist[i].Value);
                    filter += ' AND '+fieldApiName+' ='+value1;
                }else if(optionlist[i].Type == 'DATETIME'){
                    var dateVal = optionlist[i].Value// new Date(optionlist[i].Value);
                    filter += ' AND '+fieldApiName+' >='+dateVal;
                } else if(optionlist[i].Type == 'DATE'){
                    var dateVal = optionlist[i].Value// new Date(optionlist[i].Value);
                    filter += ' AND '+fieldApiName+' >='+dateVal;
                }
                console.log(filter);
            }
        }
        
        for(var i=0;i<productOptionlist.length;i++){
            if(productOptionlist[i].Value){
                var fieldApiName = productOptionlist[i]['Name']
                if(productOptionlist[i].Type == 'REFERENCE'){
                     
                    var fieldApiName1 = fieldApiName.split('__c')[0];
                    var value = '\'%' + productOptionlist[i].Value + '%\'';
                    filter1 += ' AND '+fieldApiName1+'__r.Name LIKE '+value;
               
                }else if(productOptionlist[i].Type == 'STRING' ||productOptionlist[i].Type == 'PICKLIST'){
                    var STRvalue = '\'%'  + productOptionlist[i].Value + '%\'';
                    filter1 += ' AND '+fieldApiName+' LIKE '+STRvalue;
                }else if(productOptionlist[i].Type == 'DOUBLE'){
                    var value1 =  JSON.parse(productOptionlist[i].Value);
                    filter1 += ' AND '+fieldApiName+' ='+value1;
                }else if(productOptionlist[i].Type == 'DATETIME'){
                    var dateVal = productOptionlist[i].Value// new Date(optionlist[i].Value);
                    filter1 += ' AND '+fieldApiName+' >='+dateVal;
                } else if(productOptionlist[i].Type == 'DATE'){
                    var dateVal = productOptionlist[i].Value// new Date(optionlist[i].Value);
                    filter1 += ' AND '+fieldApiName+' >='+dateVal;
                }
                console.log(filter1);
            }
        }
        
        
         for(var i=0;i<bomLineOptionlist.length;i++){
            if(bomLineOptionlist[i].Value){
                var fieldApiName = bomLineOptionlist[i]['Name']
                if(bomLineOptionlist[i].Type == 'REFERENCE'){
                     
                    var fieldApiName1 = fieldApiName.split('__c')[0];
                    var value = '\'%' + bomLineOptionlist[i].Value + '%\'';
                    filter2 += ' AND '+fieldApiName1+'__r.Name LIKE '+value;
               
                }else if(bomLineOptionlist[i].Type == 'STRING' ||bomLineOptionlist[i].Type == 'PICKLIST'){
                    var STRvalue = '\'%'  + bomLineOptionlist[i].Value + '%\'';
                    filter2 += ' AND '+fieldApiName+' LIKE '+STRvalue;
                }else if(bomLineOptionlist[i].Type == 'DOUBLE'){
                    var value1 =  JSON.parse(bomLineOptionlist[i].Value);
                    filter2 += ' AND '+fieldApiName+' ='+value1;
                }else if(bomLineOptionlist[i].Type == 'DATETIME'){
                    var dateVal = bomLineOptionlist[i].Value// new Date(optionlist[i].Value);
                    filter2 += ' AND '+fieldApiName+' >='+dateVal;
                } else if(bomLineOptionlist[i].Type == 'DATE'){
                    var dateVal = bomLineOptionlist[i].Value// new Date(optionlist[i].Value);
                    filter2 += ' AND '+fieldApiName+' >='+dateVal;
                }
                console.log(filter2);
            }
        }
        
        
        var action = component.get("c.deleteSelectedSSTLRecord");
        action.setParams({
            recordId: component.get('v.recordId'),
            productPageNumber: productPageNumber,
            productPageSize: productPageSize,
            pageNumber: pageNumber,
            pageSize: pageSize,
            SSTLPageNumber: SSTLPageNumber,
            SSTLPageSize: SSTLPageSize,
            /*packageLinesSearchTradeType: packageLinesSearchTradeType,
            packageLinesSearchCategory: packageLinesSearchCategory,
            packageLinesSearchProductType: packageLinesSearchProductType,
            collection: collection,
            tradeType: tradeType,
            category: category,
            productType: productType,
            locationSearch: locationSearch,
            tradeTypeSSTL: tradeTypeSSTL,
            categorySSTL: categorySSTL,
            productTypeSSTL: productTypeSSTL,*/
             filter1 : filter,
            filter2 : filter1,
            filter3 : filter2,
            /* filterProductOptionsList : JSON.stringify(filterProductOption),
            filterOptionList: JSON.stringify(filterOption),
             filterBOMLineOption :JSON.stringify(filterBOMLineOption), */
            deleteSSTLIds: component.get('v.selectionSheetTakeOffLinesToDelete'),
            selectPriceBook: component.get("v.pricebookName")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                result.selectionSheetTakeOffLines = result.selectionSheetTakeOffLines == undefined ? [] : result.selectionSheetTakeOffLines;
                if (result != null) {
                    helper.setSSTLRecords(component, SSTLPageNumber, SSTLPageSize, result.selectionSheetTakeOffLines.length, result.SSTLTotalRecords);
                    //component.set('v.selectionSheetTakeOffLines', helper.groupRecords(result.selectionSheetTakeOffLines));
                     component.set('v.sstlines',result.SSTLTotalRecords);
                    component.set('v.selectionSheetTakeOffLines', helper.groupRecords1(result.selectionSheetTakeOffLines,component,component.get("v.bomLineselectedFields")));
                }
                component.set('v.selectionSheetTakeOffLinesToDelete', '');
                component.set("v.isSpinner", false);
                $A.get('e.force:refreshView').fire();
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
    
    /*getField : function (component, event, helper, title, message, type) {
        var action = component.get("c.getfieldValue");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 var result = response.getReturnValue();
                component.set("v.filterOptions",result)
            }
        })
        $A.enqueueAction(action);
    }*/
    
    
     fetchTakeOffLinesData: function (component, event, helper) {       
        var action = component.get("c.getTakeOffLinesData");        
        action.setCallback(this, function (response) {
            debugger;
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result != null) {
                    console.log(result);
                    //alert(JSON.stringify(result.TakeOffFieldSettings));
                    var TakeOffFieldsSettings = result.TakeOffFieldSettings;                   
                    component.set("v.TakeOffFieldsSettings",TakeOffFieldsSettings);
                    component.set("v.takeofflineLength",result.selectedFields.split(',').length)
                    component.set("v.selectedFields",result.selectedFields);
                    //alert(JSON.stringify(result.selectedFields));
                    /*product data*/
                    component.set("v.productFieldsSettings",result.productFieldSettings);
                    component.set("v.productselectedFieldsLength",result.productselectedFields.split(',').length)
                    component.set("v.productselectedFields",result.productselectedFields);
                    // bom line data
                    component.set("v.bomLineFieldsSettings",result.bomLineFieldSettings);
                    var bomSelectedFieldsLength = result.bomLineselectedFields.split(',').length
                    bomSelectedFieldsLength = bomSelectedFieldsLength+2;
                    component.set("v.bomLineselectedFieldsLength",bomSelectedFieldsLength)
                    component.set("v.bomLineselectedFields",result.bomLineselectedFields);
                }
                    
                
                component.set("v.isSpinner", false);
                
            } else {
                helper.showToast(component, event, helper, 'Error!', 'Something went wrong!', 'error');
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
    },
    
    
    fetchpricebooks: function (component, event, helper) {
        var action = component.get("c.getpricebook");
        action.setParams({
            BudgetId: component.get("v.recordId"),
        });
        var opts = [];
        action.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                component.set("v.pricebookName", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        var actions = component.get("c.getpricebooks");
        var opts = [];
        actions.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                var result = response.getReturnValue();
                var opts = [];
                opts.push({
                    key: "All",
                    value: "",
                });
                for (var key in result) {
                    opts.push({
                        key: key,
                        value: result[key],
                    });
                }
                component.set("v.pricebookoptions", opts);
            }
        });
        $A.enqueueAction(actions);
    },
    
       
    getParameterByName: function (component, event, name) {
        name = name.replace(/[\[\]]/g, "\\$&");
        var url = window.location.href;
        //alert('url -------> '+url);
        var regex = new RegExp("[?&]" + name + "(=1\.([^&#]*)|&|#|$)");
        var results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    },
    
    getProductDetails: function (component, event, helper) {
        var action = component.get("c.getProductPrice");
        var productId = component.get("v.productId");
        var productName = component.get("v.productName");
        action.setParams({
            "productId": productId
        });
        action.setCallback(this, function (respo) {
            var res = respo.getReturnValue();
            var getProductDetails = component.get("v.newprojecttakeoffline");
            ////console.log("@Budgetline@",component.get("v.recordId"));
            
            /* getProductDetails.buildertek__Description__c = productName;
             if(res.length>=1) {
                 getProductDetails.buildertek__Unit_Price__c = res[0].UnitPrice;
             }else{
                 getProductDetails.buildertek__Unit_Price__c = 0;
             } */
            getProductDetails.buildertek__Product__c = productId;
            
            getProductDetails.buildertek__Description__c = productName;
            component.set("v.newprojecttakeoffline", getProductDetails);
        });
        $A.enqueueAction(action);
    },
    fetchpricebooks: function (component, event, helper) {
        var action = component.get("c.getpricebook");
        action.setParams({
            "PtoffId": component.get("v.recordId")
        });
        var opts = [];
        action.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                
                component.set("v.pricebookName", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        var actions = component.get("c.getpricebooks");
        
        var opts = [];
        actions.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                var result = response.getReturnValue();
                var opts = [];
                opts.push({
                    key: "None",
                    value: ""
                });
                for (var key in result) {
                    opts.push({
                        key: key,
                        value: result[key]
                    });
                }
                component.set("v.pricebookoptions", opts);
                component.set("v.Spinner", false);
            }
        });
        $A.enqueueAction(actions);
    },
    
     
    getPackageRecords: function (component, event, helper) {
        debugger;
        var pageSize = component.get("v.pageSize");
        var paginationList = [];
        var action = component.get("c.getPackageTakeoff");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.packageTakeOffList", result);
                component.set("v.totalRecords", component.get("v.packageTakeOffList").length);
                component.set("v.startPage", 0);
                component.set("v.endPage", pageSize - 1);
                for (var i = 0; i < pageSize; i++) {
                    if (component.get("v.packageTakeOffList").length > i)
                        paginationList.push(result[i]);
                }
                component.set('v.paginationList', paginationList);
                component.set("v.Spinner", false);
            }
        });
        $A.enqueueAction(action);
    },
    
    
    importTOffLinesPackage: function (component, event, helper, takeOffLinesIds) {
        debugger;
        var action = component.get("c.importPackageLinesRecords");
        action.setParams({
            takeOffLinesIds: takeOffLinesIds,
            recordId: component.get("v.parentRecordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result != null) {
                   component.set("v.isImportPackage",false);
                    $A.get('e.force:refreshView').fire();
                }
                
            } else {
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
    },

    


})