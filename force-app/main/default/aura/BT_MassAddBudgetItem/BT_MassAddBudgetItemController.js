({
    doInit : function(component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire(); 
        var recordId = component.get("v.recordId");
        console.log('recordId: ' + recordId);
        helper.nameTheTab(component, event, helper);
        helper.createBudgetItemWrapperList(component, event, helper);
        helper.getBudgetLineGroups(component, event, helper);
        helper.getAccounts(component, event, helper);
        helper.getUOM(component, event, helper);
        var action = component.get("c.getpricebooks");
        action.setParams({
            "recordId" : recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var result = response.getReturnValue();
                let projectHavePricebook=result[0].defaultValue;
                var pricebookOptions = [];
                var budgetlineWrapperList = component.get("v.budgetLineWrapperList");


                if(Object.keys(projectHavePricebook).length !=0){

                    pricebookOptions.push({ key: projectHavePricebook.Name, value: projectHavePricebook.Id });
                    result[0].priceWrapList.forEach(function(element){
                        if(projectHavePricebook.Id !== element.Id){
                            pricebookOptions.push({ key: element.Name, value: element.Id });
                        }else{
                            pricebookOptions.push({ key: "None", value: "" });
                        }
                    });
                    component.set('v.selectedPricebook' , projectHavePricebook.Id);

                    for(var key in budgetlineWrapperList){
                        budgetlineWrapperList[key].pricebookEntryId=projectHavePricebook.Id;
                    }

                }else{
                    pricebookOptions.push({ key: "None", value: "" });
                    result[0].priceWrapList.forEach(function(element){
                        pricebookOptions.push({ key: element.Name, value: element.Id });
                    });
                }

                component.set("v.pricebookOptions", pricebookOptions);
                console.log(component.get("v.pricebookOptions"));


                console.log(budgetlineWrapperList);

                for(var key in budgetlineWrapperList){
                    // console.log(budgetlineWrapperList[key].pricebookEntryId);
                    if(budgetlineWrapperList[key].pricebookEntryId != undefined){                            
                        helper.getFamily(component, event, helper, budgetlineWrapperList[key].pricebookEntryId, key);
                    }
                }
                // if(component.get('v.selectedPricebook')!= undefined){
                //     var selectedPricebookId = component.find("selectedPricebookId").get("v.value");
                //     helper.getFamily(component, event, helper , selectedPricebookId , );
                // }else{
                //     component.set('v.Spinner', false);    
                // }
                
                // var pricebookList = response.getReturnValue();
                // console.log('pricebooks: ', pricebookList); 
                // var pricebookOptions = [];
                // pricebookOptions.push({
                //     label: 'None',
                //     value: ''
                // });
                // for(var i = 0; i < pricebookList[0].priceWrapList.length; i++) {
                //     pricebookOptions.push({
                //         label: pricebookList[0].priceWrapList[i].Name,
                //         value: pricebookList[0].priceWrapList[i].Id
                //     });
                // }
                // if(pricebookList[0].defaultValue != ''){
                //     console.log('pricebookList[0].defaultValue: ', pricebookList[0].defaultValue);
                //     component.set("v.selectedPricebook", pricebookList[0].defaultValue.Id);
                //     var action1 = component.get("c.ProductsthroughPB");
                //     action1.setParams({
                //         pbookId : pricebookList[0].defaultValue.Id
                //     });
                //     action1.setCallback(this, function(response) {
                //         var state = response.getState();
                //         if(state === "SUCCESS") {
                //             var productList = response.getReturnValue();
                //             console.log('productList: ', productList);
                            
                //             var familyset = new Set();
                //             var familySet = new Set();
                //             for(var i = 0; i < productList.length; i++) {
                //                 familySet.add(productList[i].Family);
                //             }
                //             var familyList = [];
                //             familyList.push({
                //                 label: '--All Families--',
                //                 value: ''
                //             });
                //             familySet.forEach(function(item) {
                //                 if(item != null || item != undefined){
                //                     familyList.push({
                //                         label: item,
                //                         value: item
                //                     });
                //                 }
                //             }
                //             );
                //             console.log('familyList: ', familyList);
                //             var productOptionList = [];
                //             if(productList.length > 0) {
                //                 productOptionList.push({
                //                     label: 'Please Select Product',
                //                     value: ''
                //                 });
                //                 for(var i = 0; i < productList.length; i++) {
                //                     productOptionList.push({
                //                         label: productList[i].Name,
                //                         value: productList[i].Id
                //                     });
                //                 }
                //             } 
                //             var budgetlineWrapperList = component.get("v.budgetLineWrapperList");
                //             for(var i = 0; i < budgetlineWrapperList.length; i++) {
                //                 budgetlineWrapperList[i].productFamilyList = familyList;
                //                 budgetlineWrapperList[i].productOptionList = productOptionList;
                //                 budgetlineWrapperList[i].ProductList = productList;
                //             }
                //             component.set("v.DefaultproductFamilyList", familyList);
                //             component.set("v.DefaultproductOptionList", productOptionList);
                //             component.set("v.budgetLineWrapperList", budgetlineWrapperList);

                //             $A.get("e.c:BT_SpinnerEvent").setParams({
                //                 "action": "HIDE"
                //             }).fire(); 
                //         }
                //     });
                //     $A.enqueueAction(action1);
                // }else{A
                //     component.set("v.selectedPricebook", '');
                //     $A.get("e.c:BT_SpinnerEvent").setParams({
                //         "action": "HIDE"
                //     }).fire(); 


                // }
                // component.set("v.pricebookOptions", pricebookOptions);

                // for(var key in budgetlineWrapperList){
                //     if(budgetlineWrapperList[key].pricebookEntryId != undefined){                            
                //         helper.getFamily(component, event, helper, budgetlineWrapperList[key].pricebookEntryId, key);
                //     }
                // }
            }
        });
        $A.enqueueAction(action);


    },

    getFamily : function(component, event, helper) {
        
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire(); 

        var index = event.getSource().get("v.name");
        console.log('index: ', index);
        var priceBookId = component.get("v.budgetLineWrapperList")[index].pricebookEntryId;
        if(priceBookId != '') {
            helper.getFamily(component, event, helper, priceBookId, index);
        }else{
            var budgetlineWrapperList = component.get("v.budgetLineWrapperList");
            budgetlineWrapperList[index].productFamilyList = [
                {
                    label : 'None',
                    value : '',
                }];
            budgetlineWrapperList[index].selectedLookUpRecord = {};

            budgetlineWrapperList[index].BudgetLine = {
                buildertek__Budget__c : component.get("v.recordId"),
                buildertek__Product__c : '',
                Name : '',
                buildertek__Group__c : '',
                buildertek__Quantity__c : '',
                buildertek__UOM__c : '',
                buildertek__Contractor__c : '',
                buildertek__Unit_Price__c : '',
            };
            component.set("v.budgetLineWrapperList", budgetlineWrapperList);
            $A.get("e.c:BT_SpinnerEvent").setParams({
                "action": "HIDE"
            }).fire();      
        }
    },
    

    getProduct : function(component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire(); 
        var budgetlineWrapperList = component.get("v.budgetLineWrapperList");
        var index = event.getSource().get("v.name");
        var family = budgetlineWrapperList[index].productFamily;
        console.log('family: ', family);
        if(family!=''){
            helper.getProduct(component, event, helper, family, index);
        }else{
            console.log('family is empty');
            var productList = budgetlineWrapperList[index].ProductList;
            var productOptionList =[
                {
                    label: 'Please Select Product',
                    value: ''
                }
            ];
            for(var i = 0; i < productList.length; i++) {
                productOptionList.push({
                    label: productList[i].Name,
                    value: productList[i].Id
                });
            }
            budgetlineWrapperList[index].productOptionList = productOptionList;
            budgetlineWrapperList[index].BudgetLine = {
                buildertek__Budget__c : component.get("v.recordId"),
                buildertek__Product__c : '',
                Name : '',
                buildertek__Group__c : '',
                buildertek__Quantity__c : '',
                buildertek__UOM__c : '',
                buildertek__Contractor__c : '',
                buildertek__Unit_Price__c : '',
            }
            component.set("v.budgetLineWrapperList", budgetlineWrapperList);

            $A.get("e.c:BT_SpinnerEvent").setParams({
                "action": "HIDE"
            }).fire(); 
        }


    },

    // gotProduct : function(component, event, helper) {
    //     $A.get("e.c:BT_SpinnerEvent").setParams({
    //         "action": "SHOW"
    //     }).fire(); 

    //     var index = event.getSource().get("v.name");
    //     var productId = component.get("v.budgetLineWrapperList")[index].productId;
    //     if(productId != '') {
    //         helper.gotProduct(component, event, helper, productId, index);
    //     }else{
    //         var budgetlineWrapperList = component.get("v.budgetLineWrapperList");
    //         budgetlineWrapperList[index].BudgetLine = {
    //             buildertek__Budget__c : component.get("v.recordId"),
    //             buildertek__Product__c : '',
    //             Name : '',
    //             buildertek__Group__c : '',
    //             buildertek__Quantity__c : '',
    //             buildertek__UOM__c : '',
    //             buildertek__Contractor__c : '',
    //             buildertek__Unit_Price__c : '',
    //         };
    //         component.set("v.budgetLineWrapperList", budgetlineWrapperList);
    //         $A.get("e.c:BT_SpinnerEvent").setParams({
    //             "action": "HIDE"
    //         }).fire(); 
    //     }
    // },

    onCancel : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then((response) => {
            let opendTab = response.tabId;
            workspaceAPI.closeTab({tabId: opendTab});
        });
    },

    onAddClick : function(component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire(); 

        var budgetLineWrapperList = component.get("v.budgetLineWrapperList");
        for(var i = 0; i < 2; i++) {
            let budgetLineWrapper = helper.createBudgetLineWrapper(component, event, helper);
            budgetLineWrapperList.push(budgetLineWrapper);
        }
        component.set("v.budgetLineWrapperList", budgetLineWrapperList);
        let bugetLineWrap= component.get('v.budgetLineWrapperList');
        for(var i=bugetLineWrap.length-2;i<bugetLineWrap.length;i++){
            bugetLineWrap[i].pricebookEntryId = component.get('v.selectedPricebook');
            helper.getFamily(component, event, helper, component.get('v.selectedPricebook'), i);
        }
       
       
    },

    deleteRow : function(component, event, helper) {
        var index = event.target.getAttribute('data-index');
        var budgetLineWrapperList = component.get("v.budgetLineWrapperList");
        budgetLineWrapperList.splice(index, 1);
        component.set("v.budgetLineWrapperList", budgetLineWrapperList);
    },

    onMassUpdate : function(component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire(); 
        var budgetLineWrapperList = component.get("v.budgetLineWrapperList");
        var budgetLineList = [];
        for(var i = 0; i < budgetLineWrapperList.length; i++) {
            if(budgetLineWrapperList[i].BudgetLine.Name != '') {
                budgetLineList.push(budgetLineWrapperList[i].BudgetLine);
            }
        }
        if(budgetLineList.length > 0) {
            //iterate over budgetLineList and check if any budgetLine has quantity in decimal and if yes then show error, also check if the unit cost has more than 2 decimal places and if yes then show error
            var isDecimal = false;
            var isUnitCostDecimal = false;
            for(var i = 0; i < budgetLineList.length; i++) {
                if(budgetLineList[i].buildertek__Quantity__c != undefined && budgetLineList[i].buildertek__Quantity__c != null && budgetLineList[i].buildertek__Quantity__c != '') {
                    var quantity = budgetLineList[i].buildertek__Quantity__c;
                    var quantityString = quantity.toString();
                    if(quantityString.includes('.')) {
                        isDecimal = true;
                        break;
                    }
                }
                if(budgetLineList[i].buildertek__Unit_Price__c != undefined && budgetLineList[i].buildertek__Unit_Price__c != null && budgetLineList[i].buildertek__Unit_Price__c != '') {
                    var unitCost = budgetLineList[i].buildertek__Unit_Price__c;
                    var unitCostString = unitCost.toString();
                    if(unitCostString.includes('.')) {
                        var unitCostDecimal = unitCostString.split('.')[1];
                        if(unitCostDecimal.length > 2) {
                            isUnitCostDecimal = true;
                            break;
                        }
                    }
                }
            }
            if(isDecimal) {
                $A.get("e.c:BT_SpinnerEvent").setParams({
                    "action": "HIDE"
                }).fire(); 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Error',
                    message: 'Quantity cannot be in decimal.',
                    duration: ' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
                return;
            }
            if(isUnitCostDecimal) {
                $A.get("e.c:BT_SpinnerEvent").setParams({
                    "action": "HIDE"
                }).fire(); 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Error',
                    message: 'Unit Cost cannot have more than 2 decimal places.',
                    duration: ' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
                return;
            }
            helper.saveBudgetLine(component, event, helper, budgetLineList);
        }else{
            $A.get("e.c:BT_SpinnerEvent").setParams({
                "action": "HIDE"
            }).fire(); 
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Error',
                message: 'Please enter atleast one BudgetLine.',
                duration: ' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }

    },
    handleComponentEvent: function(component, event, helper) {
        console.log('handleComponentEvent');
        console.log( component.get("v.budgetLineWrapperList"));
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        component.set('v.selectedRecordMap' , selectedAccountGetFromEvent.Id);

        var productId=component.get('v.selectedRecordMap');
        var priceBookIdList=[];
        var budgetLineWrapperList = component.get("v.budgetLineWrapperList");

        budgetLineWrapperList.forEach(function(value, index){
            if(value.selectedLookUpRecord){
                if(value.selectedLookUpRecord.Id == productId){
                    budgetLineWrapperList[index].Product=productId;
                    budgetLineWrapperList[index].BudgetLine.buildertek__Product__c=productId;
                    priceBookIdList.push(value.pricebookEntryId);
                }
            }
        });
        helper.getProductDetails(component, event, helper , productId, priceBookIdList);
    },

})