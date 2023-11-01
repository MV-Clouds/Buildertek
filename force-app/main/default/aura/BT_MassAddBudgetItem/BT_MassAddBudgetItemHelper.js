({
    nameTheTab : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then((response) => {
            let opendTab = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: opendTab,
                label: "Mass Add Line"
            });
            workspaceAPI.setTabIcon({
                tabId: opendTab,
                icon: 'custom:custom5',
                iconAlt: 'Mass Add Line'
            });
        });
    },

    createBudgetLineWrapper : function(component, event, helper) {

        var budgetLineWrapper = {
            pricebookEntryId : '',
            productFamily : '',
            Product : '',
            ProductName : '',
            BudgetLine : {
                buildertek__Budget__c : component.get("v.recordId"),
                buildertek__Product__c : '',
                Name : '',
                buildertek__Group__c : '',
                buildertek__UOM__c : '',
                buildertek__Contractor__c : '',
                buildertek__Quantity__c : '1',
                buildertek__Unit_Price__c : '',
            },
            productFamilyList : [],
            ProductList : [],
            productOptionList : [],            
        };

        return budgetLineWrapper;
        
    },

    createBudgetItemWrapperList : function(component, event, helper) {
        console.log('=============createBudgetItemWrapperList===============');
        var budgetLineWrapperList = [];
        for(var i = 0; i < 5; i++) {
            budgetLineWrapperList.push(helper.createBudgetLineWrapper(component, event, helper));
        }
        console.log('budgetLineWrapperList: ', budgetLineWrapperList);
        component.set("v.budgetLineWrapperList", budgetLineWrapperList);
        

    },

    getBudgetLineGroups : function(component, event, helper) {
        var action = component.get("c.getBudgetLineGroups");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var budgetLineGroups = response.getReturnValue();
                console.log('budgetLineGroups: ', budgetLineGroups);
                component.set("v.budgetLineGroups", budgetLineGroups);
            }
        });
        $A.enqueueAction(action);
    },

    getFamily : function(component, event, helper, priceBookId, index) {

        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire(); 

        console.log('Helper....');
        var action = component.get("c.getProductfamilyRecords");
        action.setParams({
                'ObjectName': "Product2",
                'parentId': priceBookId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(response.getError());
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result', result);
                
                var familySet = new Set();
                for(var i = 0; i < result.length; i++) {
                    familySet.add(result[i].productfamilyvalues);
                }
                console.log({familySet});
                //create a list of family where we have label and value
                var familyList = [];
                familyList.push({
                    label : '-- All Families --',
                    value : 'All Families'
                });
                familySet.forEach(function(family) {
                    if(family){
                        familyList.push({
                            label : family,
                            value : family
                        });
                    }
                });
                var budgetLineWrapperList = component.get('v.budgetLineWrapperList');
                
                budgetLineWrapperList[index].productFamilyList = familyList;
                budgetLineWrapperList[index].selectedLookUpRecord = {};
                budgetLineWrapperList[index].BudgetLine = {
                    buildertek__Budget__c : component.get('v.recordId'),
                    buildertek__Product__c : '',
                    Name : '',
                    buildertek__Group__c : '',
                    buildertek__UOM__c : '',
                    buildertek__Quantity__c : '',
                    buildertek__Unit_Price__c : '',
                    buildertek__Contractor__c : '',
                    // buildertek__Markup__c : '',
                }
                component.set('v.budgetLineWrapperList', budgetLineWrapperList);
                // console.log('budgetLineWrapperList', budgetLineWrapperList);

                component.set("v.DefaultproductFamilyList", familyList);

                 $A.get("e.c:BT_SpinnerEvent").setParams({
                    "action": "HIDE"
                }).fire();

            } else if (state === "ERROR") {
                console.log('A Problem Occurred: ' + JSON.stringify(response.error));
                var toast = $A.get("e.force:showToast");
                toast.setParams({
                    title: "Error",
                    message: "A Problem Occurred: " + JSON.stringify(response.error),
                    type: "error"
                });
                toast.fire();
                 $A.get("e.c:BT_SpinnerEvent").setParams({
                    "action": "HIDE"
                }).fire();
            }
        }); 
        $A.enqueueAction(action);

        // var action = component.get("c.ProductsthroughPB");
        // action.setParams({
        //     pbookId : priceBookId
        // });
        // action.setCallback(this, function(response) {
        //     var state = response.getState();
        //     if(state === "SUCCESS") {
        //         var productList = response.getReturnValue();
        //         console.log('productList: ', productList);

        //         var familySet = new Set();
        //         for(var i = 0; i < productList.length; i++) {
        //             familySet.add(productList[i].Family);
        //         }
        //         var familyList = [];
        //         familyList.push({
        //             label: '--All Families--',
        //             value: ''
        //         });
        //         familySet.forEach(function(item) {
        //             if(item != null || item != undefined){
        //                 familyList.push({
        //                     label: item,
        //                     value: item
        //                 });
        //             }
        //         }
        //         );
        //         console.log('familyList: ', familyList);
        //         var budgetLineWrapperList = component.get("v.budgetLineWrapperList");
        //         budgetLineWrapperList[index].productFamilyList = familyList;
        //         budgetLineWrapperList[index].ProductList = productList;
        //         var productOptionList = [];
        //         if(productList.length > 0) {
        //             productOptionList.push({
        //                 label: 'Please Select Product',
        //                 value: ''
        //             });
        //             for(var i = 0; i < productList.length; i++) {
        //                 productOptionList.push({
        //                     label: productList[i].Name,
        //                     value: productList[i].Id
        //                 });
        //             }
        //         } 
        //         budgetLineWrapperList[index].productOptionList = productOptionList;
        //         budgetLineWrapperList[index].BudgetLine = {
        //             buildertek__Budget__c : component.get("v.recordId"),
        //             buildertek__Product__c : '',
        //             Name : '',
        //             buildertek__Group__c : '',
        //             buildertek__Quantity__c : '1',
        //             buildertek__UOM__c : '',
        //             buildertek__Contractor__c : '',
        //             buildertek__Unit_Price__c : '',
        //         }
        //         component.set("v.budgetLineWrapperList", budgetLineWrapperList);
        //         console.log('budgetLineWrapperList: ', budgetLineWrapperList);
        //         $A.get("e.c:BT_SpinnerEvent").setParams({
        //             "action": "HIDE"
        //         }).fire(); 
        //     }
        // });
        // $A.enqueueAction(action);
    },

    getProduct : function(component, event, helper, index) {
        
        var budgetLineWrapperList = component.get("v.budgetLineWrapperList");
        budgetLineWrapperList[index].selectedLookUpRecord = {}
        budgetLineWrapperList[index].BudgetLine = {
            buildertek__Budget__c : component.get("v.recordId"),
            buildertek__Product__c : '',
            Name : '',
            buildertek__Group__c : '',
            buildertek__Quantity__c : '1',
            buildertek__UOM__c : '',
            buildertek__Contractor__c : '',
            buildertek__Unit_Price__c : '',
        }

        component.set("v.budgetLineWrapperList", budgetLineWrapperList);
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "HIDE"
        }).fire(); 
    },

    getAccounts : function(component, event, helper) {
        var action = component.get("c.getAccounts");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var accounts = response.getReturnValue();
                var vendorList = [];
                vendorList.push({
                    label: '--Select Vendor--',
                    value: ''
                });
                for(var i = 0; i < accounts.length; i++) {
                    vendorList.push({
                        label: accounts[i].Name,
                        value: accounts[i].Id
                    });
                }
                component.set("v.vendorList", vendorList);
            }
        }
        );
        $A.enqueueAction(action);
    },

    // gotProduct : function(component, event, helper, productId, index) {
    //     var budgetLineGroups = component.get("v.budgetLineGroups");
    //     var noGroupingId;
    //     for(var i = 0; i < budgetLineGroups.length; i++) {
    //         if(budgetLineGroups[i].Name == 'No Grouping') {
    //             noGroupingId = budgetLineGroups[i].Id;
    //         }
    //     }
    //     console.log('productId: ', productId);
    //     var budgetlineWrapperList = component.get("v.budgetLineWrapperList");
    //     var ProductList = budgetlineWrapperList[index].ProductList;
    //     budgetlineWrapperList[index].GroupingOptions = component.get("v.budgetLineGroups");
    //     for(var i = 0; i < ProductList.length; i++) {
    //         if(ProductList[i].Id == productId) {
    //             budgetlineWrapperList[index].BudgetLine = {
    //                 buildertek__Budget__c : component.get("v.recordId"),
    //                 buildertek__Product__c : productId,
    //                 Name : ProductList[i].Name,
    //                 buildertek__Group__c : noGroupingId,
    //                 buildertek__Quantity__c : '1',
    //                 buildertek__UOM__c : '',
    //                 buildertek__Contractor__c : '',
    //                 buildertek__Unit_Price__c : ProductList[i].UnitPrice,
    //             }
    //         }
    //     }
    //     component.set("v.budgetLineWrapperList", budgetlineWrapperList);
    //     $A.get("e.c:BT_SpinnerEvent").setParams({
    //         "action": "HIDE"
    //     }).fire(); 
    // },

    saveBudgetLine : function(component, event, helper,budgetLineList) {
        console.log('budgetLineList: ', budgetLineList);
        debugger;
        var action = component.get("c.saveBudgetLine");
        action.setParams({
            budgetLineList : budgetLineList
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var toast = $A.get("e.force:showToast");
                toast.setParams({
                    title: "Success",
                    message: "Budget Line Saved Successfully",
                    type: "success"
                });
                toast.fire();
                $A.get("e.c:BT_SpinnerEvent").setParams({
                    "action": "HIDE"
                }).fire();     
                helper.closeNrefresh(component, event, helper);
            } else {
                $A.get("e.c:BT_SpinnerEvent").setParams({
                    "action": "HIDE"
                }).fire(); 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message: 'Budget Line(s) Not Saved',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'dismissible'
                });
                toastEvent.fire();

            }
        }
        );
        $A.enqueueAction(action);

    },

    getUOM : function(component, event, helper) {
        var action = component.get("c.getPicklistValues");
        action.setParams({
            objectName : 'buildertek__Budget_Item__c',
            fieldName : 'buildertek__UOM__c'
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var uomList = response.getReturnValue();
                var uomOptionList = [];
                uomOptionList.push({
                    label: '--Select UOM--',
                    value: ''
                });
                for(var i = 0; i < uomList.length; i++) {
                    uomOptionList.push({
                        label: uomList[i],
                        value: uomList[i]
                    });
                }
                component.set("v.uomOptionList", uomOptionList);
                console.log('uomOptionList: ', component.get("v.uomOptionList"));
            }
        }
        );
        $A.enqueueAction(action);
    },

    closeNrefresh : function(component, event, helper) {
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function (response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({
                    tabId: focusedTabId
                });
            }) 
         
            .catch(function (error) {
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": component.get('v.recordId'),
                    "slideDevName": "related"
                });
                navEvt.fire();
            });
            $A.get("e.force:closeQuickAction").fire();
            window.setTimeout(
                $A.getCallback(function () {
                    $A.get('e.force:refreshView').fire();
                    window.location.reload();
                }), 1000
            );
    },
    getProductDetails: function(component, event, helper , productId, priceBookIdList) {

        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire(); 


        var budgetLineWrapperList = component.get("v.budgetLineWrapperList");
        console.log({budgetLineWrapperList});
        var action = component.get("c.getProductPrice");
        action.setParams({
            "productId": productId,
            pricebookId: priceBookIdList
        });
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            var state= response.getState();
            var priceBookEntryWrap=result.priceBookList[0];
            var productWrap=result.productList;

            console.log({result});
            $A.get("e.c:BT_SpinnerEvent").setParams({
                "action": "HIDE"
            }).fire();
            if(state === 'SUCCESS'){

                const setBudgetLineWrapper= (pricebookList , index)=>{
                    console.log(budgetLineWrapperList[index]);
                    budgetLineWrapperList[index].BudgetLine.buildertek__Unit_Price__c=pricebookList.buildertek__Unit_Cost__c;
                    budgetLineWrapperList[index].BudgetLine.Name=pricebookList.Product2.Name;
                    budgetLineWrapperList[index].BudgetLine.buildertek__Quantity__c = 1;
                    budgetLineWrapperList[index].BudgetLine.buildertek__Contractor__c = pricebookList.Product2.buildertek__Vendor__c;
                    console.log(component.get("v.budgetLineGroups"));
                    budgetLineWrapperList[index].GroupingOptions = component.get("v.budgetLineGroups");

                    if(pricebookList.Product2.buildertek__Group__c !=undefined && pricebookList.Product2.buildertek__Group__c !='') {
                        budgetLineWrapperList[index].BudgetLine.buildertek__Group__c=pricebookList.Product2.buildertek__Group__c;
                    }else {
                        var GroupingOptions = component.get('v.budgetLineGroups');
                        for(var i = 0; i < GroupingOptions.length; i++) {
                            if(GroupingOptions[i].Name == 'No Grouping') {
                                budgetLineWrapperList[index].BudgetLine.buildertek__Group__c = GroupingOptions[i].Id;
                            }
                        }
                    }

                    
                   
                    
                    component.set("v.budgetLineWrapperList" , budgetLineWrapperList);
                }

                if(priceBookEntryWrap != undefined){
                    budgetLineWrapperList.forEach(function(value , index){
                        if(value.pricebookEntryId===priceBookEntryWrap.Pricebook2Id && value.Product===priceBookEntryWrap.Product2Id){
                            setBudgetLineWrapper(priceBookEntryWrap , index);
                        }
                    })
                }else{
                    budgetLineWrapperList.forEach(function(value , index){
                        const productWrapper = productWrap.find(subvalue => subvalue.Id === value.Product);
                        if (productWrapper) {
                            const createObj = {
                                UnitPrice: '',
                                Product2: {
                                    Name: productWrapper.Name
                                },
                                Product2Id: productWrapper.Id
                            };
                            setBudgetLineWrapper(createObj, index);
                        }          
                    })

                }
            }
            
        });
        $A.enqueueAction(action);
    
    },

    getPricebooks:function(component, event, helper) {
        var action = component.get("c.getpricebooks");
        action.setParams({
            "recordId" : recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {

                var result = response.getReturnValue();
                console.log({result});
                let projectHavePricebook=result[0].defaultValue;
                console.log(projectHavePricebook);

                var pricebookOptions = [];
                var budgetlineWrapperList = component.get("v.budgetLineWrapperList");
                
                pricebookOptions.push({ key: "", value: "None" });
                for(var key in result[0].priceWrapList){
                    pricebookOptions.push({key: result[0].priceWrapList[key].Id, value: result[0].priceWrapList[key].Name});
                }
                console.log(pricebookOptions);


                if(Object.keys(projectHavePricebook).length !=0){
                    budgetlineWrapperList.forEach(function(value , index){
                        console.log(index);
                        value.pricebookEntryId=projectHavePricebook.Id;
                        budgetlineWrapperList.push(value);
                     }); 
                }
                component.set("v.pricebookOptions", pricebookOptions);
                component.set("v.budgetlineWrapperList", budgetlineWrapperList);


                console.log(component.get('v.budgetLineWrapperList'));
               
                

                for(var key in budgetlineWrapperList){
                    if(budgetlineWrapperList[key].pricebookEntryId != undefined){                            
                        helper.getFamily(component, event, helper, budgetlineWrapperList[key].pricebookEntryId, key);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    

})