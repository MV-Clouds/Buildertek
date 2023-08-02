({
    getadminrecords : function (component, event, helper) {
       var action = component.get("c.getadminvalue"); 
       action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result == true) {
                    component.set('v.isadmin', result);
                }
            } else {
                 component.set('v.isadmin', false);
            }
        });
        $A.enqueueAction(action);
        
    },
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

                    if(result.projectSelectionSheetTakeOffRec.buildertek__Opportunity__c){
                        component.set("v.opportunityName",result.projectSelectionSheetTakeOffRec.buildertek__Opportunity__r.Name);
                        component.set("v.opportunityId",result.projectSelectionSheetTakeOffRec.buildertek__Opportunity__r.Id);
                    }
                }
            } else {
                helper.showToast(component, event, helper, 'Error!', 'Something went wrong!', 'error');
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
    },
    updatequan: function (component, event, helper) {
        // var checkLines =  component.get("v.selectedProdIds");
       // if(checkLines.length >= 1){
        var selectionSheetTakeOffLines = component.get("v.selectionSheetTakeOffLines");
        console.log('@@@@selectionSheetTakeOffLines---',selectionSheetTakeOffLines);
        var bomLineNameWithError;

        if(selectionSheetTakeOffLines != null && selectionSheetTakeOffLines != undefined && selectionSheetTakeOffLines.length > 0)
        {
            for(var i=0; i<selectionSheetTakeOffLines.length; i++)
            {
                console.log('@@@@Take Off groupedRecords--',selectionSheetTakeOffLines[i].groupedRecords);
                var groupedRecords = selectionSheetTakeOffLines[i].groupedRecords;

                if(groupedRecords != null && groupedRecords != undefined && groupedRecords.length > 0)
                {
                    for(var j=0; j<groupedRecords.length; j++)
                    {
                        var takeOffLines = groupedRecords[j].buildertek__Takeoff_Line__r;
                        console.log('@@@@takeOffLines--',takeOffLines);

                        if(takeOffLines == null || takeOffLines == undefined || takeOffLines.length == 0 )
                        {
                            //No TakeOff Line Data Found
                            bomLineNameWithError = groupedRecords[j].Name;
                            break;
                        }
                    }
                }

                //If we found a record without TakeOffLine we will break this loop too
                if(bomLineNameWithError != null && bomLineNameWithError != undefined && bomLineNameWithError != '' )
                {
                    break;
                }
            }

            if(bomLineNameWithError != null && bomLineNameWithError != undefined && bomLineNameWithError != '' )
            {
                //Show Toast with Error
                var errorString = 'No TakeOff Line value found for the BOM Line - '+bomLineNameWithError+'. Please add a TakeOff Line value.';
                helper.showToast(component, event, helper, 'Error!', errorString, 'error');
            }
            else 
            {
                //Call the apex controller
                var action = component.get("c.updatequantityvalues");
                action.setParams({
                    // "prodIds": checkLines,
                    "prodIds": component.get('v.recordId')
                });
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state == "SUCCESS") {
                        //alert('result'+result);
                        // if(result != undefined){
                        var result = response.getReturnValue();
                        //$A.get('e.force:refreshView').fire();
                        component.set("v.isupdatequote", true);
                        // component.set("v.takeline", result);
                        component.set("v.recordList", result);
                        // $A.get('e.force:refreshView').fire();
                        /* var toastEvent = $A.get("e.force:showToast");
                         toastEvent.setParams({
                             title : 'Success',
                             message: 'The Selected Products are Successfully Updated',
                             duration:' 5000',
                             key: 'info_alt',
                             type: 'success',
                             mode: 'pester'
                         });
                         toastEvent.fire();*/
                        /* }else{
                             var toastEvent = $A.get("e.force:showToast");
                             toastEvent.setParams({
                                 title: 'ERROR',
                                 message: 'There is no lines',
                                 duration: "5000",
                                 key: "info_alt",
                                 type: "error",
                             });
                             toastEvent.fire(); 
                         }*/
                    }
                });
                $A.enqueueAction(action);
            }
        }
        else
        {
            console.log('@@@@Empty List');
            helper.showToast(component, event, helper, 'Error!', 'No BOM Line Data Found', 'error');
        }







            /*var action = component.get("c.updatequantityvalues");
            action.setParams({
               // "prodIds": checkLines,
                "prodIds": component.get('v.recordId')
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state == "SUCCESS") {
                    //alert('result'+result);
                   // if(result != undefined){
                        var result = response.getReturnValue();
                    //$A.get('e.force:refreshView').fire();
                        component.set("v.isupdatequote", true);
                       // component.set("v.takeline", result);
                        component.set("v.recordList", result);
                   // $A.get('e.force:refreshView').fire();
                       /* var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Success',
                            message: 'The Selected Products are Successfully Updated',
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'success',
                            mode: 'pester'
                        });
                        toastEvent.fire();*/
                   /* }else{
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: 'ERROR',
                            message: 'There is no lines',
                            duration: "5000",
                            key: "info_alt",
                            type: "error",
                        });
                        toastEvent.fire(); 
                    }
                }
            });
            $A.enqueueAction(action);*/
       /* }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'ERROR',
                message: 'Please select Products',
                duration: "5000",
                key: "info_alt",
                type: "error",
            });
            toastEvent.fire();   
        }*/
    },
    getRecords: function (component, event, helper) {
        
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
                        //component.set('v.productsList', helper.groupRecords1(result.productsRecord,component,component.get("v.productselectedFields")));
                    	component.set('v.productsList', helper.groupRecords2(result.productsRecord,component,component.get("v.productselectedFields"),'fromproduct'));
                    }
                    if (result.takeOffLinesList != undefined) { 
                        console.log('@@result.takeOffLinesList--',result.takeOffLinesList);
                       //alert('@@result.takeOffLinesList--'+ JSON.stringify(result.totalRecords));
                        if(result.takeOffLinesList != null && result.takeOffLinesList != undefined && result.takeOffLinesList.length > 0)
                        {
                            component.set('v.theTakeOffRecordId',result.takeOffLinesList[0].buildertek__Project_Takeoff__c);
                        }
                        helper.setTakeOffLinesRecords(component, pageNumber, pageSize, result.takeOffLinesList.length, result.totalRecords);
                        component.set('v.takeofflineslength',result.totalRecords);
                        //component.set('v.takeOffLinesList', helper.groupRecords(result.takeOffLinesList));
                      //  component.set('v.takeOffLinesList', helper.groupRecords1(result.takeOffLinesList,component,component.get("v.selectedFields")));
                       component.set('v.takeOffLinesList', helper.groupRecords2(result.takeOffLinesList,component,component.get("v.selectedFields"),'fromtakeoffline'));
                    //    helper.setPriceBookName(component, event, helper);
                    }
                    if (result.selectionSheetTakeOffLines != undefined) {
                        
                        console.log('result.selectionSheetTakeOffLines::::',result.selectionSheetTakeOffLines);
                        console.log('result.SSTLTotalRecords::::',result.SSTLTotalRecords);
                        result.selectionSheetTakeOffLines != undefined ? helper.setSSTLRecords(component, SSTLPageNumber, SSTLPageSize, result.selectionSheetTakeOffLines.length, result.SSTLTotalRecords) : '';
                        component.set('v.sstlines',result.SSTLTotalRecords);
                       // component.set('v.selectionSheetTakeOffLines', helper.groupRecords(result.selectionSheetTakeOffLines));
                       // component.set('v.selectionSheetTakeOffLines', helper.groupRecords1(result.selectionSheetTakeOffLines,component,component.get("v.bomLineselectedFields")));
                       console.log('takeoffline==='+result.selectionSheetTakeOffLines);
                   		 component.set('v.selectionSheetTakeOffLines', helper.groupRecords2(result.selectionSheetTakeOffLines,component,component.get("v.bomLineselectedFields"),'frombomline'));
                           //added for soting Selected Products by Takeoff line 26th August,2022
                            var selectionSheetTakeOffLines = component.get("v.selectionSheetTakeOffLines");
                            var totalList = [];
                            var sortList = [];
                            for(var s of selectionSheetTakeOffLines){
                                for(var ss of s.groupedRecordsTmp){
                                    totalList.push(ss);
                                }
                            }
                            console.log({totalList});
                            
                            let x = totalList.sort(( a, b ) => {
                                console.log({a});
                                console.log({b});
                                console.log('--.--.--.--');
                                var sa;
                                a.forEach(ele => {
                                    if(ele.Key == "buildertek__Takeoff_Line__r"){
                                        sa = ele.Value;
                                    }
                                });
                                var sb;
                                b.forEach(ele => {
                                    if(ele.Key == "buildertek__Takeoff_Line__r"){
                                        sb = ele.Value;
                                    }
                                });
                                
                                
                                  if ( sa < sb ){
                                    return -1;
                                  }
                                  if ( sa > sb ){
                                    return 1;
                                  }
                                  return 0;
                                });
                                component.set("v.sortedselectionSheetTakeOffLines",x);
                            
                    }
                }
                component.set("v.isSpinner", false);
                var getFieldMapAction =  component.get("c.getFiledNameAndApi")
                component.set("v.isSpinner",true)
                getFieldMapAction.setCallback(this, function (response) {
                    
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        component.set("v.isSpinner",true)
                        var result = response.getReturnValue();
                        component.set("v.fieldNameApiMap",result)
                        var neList = []
                        neList = Object.values(result)
                        console.log('neList==='+neList)
                        component.set("v.fieldNameApiList",neList)
                        component.set("v.isSpinner",false)
                    }
                })
                $A.enqueueAction(getFieldMapAction);
                
                //product
                var getProductFieldMapAction =  component.get("c.getProductFiledNameAndApi")
                component.set("v.isSpinner",true)
                getProductFieldMapAction.setCallback(this, function (response) {
                    
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        component.set("v.isSpinner",true)
                        var result = response.getReturnValue();
                        component.set("v.fieldProductNameApiMap",result)
                        var neList = []
                        neList = Object.values(result)
                        console.log('neList 1===='+neList)
                        component.set("v.fieldProductNameApiList",neList)
                        component.set("v.isSpinner",false)
                    }
                })
                $A.enqueueAction(getProductFieldMapAction);
                
                var getBOMLineFieldMapAction =  component.get("c.getBOMLineFiledNameAndApi")
                component.set("v.isSpinner",true)
                getBOMLineFieldMapAction.setCallback(this, function (response) {
                    
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        component.set("v.isSpinner",true)
                        var result = response.getReturnValue();
                        component.set("v.fieldBOMLineNameApiMap",result)
                        var neList = []
                        neList = Object.values(result)
                        console.log('neList 2=='+neList)
                        component.set("v.fieldBOMLineNameApiList",neList)
                        component.set("v.isSpinner",false)
                    }
                })
                $A.enqueueAction(getBOMLineFieldMapAction);
            } else {
                helper.showToast(component, event, helper, 'Error!', 'Something went wrong!', 'error');
                 console.log('Error');
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
                      // component.set('v.takeOffLinesList', helper.groupRecords1(result.takeOffLinesList,component,component.get("v.selectedFields")));
                       component.set('v.takeOffLinesList', helper.groupRecords2(result.takeOffLinesList,component,component.get("v.selectedFields"),'fromtakeoffline')); 
                    //    helper.setPriceBookName(component, event, helper);
                    }
                    if (result.selectionSheetTakeOffLines != undefined) {
                        result.selectionSheetTakeOffLines != undefined ? helper.setSSTLRecords(component, SSTLPageNumber, SSTLPageSize, result.selectionSheetTakeOffLines.length, result.SSTLTotalRecords) : '';
                       // component.set('v.selectionSheetTakeOffLines', helper.groupRecords(result.selectionSheetTakeOffLines));
                       // component.set('v.selectionSheetTakeOffLines', helper.groupRecords1(result.selectionSheetTakeOffLines,component,component.get("v.bomLineselectedFields")));
                     component.set('v.selectionSheetTakeOffLines', helper.groupRecords2(result.selectionSheetTakeOffLines,component,component.get("v.bomLineselectedFields"),'frombomline'));

                     //added for soting Selected Products by Takeoff line 26th August,2022
                     var selectionSheetTakeOffLines = component.get("v.selectionSheetTakeOffLines");
                     var totalList = [];
                     var sortList = [];
                     for(var s of selectionSheetTakeOffLines){
                         for(var ss of s.groupedRecordsTmp){
                             totalList.push(ss);
                         }
                     }
                     console.log({totalList});
                     
                     let x = totalList.sort(( a, b ) => {
                         console.log({a});
                         console.log({b});
                         console.log('--.--.--.--');
                         var sa;
                         a.forEach(ele => {
                             if(ele.Key == "buildertek__Takeoff_Line__r"){
                                 sa = ele.Value;
                             }
                         });
                         var sb;
                         b.forEach(ele => {
                             if(ele.Key == "buildertek__Takeoff_Line__r"){
                                 sb = ele.Value;
                             }
                         });
                         
                         
                           if ( sa < sb ){
                             return -1;
                           }
                           if ( sa > sb ){
                             return 1;
                           }
                           return 0;
                         });
                         component.set("v.sortedselectionSheetTakeOffLines",x);
                     
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
        //alert(component.get('v.totalRecords', totalRecords));
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
    
    // group by category
     groupRecords2: function (data,component,selectedFields,fromvar) {
        //alert(component.get("v.selectedFields"));
       console.log('selectedFields>>>>'+selectedFields);
        var selectedFields = selectedFields;
        var selectedFieldsArray = selectedFields.split(",");         
         
         var listOfRecords = [];
         let recordMap = new Map();
        console.log('data>>>>',data);
         if(fromvar == 'fromtakeoffline'){
             console.log('inside If---');
             for (var i in data) {
                 //buildertek__Categories__c
                 //Created Key with (#*&)
                 if (data[i].buildertek__Category__c) {
                     if (!recordMap.has(data[i].buildertek__Category__c + '(#*&)' + data[i].buildertek__Category__c)) {
                         recordMap.set(data[i].buildertek__Category__c + '(#*&)' + data[i].buildertek__Category__c, []);
                     }
                     recordMap.get(data[i].buildertek__Category__c + '(#*&)' + data[i].buildertek__Category__c).push(data[i]);
                 } else {
                     data[i].buildertek__Category__c = 'No Grouping';
                    // data[i].buildertek__Trade_Type__r = {};
                    // data[i].buildertek__Trade_Type__r.Name = 'No Grouping';
                     if (!recordMap.has(data[i].buildertek__Category__c + '(#*&)' + data[i].buildertek__Category__c)) {
                         recordMap.set(data[i].buildertek__Category__c + '(#*&)' + data[i].buildertek__Category__c, []);
                     }
                     recordMap.get(data[i].buildertek__Category__c + '(#*&)' + data[i].buildertek__Category__c).push(data[i]);
                 }
                 
                 /* if (data[i].buildertek__Categories__r) {
                     if (!recordMap.has(data[i].buildertek__Categories__c + '(#*&)' + data[i].buildertek__Categories__r.Name)) {
                         recordMap.set(data[i].buildertek__Categories__c + '(#*&)' + data[i].buildertek__Categories__r.Name, []);
                     }
                     recordMap.get(data[i].buildertek__Categories__c + '(#*&)' + data[i].buildertek__Categories__r.Name).push(data[i]);
                 } else {
                     data[i].buildertek__Categories__c = 'No Grouping';
                     data[i].buildertek__Categories__r = {};
                     data[i].buildertek__Categories__r.Name = 'No Grouping';
                     if (!recordMap.has(data[i].buildertek__Categories__c + '(#*&)' + data[i].buildertek__Categories__r.Name)) {
                         recordMap.set(data[i].buildertek__Categories__c + '(#*&)' + data[i].buildertek__Categories__r.Name, []);
                     }
                     recordMap.get(data[i].buildertek__Categories__c + '(#*&)' + data[i].buildertek__Categories__r.Name).push(data[i]);
                 }*/
             }
         }else{
             console.log('Inside Else===');
             for (var i in data) {
                 //Created Key with (#*&)
                 if (data[i].buildertek__Category__r != undefined) {
                     if (!recordMap.has(data[i].buildertek__Category__c + '(#*&)' + data[i].buildertek__Category__r.Name)) {
                         recordMap.set(data[i].buildertek__Category__c + '(#*&)' + data[i].buildertek__Category__r.Name, []);
                     }
                     recordMap.get(data[i].buildertek__Category__c + '(#*&)' + data[i].buildertek__Category__r.Name).push(data[i]);
                 } else {
                     data[i].buildertek__Category__c = 'No Grouping';
                     data[i].buildertek__Category__r = {};
                     data[i].buildertek__Category__r.Name = 'No Grouping';
                     if (!recordMap.has(data[i].buildertek__Category__c + '(#*&)' + data[i].buildertek__Category__r.Name)) {
                         recordMap.set(data[i].buildertek__Category__c + '(#*&)' + data[i].buildertek__Category__r.Name, []);
                     }
                     recordMap.get(data[i].buildertek__Category__c + '(#*&)' + data[i].buildertek__Category__r.Name).push(data[i]);
                 }
             }
         }
         console.log('recordMap==');
         console.log({recordMap});
         var result = Array.from(recordMap.entries());
         console.log('result=='+result);
         var  filteredTakeOffLineList = component.get('v.slectedcheckBoxtakeoffline');
         for (var i in result) {
             console.log('in For==');
             //alert(i);
             var obj = {};
             obj.groupId = result[i][0].split('(#*&)')[0];
             obj.groupName = result[i][0].split('(#*&)')[1];
             obj.groupedRecords = result[i][1];
             obj.isSelected = false; 
             if(filteredTakeOffLineList.indexOf(result[i][1]['Id']) > -1){
                 obj.isSelected  = true;
             }
             //alert( result[i][0].split('(#*&)')[1]);
             //alert(obj.groupName);
             
             var mainList = []; 
             
             //alert('arrkeys '+i+arrkeys);
             var takeoffrec
             for (var j in obj.groupedRecords) {
                 console.log('inside inner for loop');
                 //alert(obj.groupedRecords[j].Name);
                 obj.groupedRecords[j].isSelected = false;
                 takeoffrec = obj.groupedRecords[j]
                 if(filteredTakeOffLineList.indexOf(obj.groupedRecords[j]['Id']) > -1){
                     obj.groupedRecords[j].isSelected  = true;
                 }
                 
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
                             indexObj.isBOMLine = obj.groupedRecords[j]['buildertek__IsBOMLines__c']
                             if(filteredTakeOffLineList.indexOf(obj.groupedRecords[j]['Id']) > -1){
                                 indexObj.isSelected = true;
                             }
                         }
                         
                         if(mapKey.indexOf('__r')>0){
                             var AllRowListMap2 = new Map(Object.entries(AllRowListMap.get(mapKey)));
                             var mapKey2 = Array.from(AllRowListMap2.keys())[0];
                             indexObj.Key = mapKey;                                
                             indexObj.Value = AllRowListMap2.get(mapKey2); 
                             indexObj.Id  = AllRowListMap.get(keyId); 
                             indexObj.isSelected = false;
                             indexObj.isBOMLine = obj.groupedRecords[j]['buildertek__IsBOMLines__c']
                             if(filteredTakeOffLineList.indexOf(obj.groupedRecords[j]['Id']) > -1){
                                 indexObj.isSelected = true;
                             }
                         }
                         if(mapKey=='Name'){
                             indexObj.Key = mapKey;                                
                             indexObj.Value = AllRowListMap.get(mapKey);
                             indexObj.Id  = AllRowListMap.get(keyId); 
                             indexObj.isSelected = false;
                             indexObj.isBOMLine = obj.groupedRecords[j]['buildertek__IsBOMLines__c']
                             if(filteredTakeOffLineList.indexOf(obj.groupedRecords[j]['Id']) > -1){
                                 indexObj.isSelected = true;
                             }
                         }else if(mapKey.indexOf('__') < 0){
                             indexObj.Key = mapKey;                                
                             indexObj.Value = AllRowListMap.get(mapKey);
                             indexObj.Id  = AllRowListMap.get(keyId); 
                             indexObj.isSelected = false;
                             indexObj.isBOMLine = obj.groupedRecords[j]['buildertek__IsBOMLines__c']
                         }
                     }else{
                         indexObj.Key = mapKey;                                
                         indexObj.Value = '';
                         indexObj.Id  = AllRowListMap.get(keyId);   
                         indexObj.isSelected = false;
                         if(filteredTakeOffLineList.indexOf(obj.groupedRecords[j]['Id']) > -1){
                             indexObj.isSelected = true;
                         }
                         indexObj.isBOMLine = obj.groupedRecords[j]['buildertek__IsBOMLines__c']
                     }  
                     
                     newList.push(indexObj);  
                     
                 }
                 if(filteredTakeOffLineList.indexOf(obj.groupedRecords[j]['Id']) > -1){
                     newList.push({'isSelected':true})
                 }else{
                     newList.push({'isSelected':false})
                 }
                 
                  newList['isBOMLine'] = obj.groupedRecords[j]['buildertek__IsBOMLines__c']
                 
                 //newList.push({'isSelected':false})
                 if(fromvar == 'fromtakeoffline'){
                     if(filteredTakeOffLineList.indexOf(takeoffrec['Id']) > -1){
                        newList['isSelected'] = true
                     }else{
                         newList['isSelected'] = false
                         // newList.push({'isSelected':false})
                     }
                 }
                 mainList.push(newList);                 
             }
             console.log('mainList==');
             console.log({mainList});
             obj.groupedRecordsTmp = mainList;
             
             
             
             listOfRecords.push(obj);
         }
         
         console.log('listOfRecords:::::::',listOfRecords);
         var TestList = [];
         for (var val of listOfRecords) {
            console.log('test++'+val.groupedRecords);
            for (var value of val.groupedRecords) {
                console.log({value});
                TestList.push(value);
            }
        }
        console.log('TestList:::::::');
        console.log({TestList});
        //  TestList.sort((a, b) => a.groupedRecords.Name.localeCompare(b.groupedRecords.Name));

        // TestList.sort((a,b) => (a.buildertek__Takeoff_Line__r > b.buildertek__Takeoff_Line__r) ? 1 : ((b.buildertek__Takeoff_Line__r > a.buildertek__Takeoff_Line__r) ? -1 : 0))
        console.log('TestList af:::::::');
        // for (var val of TestList) {
        //     console.log('innnn===');
        //     var a = val.buildertek__Takeoff_Line__r.Name;
        //     console.log({a});
        // }
        TestList.sort(function(a,b){
            console.log('recordtype 1==='+a.buildertek__Takeoff_Line__r);
            // console.log('a Name==='+Object.entries(a.buildertek__Takeoff_Line__r).Name);
            // console.log('Name 2==='+b.buildertek__Takeoff_Line__r['Name']);
            // return object.entries(a.buildertek__Takeoff_Line__r).Name.toLowerCase().localeCompare(Object.entries(b.buildertek__Takeoff_Line__r).Name.toLowerCase());
           });
        console.log({TestList});
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
        if(productIdList.length > 0 ){
            var action1 = component.get("c.productrecords");
            component.set("v.NewProduct",productIdList);
            action1.setParams({
                productIds: productIdList,
            });
            action1.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if(result == 'success'){
                      //helper.showToast(component, event, helper, 'Warning!', 'There is No Product SKU for the Products You have selected.', 'warning');  
                      helper.showToast(component, event, helper, 'Warning!', 'There is No Product Code or Product SKU for the Products selected.', 'warning');
                    }else{
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
            selectPriceBook:  component.get('v.pricebookName'),
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
                  // component.set('v.selectionSheetTakeOffLines', helper.groupRecords1(result.selectionSheetTakeOffLines,component,component.get("v.bomLineselectedFields")));
                   component.set('v.selectionSheetTakeOffLines', helper.groupRecords2(result.selectionSheetTakeOffLines,component,component.get("v.bomLineselectedFields")),'frombomline'); 

                   //added for soting Selected Products by Takeoff line 26th August,2022
                   var selectionSheetTakeOffLines = component.get("v.selectionSheetTakeOffLines");
                   var totalList = [];
                   var sortList = [];
                   for(var s of selectionSheetTakeOffLines){
                       for(var ss of s.groupedRecordsTmp){
                           totalList.push(ss);
                       }
                   }
                   console.log({totalList});
                   
                   let x = totalList.sort(( a, b ) => {
                       console.log({a});
                       console.log({b});
                       console.log('--.--.--.--');
                       var sa;
                       a.forEach(ele => {
                           if(ele.Key == "buildertek__Takeoff_Line__r"){
                               sa = ele.Value;
                           }
                       });
                       var sb;
                       b.forEach(ele => {
                           if(ele.Key == "buildertek__Takeoff_Line__r"){
                               sb = ele.Value;
                           }
                       });
                       
                       
                         if ( sa < sb ){
                           return -1;
                         }
                         if ( sa > sb ){
                           return 1;
                         }
                         return 0;
                       });
                       component.set("v.sortedselectionSheetTakeOffLines",x);
                }
                var slectedcheckBoxtakeoffline = [];
                component.set('v.slectedcheckBoxtakeoffline',slectedcheckBoxtakeoffline);
                helper.getRecords(component, event, helper);
                helper.showToast(component, event, helper, 'Success!', 'Selection Sheet TakeOff Lines created Successfully.', 'success');
                component.set("v.isSpinner", false);
                
               // $A.get('e.force:refreshView').fire();
                
            } else {
                var slectedcheckBoxtakeoffline = [];

                helper.showToast(component, event, helper, 'Error!', 'Something went wrong!', 'error');
                console.log('Error');
                component.set('v.slectedcheckBoxtakeoffline',slectedcheckBoxtakeoffline);
            }
        });
        $A.enqueueAction(action);
                    }
                }
            });
            $A.enqueueAction(action1);
        }
    },
    createBOMLines: function (component, event, helper) {
        var SSTLPageNumber = component.get("v.SSTLPageNumber");
        var SSTLPageSize = component.get("v.SSTLPageSize");
        var action = component.get("c.validateAndCreateBOMLines");
        action.setParams({
            billOfMaterialId: component.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('BOM Create result--',result);
                if (result != null && result != undefined && result.selectionSheetTakeOffLines != null && result.selectionSheetTakeOffLines != undefined) 
                {
                    result.selectionSheetTakeOffLines = result.selectionSheetTakeOffLines == undefined ? [] : result.selectionSheetTakeOffLines;
                }
                if (result != null && result.selectionSheetTakeOffLines != undefined && result.SSTLTotalRecords != null && result.SSTLTotalRecords != undefined ) {
                    helper.setSSTLRecords(component, SSTLPageNumber, SSTLPageSize, result.selectionSheetTakeOffLines.length, result.SSTLTotalRecords);
                   // component.set('v.selectionSheetTakeOffLines', helper.groupRecords(result.selectionSheetTakeOffLines));
                  // component.set('v.selectionSheetTakeOffLines', helper.groupRecords1(result.selectionSheetTakeOffLines,component,component.get("v.bomLineselectedFields")));
                   component.set('v.selectionSheetTakeOffLines', helper.groupRecords2(result.selectionSheetTakeOffLines,component,component.get("v.bomLineselectedFields")),'frombomline'); 

                   //added for soting Selected Products by Takeoff line 26th August,2022
                   var selectionSheetTakeOffLines = component.get("v.selectionSheetTakeOffLines");
                   var totalList = [];
                   var sortList = [];
                   for(var s of selectionSheetTakeOffLines){
                       for(var ss of s.groupedRecordsTmp){
                           totalList.push(ss);
                       }
                   }
                   console.log({totalList});
                   
                   let x = totalList.sort(( a, b ) => {
                       console.log({a});
                       console.log({b});
                       console.log('--.--.--.--');
                       var sa;
                       a.forEach(ele => {
                           if(ele.Key == "buildertek__Takeoff_Line__r"){
                               sa = ele.Value;
                           }
                       });
                       var sb;
                       b.forEach(ele => {
                           if(ele.Key == "buildertek__Takeoff_Line__r"){
                               sb = ele.Value;
                           }
                       });
                       
                       
                         if ( sa < sb ){
                           return -1;
                         }
                         if ( sa > sb ){
                           return 1;
                         }
                         return 0;
                       });
                       component.set("v.sortedselectionSheetTakeOffLines",x);
                }
                var slectedcheckBoxtakeoffline = [];
                component.set('v.slectedcheckBoxtakeoffline',slectedcheckBoxtakeoffline);
                helper.getRecords(component, event, helper);
                if(result != null && result != undefined)
                {
                    helper.showToast(component, event, helper, 'Success!', 'Selection Sheet TakeOff Lines created Successfully.', 'success');
                }
                component.set("v.isSpinner", false);
                                
            } else {
                var slectedcheckBoxtakeoffline = [];

                helper.showToast(component, event, helper, 'Error!', 'Something went wrong!', 'error');
                console.log('Error');
                component.set('v.slectedcheckBoxtakeoffline',slectedcheckBoxtakeoffline);
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
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result != null) {
                    result.productsRecord = result.productsRecord == undefined ? [] : result.productsRecord;
                    result.takeOffLinesList = result.takeOffLinesList == undefined ? [] : result.takeOffLinesList;
                    result.selectionSheetTakeOffLines = result.selectionSheetTakeOffLines == undefined ? [] : result.selectionSheetTakeOffLines;

                    if (result.productsRecord != undefined) {
                        helper.setProductRecords(component, productPageNumber, productPageSize, result.productsRecord.length, result.productTotalRecords);
                       component.set('v.productslength' ,result.productTotalRecords)
                        //component.set('v.productsList', helper.groupRecords(result.productsRecord));
                    	//component.set('v.productsList', helper.groupRecords1(result.productsRecord,component,component.get("v.productselectedFields")));
                    	component.set('v.productsList', helper.groupRecords2(result.productsRecord,component,component.get("v.productselectedFields"),'fromproduct'));
                    }
                    if (result.takeOffLinesList != undefined) {
                        helper.setTakeOffLinesRecords(component, pageNumber, pageSize, result.takeOffLinesList.length, result.totalRecords)
                       // component.set('v.takeOffLinesList', helper.groupRecords(result.takeOffLinesList));
                        //component.set('v.takeOffLinesList', helper.groupRecords1(result.takeOffLinesList, component));
                      // component.set('v.takeOffLinesList', helper.groupRecords1(result.takeOffLinesList,component,component.get("v.selectedFields"))); 
                        component.set('v.takeOffLinesList', helper.groupRecords2(result.takeOffLinesList,component,component.get("v.selectedFields"),'fromtakeoffline')); 
                        // helper.setPriceBookName(component, event, helper);
                    }
                    if (result.selectionSheetTakeOffLines != undefined) {
                        result.selectionSheetTakeOffLines != undefined ? helper.setSSTLRecords(component, SSTLPageNumber, SSTLPageSize, result.selectionSheetTakeOffLines.length, result.SSTLTotalRecords) : '';
                        //component.set('v.selectionSheetTakeOffLines', helper.groupRecords(result.selectionSheetTakeOffLines));
                        //component.set('v.selectionSheetTakeOffLines', helper.groupRecords1(result.selectionSheetTakeOffLines,component,component.get("v.bomLineselectedFields")));
                        component.set('v.selectionSheetTakeOffLines', helper.groupRecords2(result.selectionSheetTakeOffLines,component,component.get("v.bomLineselectedFields"),'frombomline'));
                        
                        
                        //added for soting Selected Products by Takeoff line 26th August,2022
                        var selectionSheetTakeOffLines = component.get("v.selectionSheetTakeOffLines");
                        var totalList = [];
                        var sortList = [];
                        for(var s of selectionSheetTakeOffLines){
                            for(var ss of s.groupedRecordsTmp){
                                totalList.push(ss);
                            }
                        }
                        console.log({totalList});
                        
                        let x = totalList.sort(( a, b ) => {
                            console.log({a});
                            console.log({b});
                            console.log('--.--.--.--');
                            var sa;
                            a.forEach(ele => {
                                if(ele.Key == "buildertek__Takeoff_Line__r"){
                                    sa = ele.Value;
                                }
                            });
                            var sb;
                            b.forEach(ele => {
                                if(ele.Key == "buildertek__Takeoff_Line__r"){
                                    sb = ele.Value;
                                }
                            });
                            
                            
                              if ( sa < sb ){
                                return -1;
                              }
                              if ( sa > sb ){
                                return 1;
                              }
                              return 0;
                            });
                            component.set("v.sortedselectionSheetTakeOffLines",x);
                    }
                }
                component.set("v.isSpinner", false);
            } else {
                helper.showToast(component, event, helper, 'Error!', 'Something went wrong!', 'error');
                console.log('Error');
                console.log(response.getError());
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
                       // component.set('v.productsList', helper.groupRecords1(result.productsRecord,component,component.get("v.productselectedFields")));
                         //component.set('v.productsList', helper.groupRecords2(result.productsRecord,component,component.get("v.productselectedFields"),'fromproduct'));
                    }
                    if (result.selectionSheetTakeOffLines != undefined) {
                        result.selectionSheetTakeOffLines != undefined ? helper.setSSTLRecords(component, SSTLPageNumber, SSTLPageSize, result.selectionSheetTakeOffLines.length, result.SSTLTotalRecords) : '';
                        //component.set('v.selectionSheetTakeOffLines', helper.groupRecords(result.selectionSheetTakeOffLines));
                        //component.set('v.selectionSheetTakeOffLines', helper.groupRecords1(result.selectionSheetTakeOffLines,component,component.get("v.bomLineselectedFields")));
                        component.set('v.selectionSheetTakeOffLines', helper.groupRecords2(result.selectionSheetTakeOffLines,component,component.get("v.bomLineselectedFields"),'frombomline'));
                        

                        //added for soting Selected Products by Takeoff line 26th August,2022
                        var selectionSheetTakeOffLines = component.get("v.selectionSheetTakeOffLines");
                        var totalList = [];
                        var sortList = [];
                        for(var s of selectionSheetTakeOffLines){
                            for(var ss of s.groupedRecordsTmp){
                                totalList.push(ss);
                            }
                        }
                        console.log({totalList});
                        
                        let x = totalList.sort(( a, b ) => {
                            console.log({a});
                            console.log({b});
                            console.log('--.--.--.--');
                            var sa;
                            a.forEach(ele => {
                                if(ele.Key == "buildertek__Takeoff_Line__r"){
                                    sa = ele.Value;
                                }
                            });
                            var sb;
                            b.forEach(ele => {
                                if(ele.Key == "buildertek__Takeoff_Line__r"){
                                    sb = ele.Value;
                                }
                            });
                            
                            
                              if ( sa < sb ){
                                return -1;
                              }
                              if ( sa > sb ){
                                return 1;
                              }
                              return 0;
                            });
                            component.set("v.sortedselectionSheetTakeOffLines",x);
                    }
                    // helper.setPriceBookAndProducts(component, event, helper,filteredTakeOffLines);
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
                    //component.set('v.selectionSheetTakeOffLines', helper.groupRecords1(result.selectionSheetTakeOffLines,component,component.get("v.bomLineselectedFields")));
                    component.set('v.selectionSheetTakeOffLines', helper.groupRecords2(result.selectionSheetTakeOffLines,component,component.get("v.bomLineselectedFields"),'frombomline'));
                    

                    //added for soting Selected Products by Takeoff line 26th August,2022
                    var selectionSheetTakeOffLines = component.get("v.selectionSheetTakeOffLines");
                    var totalList = [];
                    var sortList = [];
                    for(var s of selectionSheetTakeOffLines){
                        for(var ss of s.groupedRecordsTmp){
                            totalList.push(ss);
                        }
                    }
                    console.log({totalList});
                    
                    let x = totalList.sort(( a, b ) => {
                        console.log({a});
                        console.log({b});
                        console.log('--.--.--.--');
                        var sa;
                        a.forEach(ele => {
                            if(ele.Key == "buildertek__Takeoff_Line__r"){
                                sa = ele.Value;
                            }
                        });
                        var sb;
                        b.forEach(ele => {
                            if(ele.Key == "buildertek__Takeoff_Line__r"){
                                sb = ele.Value;
                            }
                        });
                        
                        
                          if ( sa < sb ){
                            return -1;
                          }
                          if ( sa > sb ){
                            return 1;
                          }
                          return 0;
                        });
                        component.set("v.sortedselectionSheetTakeOffLines",x);
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
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result != null) {
                    console.log(result);
                   // alert(JSON.stringify(result));
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
                    console.log('result.bomLineFieldSettings==');
                    var test = result.bomLineFieldSettings;
                    console.log({test});
                    component.set("v.bomLineFieldsSettings",result.bomLineFieldSettings);
                    var bomSelectedFieldsLength = result.bomLineselectedFields.split(',').length
                    bomSelectedFieldsLength = bomSelectedFieldsLength+2;
                    component.set("v.bomLineselectedFieldsLength",bomSelectedFieldsLength)
                    console.log('result.bomLineselectedField===');
                    var Test = result.bomLineselectedFields;
                    console.log({Test});
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
                console.log('opts',{opts});
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
                    key: "All",
                    value: ""
                });
                for (var key in result) {
                    opts.push({
                        key: key,
                        value: result[key]
                    });
                }
                console.log('opts',{opts});
                component.set("v.pricebookoptions", opts);
                component.set("v.Spinner", false);
            }
        });
        $A.enqueueAction(actions);
    },
    
     
    getPackageRecords: function (component, event, helper) {
        
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
                   console.log(result[i]);
                }
                component.set('v.paginationList', paginationList);
                component.set("v.Spinner", false);
            }
        });
        $A.enqueueAction(action);
    },
    
    
    
   importTOffLinesPackage: function (component, event, helper, takeOffLinesIds) {
        
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

    setPriceBookName: function (component, event, helper)
    {
        var allTOLs = component.get('v.takeOffLinesList');
        var allPbOptions = component.get("v.pricebookoptions");
        var allPriceBooks = new Set();
        if(allTOLs != null && allTOLs != undefined && allTOLs.length > 0 )
        {
            allTOLs = allTOLs[0].groupedRecords;
            for(var i=0;i<allTOLs.length;i++)
            {
               if(allTOLs[i].buildertek__Price_Book__r != null && allTOLs[i].buildertek__Price_Book__r != undefined &&
                allTOLs[i].buildertek__Price_Book__r.Name != null && allTOLs[i].buildertek__Price_Book__r.Name != undefined && allTOLs[i].buildertek__Price_Book__r.Name != '')
                {
                    allPriceBooks.add(allTOLs[i].buildertek__Price_Book__r.Name);
                }
            }

            console.log('@@allPriceBooks--'+allPriceBooks.size);
            if(allPriceBooks != null && allPriceBooks != undefined && allPriceBooks.size == 1 )
            {
                var thisPbName;
                for (const pbName of allPriceBooks.values()) {
                    console.log('@@PB NAME--'+pbName);
                    thisPbName = pbName;
                }

                if(thisPbName != null && thisPbName != undefined && thisPbName !='' && allPbOptions != null && allPbOptions != undefined && allPbOptions.length > 0 )
                {
                    for(var i=0;i<allPbOptions.length; i++ )
                    {
                        if(allPbOptions[i].key == thisPbName)
                        {
                            component.set("v.pricebookName", allPbOptions[i].value);
                        }
                    }
                    
                    var flagVal = component.get('v.priceBookFlag');
                    console.log('@@flagVal--',flagVal);
                    if(flagVal == 1)
                    {
                        component.set('v.priceBookFlag',2);
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

                        // TakeOff Lines Search
                        var buildPhase = ''
                        var tradeType = ''
                        var category = ''
                        var productType = ''
                        var locationSearch = ''
                        var tradeTypeSSTL = ''
                        var categorySSTL = ''
                        var productTypeSSTL = ''

                        helper.getSearchRecords(component, event, helper, 1, productPageSize, 1, pageSize, 1, SSTLPageSize, packageLinesSearchTradeType, packageLinesSearchCategory, packageLinesSearchProductType, collection, tradeType, category, productType, locationSearch, tradeTypeSSTL, categorySSTL, productTypeSSTL);
                    }
                }

            }
        }
    },

    setPriceBookAndProducts: function (component, event, helper,filteredTakeOffLines)
    {
        var allPbOptions = component.get("v.pricebookoptions");

        if(allPbOptions != null && allPbOptions != undefined && 
            filteredTakeOffLines != null && filteredTakeOffLines != undefined && filteredTakeOffLines.length == 1 && 
            filteredTakeOffLines[0].buildertek__Price_Book__r != null && filteredTakeOffLines[0].buildertek__Price_Book__r != undefined && 
            filteredTakeOffLines[0].buildertek__Price_Book__r.Name != null && filteredTakeOffLines[0].buildertek__Price_Book__r.Name != undefined && filteredTakeOffLines[0].buildertek__Price_Book__r.Name != '' )
        {
            var theSelectedPB = filteredTakeOffLines[0].buildertek__Price_Book__r.Name;
            console.log('@@theSelectedPB--'+theSelectedPB);
            for(var i=0;i<allPbOptions.length; i++ )
            {
                if(allPbOptions[i].key == theSelectedPB)
                {
                    component.set("v.pricebookName", allPbOptions[i].value);
                }
            }

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

            // TakeOff Lines Search
            var buildPhase = ''
            var tradeType = ''
            var category = ''
            var productType = ''
            var locationSearch = ''
            var tradeTypeSSTL = ''
            var categorySSTL = ''
            var productTypeSSTL = ''

            helper.getSearchRecords(component, event, helper, 1, productPageSize, 1, pageSize, 1, SSTLPageSize, packageLinesSearchTradeType, packageLinesSearchCategory, packageLinesSearchProductType, collection, tradeType, category, productType, locationSearch, tradeTypeSSTL, categorySSTL, productTypeSSTL);
        }
        else
        {
            component.set("v.pricebookName", '');

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

            // TakeOff Lines Search
            var buildPhase = ''
            var tradeType = ''
            var category = ''
            var productType = ''
            var locationSearch = ''
            var tradeTypeSSTL = ''
            var categorySSTL = ''
            var productTypeSSTL = ''

            helper.getSearchRecords(component, event, helper, 1, productPageSize, 1, pageSize, 1, SSTLPageSize, packageLinesSearchTradeType, packageLinesSearchCategory, packageLinesSearchProductType, collection, tradeType, category, productType, locationSearch, tradeTypeSSTL, categorySSTL, productTypeSSTL);
        }
    },


})