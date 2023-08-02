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
        var action = component.get("c.ProductsthroughPB");
        action.setParams({
            pbookId : priceBookId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var productList = response.getReturnValue();
                console.log('productList: ', productList);

                var familySet = new Set();
                for(var i = 0; i < productList.length; i++) {
                    familySet.add(productList[i].Family);
                }
                var familyList = [];
                familyList.push({
                    label: '--All Families--',
                    value: ''
                });
                familySet.forEach(function(item) {
                    if(item != null || item != undefined){
                        familyList.push({
                            label: item,
                            value: item
                        });
                    }
                }
                );
                console.log('familyList: ', familyList);
                var budgetLineWrapperList = component.get("v.budgetLineWrapperList");
                budgetLineWrapperList[index].productFamilyList = familyList;
                budgetLineWrapperList[index].ProductList = productList;
                var productOptionList = [];
                if(productList.length > 0) {
                    productOptionList.push({
                        label: 'Please Select Product',
                        value: ''
                    });
                    for(var i = 0; i < productList.length; i++) {
                        productOptionList.push({
                            label: productList[i].Name,
                            value: productList[i].Id
                        });
                    }
                } 
                budgetLineWrapperList[index].productOptionList = productOptionList;
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
                console.log('budgetLineWrapperList: ', budgetLineWrapperList);
                component.set("v.isLoading", false);
            }
        });
        $A.enqueueAction(action);
    },

    getProduct : function(component, event, helper, family, index) {
        var budgetLineWrapperList = component.get("v.budgetLineWrapperList");
        var productList = budgetLineWrapperList[index].ProductList;
        var productOptionList = [
            {
                label: 'Please Select Product',
                value: ''
            }
        ];
        productList.forEach(function(item) {
            if(item.Family == family) {
                productOptionList.push({
                    label: item.Name,
                    value: item.Id
                });
            }
        });
        budgetLineWrapperList[index].productOptionList = productOptionList;
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
        component.set("v.isLoading", false);
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
                // console.log('vendorList: ', component.get("v.vendorList"));
            }
        }
        );
        $A.enqueueAction(action);
    },

    gotProduct : function(component, event, helper, productId, index) {
        var budgetLineGroups = component.get("v.budgetLineGroups");
        var noGroupingId;
        for(var i = 0; i < budgetLineGroups.length; i++) {
            if(budgetLineGroups[i].Name == 'No Grouping') {
                noGroupingId = budgetLineGroups[i].Id;
            }
        }
        console.log('productId: ', productId);
        var budgetlineWrapperList = component.get("v.budgetLineWrapperList");
        var ProductList = budgetlineWrapperList[index].ProductList;
        budgetlineWrapperList[index].GroupingOptions = component.get("v.budgetLineGroups");
        for(var i = 0; i < ProductList.length; i++) {
            if(ProductList[i].Id == productId) {
                budgetlineWrapperList[index].BudgetLine = {
                    buildertek__Budget__c : component.get("v.recordId"),
                    buildertek__Product__c : productId,
                    Name : ProductList[i].Name,
                    buildertek__Group__c : noGroupingId,
                    buildertek__Quantity__c : '1',
                    buildertek__UOM__c : '',
                    buildertek__Contractor__c : '',
                    buildertek__Unit_Price__c : ProductList[i].UnitPrice,
                }
            }
        }
        component.set("v.budgetLineWrapperList", budgetlineWrapperList);
        component.set("v.isLoading", false);
    },

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
                //close modal
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Budget Line(s) Saved Successfully',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'dismissible'
                });
                toastEvent.fire();
                component.set("v.isLoading", false);
                helper.closeNrefresh(component, event, helper);
            } else {
                component.set("v.isLoading", false);
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
                    // $A.get('e.force:refreshView').fire();
                    window.location.reload();
                }), 1000
            );
    },

    




})