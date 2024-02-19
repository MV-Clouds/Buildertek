({
    doInitHelper : function(component, event, helper) {
        component.set('v.Spinner', true);
        var action = component.get("c.getPricebookList");
        action.setParams({
            recordId:component.get("v.quoteId")
        })
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            // console.log(component.get('v.getPhase') , 'getPhase::::::;');
            let projectHavePricebook=result[0].defaultValue;
            console.log(Object.keys(projectHavePricebook).length);
            var pricebookOptions = [];
            if(Object.keys(projectHavePricebook).length !=0){

                pricebookOptions.push({ key: projectHavePricebook.Name, value: projectHavePricebook.Id });
                result[0].priceWrapList.forEach(function(element){
                    if(projectHavePricebook.Id !== element.Id){
                        pricebookOptions.push({ key: element.Name, value: element.Id });
                    }else{
                        pricebookOptions.push({ key: "None", value: "" });
                    }
                });
                component.set('v.selectedPricebookId' , projectHavePricebook.Id);

            }else{
                pricebookOptions.push({ key: "None", value: "" });
                result[0].priceWrapList.forEach(function(element){
                    pricebookOptions.push({ key: element.Name, value: element.Id });
                });
            }
            if(component.get('v.selectedPricebookId')!= undefined){
                var selectedPricebook = component.find("selectedPricebook").get("v.value");
                helper.changePricebookHelper(component, event, helper , selectedPricebook);
            }else{
                 component.set('v.Spinner', false);    
            }
            component.set("v.pricebookoptions", pricebookOptions);
            // component.set('v.Spinner', false);    
        });
        $A.enqueueAction(action);

        //create a action tgetQuoteLineGroups and set callback without parameters
        var action1 = component.get("c.getQuoteLineGroups");
        action1.setCallback(this, function(response){
            var result = response.getReturnValue();
            var quoteLineGroupOptions = [];
            var selectedProducts = [];


            // var phaseValue= component.get('v.getPhase');
            // if(phaseValue != undefined){

            // }else{
                result.forEach(element => {
                    quoteLineGroupOptions.push({ key: element.Name, value: element.Id });
                });

            // }
            
            component.set("v.quoteLineGroupOptions", quoteLineGroupOptions);
            // console.log({quoteLineGroupOptions});
            component.set("v.selectedQuoteLineGroupId", '');
        });  
        $A.enqueueAction(action1);      
    }, 

    changePricebookHelper : function(component, event, helper , priceBookId){
        // component.find("selectAll").set("v.checked", false);
        component.set('v.Spinner', true);
        component.set("v.sProductFamily", '');
        component.set("v.sProductName", '');
        component.set("v.sVendorName", '');
        // var selectedPricebook = component.find("selectedPricebook").get("v.value");
        console.log('selectedPricebook => '+priceBookId);
        if (priceBookId != '') {
            
            var action = component.get("c.getProductsthroughPriceBook2");
            action.setParams({
                "pbookId": priceBookId 
            });
            action.setCallback(this, function(response) {
                var rows = response.getReturnValue();
                if (response.getState() == "SUCCESS" && rows != null) {
                    console.log('quoteLineList ==> ',{rows});
                    // component.set("v.quoteLineList", rows);
                    // component.set("v.tableDataList", rows);
                    //---------------------------------------------------------------------------
                    var selectedRecords = component.get("v.selectedRecords");
                    var selectedRows = [];
                    var remainingRows = [];

                    rows.forEach(function(row) {
                        var matchingRecord = selectedRecords.find(function(record) {
                            return record.Id === row.Id;
                        });

                        if (matchingRecord) {
                            row.Selected = true; // Assuming there's a field like 'Selected__c'
                            selectedRows.push(row);
                        } else {
                            row.Selected = false;
                            remainingRows.push(row);
                        }
                    });

                    // Combine selectedRows and remainingRows while maintaining selected order
                    var updatedRows = selectedRecords.concat(remainingRows);

                    component.set("v.quoteLineList", updatedRows);
                    component.set("v.tableDataList", updatedRows);


                    //--------------------------------------------------------------------------
                    var productFamilySet = new Set();
                    rows.forEach(element => {
                        if (element.Family != undefined && element.Family != '') {
                            productFamilySet.add(element.Family);
                        }
                    });
                    var productFamilyList = [];
                    productFamilyList.push({
                        key: '-- All Product Family --',
                        value: ''
                    });
                    productFamilySet.forEach(function(value) {
                        productFamilyList.push({
                            key: value,
                            value: value
                        });
                    });
                    console.log(component.get('v.getPhase') , 'getPhase::::::;');
                    if(component.get('v.getPhase') != undefined && component.get('v.getPhase') != ''){
                        var quotelineGroupOptions = component.get("v.quoteLineGroupOptions");
                        console.log('quoteLineGroupOptions ==>', component.get("v.quoteLineGroupOptions"));
                        var name = '';
                        quotelineGroupOptions.forEach(function(element){
                            if(element.value == component.get('v.getPhase')){
                                name = element.key;
                            }
                        });
                        var productFamily = '';
                        productFamilyList.forEach(function(element){
                            if(element.key == name){
                                productFamily = element.value;
                            }
                        });
                        console.log('productFamily from phase ==> ',{productFamily});
                        if(productFamily != ''){
                            console.log('inside if');
                            component.set("v.sProductFamily", productFamily);
                            helper.changeProductFamilyHelper(component, event, helper , priceBookId, productFamily);
                        }
                        else{
                            component.set('v.Spinner', false);
                        }
                    }
                    else{
                        component.set('v.Spinner', false);
                    }
                    console.log('productFamilyList ==> ',{productFamilyList});
                    component.set("v.productFamilyOptions", productFamilyList);
                }
                else{
                    component.set('v.Spinner', false);
                }
            });
            $A.enqueueAction(action);
        } else {
            component.set("v.quoteLineList", []);
            component.set("v.tableDataList", []);
            component.set('v.Spinner', false);
        }
    }, 
    changeProductFamilyHelper : function(component, event, helper , priceBookId, productFamilyId){
        console.log('method is calllll');
        component.set('v.Spinner', true);
        component.set("v.sProductName", '');
        component.set("v.sVendorName", '');
        console.log('selectedPricebook====>',priceBookId);
        console.log('selectedProductFamily=====>',productFamilyId);
        let sProductFamily = component.get("v.sProductFamily");
        let sVendorName = component.get("v.sVendorName");
        console.log('sProductFamily=====>',sProductFamily);
        if (priceBookId != '' && productFamilyId != '') {
            
            var action = component.get("c.getProductsthroughProductFamily");
            action.setParams({
                "pbookId": priceBookId ,
                "pfId": productFamilyId
            });
            action.setCallback(this, function(response) {
                var rows = response.getReturnValue();
                if (response.getState() == "SUCCESS" && rows != null) {
                    console.log('quoteLineList ==> ',{rows});
                    // component.set("v.quoteLineList", rows);
                    // component.set("v.tableDataList", rows);
                    //---------------------------------------------------------------------------
                    var selectedRecords = component.get("v.selectedRecords");
                    var selectedRows = [];
                    var remainingRows = [];

                    rows.forEach(function(row) {
                        var matchingRecord = selectedRecords.find(function(record) {
                            return record.Id === row.Id;
                        });

                        if (matchingRecord) {
                            row.Selected = true; // Assuming there's a field like 'Selected__c'
                            selectedRows.push(row);
                        } else {
                            row.Selected = false;
                            remainingRows.push(row);
                        }
                    });

                    // Combine selectedRows and remainingRows while maintaining selected order
                    var updatedRows = selectedRecords.concat(remainingRows);

                    component.set("v.quoteLineList", updatedRows);
                    component.set("v.tableDataList", updatedRows);
                    //--------------------------------------------------------------------------
                }
                component.set('v.Spinner', false);
            });
            $A.enqueueAction(action);
        } else {
            component.set("v.quoteLineList", []);
            component.set("v.tableDataList", []);
            if(component.get('v.selectedPricebookId')!= undefined){
                var selectedPricebook = component.find("selectedPricebook").get("v.value");
                helper.changePricebookHelper(component, event, helper , selectedPricebook);
            }
        }
    },


    searchDatatableHelper : function(component, event, helper){
        console.log('searchDatatableHelper method is called------');
        component.set('v.Spinner', true);
        if (component.get("v.selectedPricebookId") != '') {
            let sVendorName = component.get("v.sVendorName");
            let sProductFamily = component.get("v.sProductFamily");
            let sProductName = component.get("v.sProductName");
            let sPriceBook = component.get("v.selectedPricebookId");
            var quoteLineList = component.get("v.quoteLineList");
            var tableDataList = [];
            if (sProductName != '' && sProductFamily == '') {
                
                    var action = component.get("c.getProductsbyName");
                    action.setParams({
                        "pbookId": sPriceBook ,
                        "pName": sProductName
                    });
                    action.setCallback(this, function(response) {
                        var rows = response.getReturnValue();
                        if (response.getState() == "SUCCESS" && rows != null) {
                            console.log('quoteLineList ==> ',{rows});
                            // component.set("v.quoteLineList", rows);
                            // component.set("v.tableDataList", rows);
                            //---------------------------------------------------------------------------
                            var selectedRecords = component.get("v.selectedRecords");
                            rows.forEach(function(row) {
                                var matchingRecord = selectedRecords.find(function(record) {
                                    return record.Id === row.Id;
                                });
                                if (matchingRecord) {
                                    row.Selected = true;
                                }
                            });
                            
                            // Sort the records with selected ones on top
                            rows.sort(function(a, b) {
                                if (a.Selected && !b.Selected) {
                                    return -1; // a comes before b
                                } else if (!a.Selected && b.Selected) {
                                    return 1; // b comes before a
                                }
                                return 0; // no change in order
                            });

                            if (sVendorName != '') {
                                // rows.forEach(element => {
                                //     if (element.Vendor == sVendorName) {
                                //         tableDataList.push(element);
                                //     }
                                // });
                                //make attribute of vendorName and set it to null
                                component.set("v.sVendorName", '');
                            } 
                            
                            component.set("v.quoteLineList", rows);
                            component.set("v.tableDataList", rows);
                            component.set('v.Spinner', false);
                            //--------------------------------------------------------------------------
                        }
                    });
                    $A.enqueueAction(action);
                
            }
            else if (sProductName != '' && sProductFamily != '') {
                
                    var action = component.get("c.getProductsbyNameandFamily");
                    action.setParams({
                        "pbookId": sPriceBook ,
                        "pName": sProductName ,
                        "pfId": sProductFamily
                    });
                    action.setCallback(this, function(response) {
                        var rows = response.getReturnValue();
                        if (response.getState() == "SUCCESS" && rows != null) {
                            console.log('quoteLineList ==> ',{rows});
                            // component.set("v.quoteLineList", rows);
                            // component.set("v.tableDataList", rows);
                            //---------------------------------------------------------------------------
                            var selectedRecords = component.get("v.selectedRecords");
                            rows.forEach(function(row) {
                                var matchingRecord = selectedRecords.find(function(record) {
                                    return record.Id === row.Id;
                                });
                                if (matchingRecord) {
                                    row.Selected = true;
                                }
                            });

                            // Sort the records with selected ones on top
                            rows.sort(function(a, b) {
                                if (a.Selected && !b.Selected) {
                                    return -1; // a comes before b
                                } else if (!a.Selected && b.Selected) {
                                    return 1; // b comes before a
                                }
                                return 0; // no change in order
                            });
                            
                            component.set("v.quoteLineList", rows);
                            component.set("v.tableDataList", rows);
                            component.set('v.Spinner', false);
                            //--------------------------------------------------------------------------
                        }
                    });
                    $A.enqueueAction(action);
                
            }
            else if (sProductName == '' && sProductFamily != '') {
                var selectedPricebook = component.find("selectedPricebook").get("v.value");
                var selectedProductFamily = component.find("selectedProductFamily").get("v.value");
                helper.changeProductFamilyHelper(component, event, helper , selectedPricebook, selectedProductFamily);
            }
            else if (sProductName == '' && sProductFamily == '') {
                var selectedPricebook = component.find("selectedPricebook").get("v.value");
                helper.changePricebookHelper(component, event, helper , selectedPricebook);
            }
        }
    }, 

    goToEditModalHelper: function(component, event, helper) {
        console.log("CAAALING");
        
        var quoteLineList = component.get("v.selectedRecords");
        console.log('quoteLineList => ',{quoteLineList});
        var selectedProducts = [];
        var phaseValue= component.get('v.getPhase');
        //finding No Grouping from quoteLineGroupOptions and store it's Id in noGroupingId
        var noGroupingId = '';
        var quoteLineGroupOptions = component.get("v.quoteLineGroupOptions");
        //iterate through quoteLineGroupOptions and find first No Grouping
        quoteLineGroupOptions.forEach(element => {
            if (element.key == 'No Grouping') {
                noGroupingId = element.value;
            }
        });
        quoteLineList.forEach(element => {
            console.log(phaseValue);
            console.log(phaseValue!= undefined);
            if(element.Selected){
                console.log("ELEMENT----->" , element.CostCode);
                selectedProducts.push({
                    'Id':element.Id,
                    'Name': element.Name,
                    'buildertek__Unit_Price__c': element.UnitPrice,
                    'buildertek__Cost_Code__c': element.CostCode,
                    'buildertek__Grouping__c': phaseValue,
                    'buildertek__Quantity__c': '1',
                    'buildertek__Additional_Discount__c': element.Discount ? element.Discount : 0,
                    'buildertek__Unit_Cost__c': element.UnitCost ? element.UnitCost : element.UnitPrice,
                    'buildertek__Markup__c': element.MarkUp ? element.MarkUp : 0,
                    'buildertek__Product__c': element.Id,
                    'buildertek__Size__c': element.Size,
                    'buildertek__Description__c': element.Description ? element.Description : element.Name,
                    'buildertek__Product_Family__c': element.Family ? element.Family : 'No Grouping',
                    'buildertek__UOM__c': element.QuantityUnitOfMeasure     //----

                })
                console.log('Quantity Unit Of Measure => ', element.QuantityUnitOfMeasure);
                console.log('Quantity Unit Of Measure New => ', element.CostCode);
            }

            // =====BUIL-3198 ====
            /*if (element.Selected && phaseValue != undefined) {
                console.log(phaseValue != undefined);
                    selectedProducts.push({
                        'Id':element.Id,
                        'Name': element.Name,
                        'buildertek__Unit_Price__c': element.UnitPrice,
                        'buildertek__Grouping__c': phaseValue,
                        'buildertek__Quantity__c': '1',
                        'buildertek__Additional_Discount__c': element.Discount ? element.Discount : 0,
                        'buildertek__Unit_Cost__c': element.UnitCost ? element.UnitCost : element.UnitPrice,
                        'buildertek__Markup__c': element.MarkUp ? element.MarkUp : 0,
                        'buildertek__Product__c': element.Id,
                        'buildertek__Size__c': element.Size,
                        'buildertek__Description__c': element.Description ? element.Description : element.Name,
                        'buildertek__Product_Family__c': element.Family ? element.Family : 'No Grouping'
                    })
            }else if(element.Selected){
                selectedProducts.push({
                    'Id':element.Id,
                    'Name': element.Name,
                    'buildertek__Unit_Price__c': element.UnitPrice,
                    'buildertek__Grouping__c': element.Phase ? element.Phase : noGroupingId,
                    'buildertek__Quantity__c': '1',
                    'buildertek__Additional_Discount__c': element.Discount ? element.Discount : 0,
                    'buildertek__Unit_Cost__c': element.UnitCost ? element.UnitCost : element.UnitPrice,
                    'buildertek__Markup__c': element.MarkUp ? element.MarkUp : 0,
                    'buildertek__Product__c': element.Id,
                    'buildertek__Size__c': element.Size,
                    'buildertek__Description__c': element.Description ? element.Description : element.Name,
                    'buildertek__Product_Family__c': element.Family ? element.Family : 'No Grouping'
                })
            }*/

            // ====BUIL-3198===
            
        });
        console.log('selectedProducts => ',{selectedProducts});
        // var truelist = component.get("v.trueCheckBoxList");
        component.set("v.selectedProducts", selectedProducts);
        if (selectedProducts.length > 0) {
            component.set("v.selecteProducts", false);
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Error',
                message: 'Please select at least one Product.',
                duration: ' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }
    },
})