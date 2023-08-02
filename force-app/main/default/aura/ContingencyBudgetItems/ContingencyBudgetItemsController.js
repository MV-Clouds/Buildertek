({
    doInit: function (component, event, helper) {
        var action = component.get("c.getContingencyBudgetItems");
        action.setParams({
            recordId: component.get('v.recordId'),
        });
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                var result = JSON.parse(response.getReturnValue());
                if (result.contingencyItemList != undefined) {
                    for (var i in result.contingencyItemList) {
                        if (result.contingencyItemList[i].buildertek__Is_Selected__c == undefined) {
                            result.contingencyItemList[i].buildertek__Is_Selected__c = false;
                        }
                        result.contingencyItemList[i].buildertek__Is_Selected__c = false;
                        
                        var revisedBudget = result.contingencyItemList[i].buildertek__Revised_Budget__c;
                        var commitedCost = result.contingencyItemList[i].buildertek__Committed_Costs__c;
                        var modificationBudget = result.contingencyItemList[i].buildertek__Budget_Modification__c;
                        var eligibleCost = result.contingencyItemList[i].buildertek__Eligible_Contingency_Amount__c;
                        if (revisedBudget != undefined) {
                            result.contingencyItemList[i].buildertek__Revised_Budget1__c = new Intl.NumberFormat('en-US', {
                                style: 'currency',
                                currency: 'USD'
                            }).format(revisedBudget)
                        }
                        if (modificationBudget != undefined) {
                            result.contingencyItemList[i].buildertek__Budget_Modification1__c = new Intl.NumberFormat('en-US', {
                                style: 'currency',
                                currency: 'USD'
                            }).format(modificationBudget)
                        }
                        if (commitedCost != undefined) {
                            result.contingencyItemList[i].buildertek__Committed_Costs1__c = new Intl.NumberFormat('en-US', {
                                style: 'currency',
                                currency: 'USD'
                            }).format(commitedCost)
                        }
                        if (eligibleCost != undefined) {
                            result.contingencyItemList[i].buildertek__Eligible_Contingency_Amount1__c = new Intl.NumberFormat('en-US', {
                                style: 'currency',
                                currency: 'USD'
                            }).format(eligibleCost)
                        }
                    }
                    component.set('v.contingencyItemList', result.contingencyItemList);
                }
                if (result.budgetItemList != undefined) {
                    for (var i in result.budgetItemList) {
                        var revisedBudget = result.budgetItemList[i].buildertek__Revised_Budget__c;
                        var commitedCost = result.budgetItemList[i].buildertek__Committed_Costs__c;
                        var modificationBudget = result.budgetItemList[i].buildertek__Budget_Modification__c;
                        var eligibleCost = result.budgetItemList[i].buildertek__Revised_Budget__c - result.budgetItemList[i].buildertek__Committed_Costs__c;
                        if (revisedBudget != undefined) {
                            result.budgetItemList[i].buildertek__Revised_Budget1__c = new Intl.NumberFormat('en-US', {
                                style: 'currency',
                                currency: 'USD'
                            }).format(revisedBudget)
                        }
                        if (modificationBudget != undefined) {
                            result.budgetItemList[i].buildertek__Budget_Modification1__c = new Intl.NumberFormat('en-US', {
                                style: 'currency',
                                currency: 'USD'
                            }).format(modificationBudget)
                        }
                        if (commitedCost != undefined) {
                            result.budgetItemList[i].buildertek__Committed_Costs1__c = new Intl.NumberFormat('en-US', {
                                style: 'currency',
                                currency: 'USD'
                            }).format(commitedCost)
                        }
                        if (eligibleCost != undefined) {
                            eligibleCost = eligibleCost < 0 ? 0 : eligibleCost;
                            result.budgetItemList[i].buildertek__Eligible_Costs1__c = new Intl.NumberFormat('en-US', {
                                style: 'currency',
                                currency: 'USD'
                            }).format(eligibleCost)
                        }
                    }
                    component.set('v.budgetItemList', result.budgetItemList);
                }
            } else {
                console.log('::Error::');
            }
        });
        $A.enqueueAction(action);
    },
    
    closeModel: function (component, event, helper) {
        component.set('v.isContingencyItemListSelected', false);
        component.set('v.isAmountToTransferOpen', false);
        component.set('v.note', '');
        component.set('v.enteredAmount', '');
        component.set('v.amountToTransfer', '');
        component.set('v.customModalCss', 'width: 90% !important;');
    },
    
    onItemSelect: function (component, event, helper) {
        var contingencyItemList = component.get('v.contingencyItemList');
        component.set('v.selectedContingencyId', contingencyItemList[event.target.dataset.index].Id);
        component.set('v.contingencyBudgetItem', contingencyItemList[event.target.dataset.index]);
        var count = 0;
        for (var i in contingencyItemList) {
            if (contingencyItemList[i].Id == event.target.dataset.id) {
                contingencyItemList[i].buildertek__Is_Selected__c = true;
                count++;
            } else {
                contingencyItemList[i].buildertek__Is_Selected__c = false;
            }
        }
        if (count == 1) {
            component.set('v.isContingencyItemListSelected', true);
        } else {
            component.set('v.isContingencyItemListSelected', false);
        }
        component.set('v.contingencyItemList', contingencyItemList);
    },
    
    onLeftClick: function (component, event, helper) {
        debugger;
        var budgetItemList = component.get('v.budgetItemList');
        var contingencyItemList = component.get('v.contingencyItemList');
        
        //if (budgetItemList[event.target.dataset.index].buildertek__Revised_Budget__c != undefined && budgetItemList[event.target.dataset.index].buildertek__Revised_Budget__c != undefined && budgetItemList[event.target.dataset.index].buildertek__Committed_Costs__c != undefined && budgetItemList[event.target.dataset.index].buildertek__Revised_Budget__c - budgetItemList[event.target.dataset.index].buildertek__Committed_Costs__c <= 0) {
        for (var i in contingencyItemList) {
            if (contingencyItemList[i].buildertek__Is_Selected__c != undefined && contingencyItemList[i].buildertek__Is_Selected__c) {
                component.set('v.amountToTransfer', contingencyItemList[i].buildertek__Revised_Budget__c);
                component.set('v.transferFrom', contingencyItemList[i].Name);
                component.set('v.transferTo', budgetItemList[event.target.dataset.index].Name);
            }
        }
        if (component.get('v.isContingencyItemListSelected')) {
            component.set('v.isAmountToTransferOpen', true);
            component.set('v.isLeftToRight', true);
            component.set('v.isRightToLeft', false);
            component.set('v.customModalCss', 'width: 40rem !important;max-width: 40rem !important;');
            component.set('v.budgetLineItemId', budgetItemList[event.target.dataset.index].Id);
            component.set('v.budgetLineItem', budgetItemList[event.target.dataset.index]);
        } else {
            helper.showErrorToast(component, event, helper, 'Error!', 'Please Select Contingency Budget Item!');
        }
        //}
    },
    
    onRightClick: function (component, event, helper) {
        debugger;
        var budgetItemList = component.get('v.budgetItemList');
        var contingencyItemList = component.get('v.contingencyItemList');
        if (budgetItemList[event.target.dataset.index].buildertek__Revised_Budget__c != undefined && budgetItemList[event.target.dataset.index].buildertek__Revised_Budget__c > 0) {
            for (var i in contingencyItemList) {
                if (contingencyItemList[i].buildertek__Is_Selected__c != undefined && contingencyItemList[i].buildertek__Is_Selected__c) {
                    component.set('v.transferFrom', budgetItemList[event.target.dataset.index].Name);
                    component.set('v.transferTo', contingencyItemList[i].Name);
                }
            }
            if (component.get('v.isContingencyItemListSelected')) {
                component.set('v.isAmountToTransferOpen', true);
                component.set('v.isRightToLeft', true);
                component.set('v.isLeftToRight', false);
                component.set('v.customModalCss', 'width: 40rem !important;max-width: 40rem !important;');
                component.set('v.amountToTransfer', budgetItemList[event.target.dataset.index].buildertek__Revised_Budget__c);
                component.set('v.budgetLineItemId', budgetItemList[event.target.dataset.index].Id);
                component.set('v.budgetLineItem', budgetItemList[event.target.dataset.index]);
            } else {
                helper.showErrorToast(component, event, helper, 'Error!', 'Please Select Contingency Budget Item!');
            }
        }
    },
    
    moveAmount: function (component, event, helper) {
        debugger;
        var amount = component.get('v.enteredAmount');
        var note = component.get('v.note');
        var totalAmount = component.get('v.amountToTransfer');
        if (amount == undefined || amount == '') {
            helper.showErrorToast(component, event, helper, 'Error!', 'Please Enter Amount!');
            return;
        }
        
        if (note == undefined || note == '') {
            helper.showErrorToast(component, event, helper, 'Error!', 'Please Enter Notes!');
            return;
        }
        
        if (amount <= 0 || totalAmount < amount) {
            helper.showErrorToast(component, event, helper, 'Error!', 'You cannot transfer more than the Eligible Amount.');
            return;
        }
        
        helper.moveAmountToContingency(component, event, helper);
    },
})