({
    getVendors : function(component, event, helper) {
        try {
            component.set("v.Spinner", true);
            console.log('getVendors');

            var action = component.get("c.getVendors");
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var vendors = response.getReturnValue();
                    console.log('vendors: ', vendors);
                    component.set("v.MainvendorList", vendors);
                    component.set("v.ItervendorList", vendors);
                    component.set("v.Spinner", false);
                }
            });
            $A.enqueueAction(action);

            //create a action tgetQuoteLineGroups and set callback without parameters
            var action1 = component.get("c.getQuoteLineGroups");
            action1.setCallback(this, function(response){
                var result = response.getReturnValue();
                var quoteLineGroupOptions = [];
                result.forEach(element => {
                    quoteLineGroupOptions.push({ key: element.Name, value: element.Id });
                });
                
                component.set("v.quoteLineGroupOptions", quoteLineGroupOptions);
                component.set("v.selectedQuoteLineGroupId", '');
            });  
            $A.enqueueAction(action1);
        } catch (error) {
            component.set("v.Spinner", false);
            console.log('error in getVendors helper :: ' + error);
        }
    },

    goToProdModalHelper: function(component, event, helper) {
        try {
            component.set("v.Spinner", true);
            var vendorId = component.get('v.vendorId');
            console.log('vendorId--->',vendorId);
            component.set("v.vendorId" , vendorId);

            var action = component.get("c.getProductsthroughVendor");
            action.setParams({
                "vendorId": vendorId 
            });
            action.setCallback(this, function(response) {
                var rows = response.getReturnValue();
                if (response.getState() == "SUCCESS" && rows != null) {
                    console.log('quoteLineList ==> ',{rows});
                    console.log('updatedRows--->',rows);

                    component.set("v.quoteLineList", rows);
                    component.set("v.tableDataList", rows);
                    
                    var pricebookFamilySet = new Set();
                    rows.forEach(element => {
                        if (element.PriceBookName != undefined && element.PriceBookName != '') {
                            pricebookFamilySet.add(element.PriceBookName);
                        }
                    });
                    var pricebookFamilyList = [];
                    pricebookFamilyList.push({
                        key: '-- All Pricebook --',
                        value: ''
                    });

                    pricebookFamilySet.forEach(function(value) {
                        pricebookFamilyList.push({
                            key: value,
                            value: value
                        });
                    });
                    console.log('pricebookFamilyList ==> ',{pricebookFamilyList});
                    component.set("v.pricebookFamilyOptions", pricebookFamilyList);

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
                    console.log('productFamilyList ==> ',{productFamilyList});
                    component.set("v.productFamilyOptions", productFamilyList);
                    component.set("v.Spinner", false);
                }
            });
            $A.enqueueAction(action);
        } catch (error) {
            component.set("v.Spinner", false);
            console.log('error in goToProdModalHelper ' + error);
        }
    },

    goToEditModalHelper: function(component, event, helper) {
        try {
            console.log("in goToEditModalHelper");
            
            var quoteLineList = component.get("v.selectedRecords");
            console.log('quoteLineList => ',{quoteLineList});
            var selectedProducts = [];

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
                console.log("ELEMENT----->" , {element});
                selectedProducts.push({
                    'PriceBookEntryId':element.PriceBookEntryId,
                    'Id':element.Id,
                    'Name': element.Name,
                    'buildertek__Unit_Price__c': element.UnitPrice,
                    'buildertek__Cost_Code__c': element.CostCode,
                    'buildertek__Grouping__c': element.Phase ? element.Phase : noGroupingId,
                    'buildertek__Quantity__c': '1',
                    'buildertek__Additional_Discount__c': element.Discount ? element.Discount : 0,
                    'buildertek__Unit_Cost__c': element.UnitCost ? element.UnitCost : element.UnitPrice,
                    'buildertek__Markup__c': element.MarkUp ? element.MarkUp : 0,
                    'buildertek__Product__c': element.Id,
                    'buildertek__Size__c': element.Size,
                    'buildertek__Description__c': element.Description ? element.Description : element.Name,
                    'buildertek__Product_Family__c': element.Family ? element.Family : 'No Grouping',
                    'buildertek__UOM__c': element.QuantityUnitOfMeasure   
                })
                console.log('Quantity Unit Of Measure => ', element.QuantityUnitOfMeasure);
                console.log('Quantity Unit Of Measure New => ', element.CostCode);           
            });
            console.log('selectedProducts => ',{selectedProducts});
            component.set("v.selectedProducts", selectedProducts);
            if (selectedProducts.length > 0) {
                component.set("v.selectedProduct", false);
                component.set("v.selectedEdit", true);
            }else{
                component.set("v.selectedEdit", false);
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
        } catch (error) {
            console.log('error in goToEditModalHelper ::' + error);
        }
    },

    // save button
    saveQuoteLine : function(component, event, helper){
        try {
            component.set("v.Spinner", true);
            console.log('saveQuoteLine');
            var listQlines = component.get("v.selectedProducts");
            var flag=false;
            listQlines.forEach(function(elem){
                console.log({elem});
                console.log(elem.buildertek__Description__c);
                if(elem.buildertek__Description__c == '' || elem.buildertek__Description__c== undefined){
                    flag=true;
                }
            });
    
            console.log({flag});
            if(listQlines.length > 0 && flag== false){
                var action10 = component.get("c.QuoteLinesInsert");
                action10.setParams({
                    "Quotelines": listQlines,
                    "QuoteId": component.get("v.quoteId")
                });

                action10.setCallback(this, function(response) {
                    console.log(response.getReturnValue());
                    component.set("v.openQuoteLineBox", false);
                    $A.get("e.force:refreshView").fire();
                    component.set("v.Spinner", false);
                    component.set("v.openProductBoxwithVendor", false);        
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Success',
                        message: 'Quote Lines are created successfully',
                        duration: ' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                });
                $A.enqueueAction(action10);
            } else if(flag) {
                component.set("v.Spinner", false);
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Error',
                        message: 'Please select Description.',
                        duration: ' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
            } else {
                component.set("v.Spinner", false);
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
        } catch (error) {
            component.set("v.Spinner", false);
            console.log('error in saveQuoteLine :: ' + error);
        }
    }
})