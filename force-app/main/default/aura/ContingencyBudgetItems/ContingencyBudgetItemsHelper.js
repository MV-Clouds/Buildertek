({
    showErrorToast: function (component, event, helper, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            duration: '3000',
            type: 'error',
            mode: 'pester'
        });
        toastEvent.fire();
    },

    moveAmountToContingency: function (component, event, helper) {
        var amount = component.get('v.enteredAmount');
        var budgetLineId = component.get('v.budgetLineItemId');
        var contingencyId = component.get('v.selectedContingencyId');
        var budgetId = component.get('v.recordId');
        var note = component.get('v.note');
        var budgetLineItem = component.get('v.budgetLineItem');
        var contingencyBudgetItem = component.get('v.contingencyBudgetItem');
        var budgetAmount = 0;
        var contingencyAmount = 0;

        if (component.get('v.isLeftToRight')) {
            budgetLineItem.buildertek__Amount_In__c = budgetLineItem.buildertek__Amount_In__c == undefined ? 0 : budgetLineItem.buildertek__Amount_In__c;
            contingencyBudgetItem.buildertek__Amount_Out_2__c = contingencyBudgetItem.buildertek__Amount_Out_2__c == undefined ? 0 : contingencyBudgetItem.buildertek__Amount_Out_2__c;
            budgetAmount = budgetLineItem.buildertek__Amount_In__c + amount;
            contingencyAmount = contingencyBudgetItem.buildertek__Amount_Out_2__c + amount;
        } else if (component.get('v.isRightToLeft')) {
            budgetLineItem.buildertek__Amount_Out_2__c = budgetLineItem.buildertek__Amount_Out_2__c == undefined ? 0 : budgetLineItem.buildertek__Amount_Out_2__c;
            contingencyBudgetItem.buildertek__Amount_In__c = contingencyBudgetItem.buildertek__Amount_In__c == undefined ? 0 : contingencyBudgetItem.buildertek__Amount_In__c
            budgetAmount = budgetLineItem.buildertek__Amount_Out_2__c + amount;
            contingencyAmount = contingencyBudgetItem.buildertek__Amount_In__c + amount;
        }

        budgetAmount = budgetAmount < 0 ? -budgetAmount : budgetAmount;
        contingencyAmount = contingencyAmount < 0 ? -contingencyAmount : contingencyAmount;

        console.log('contingencyId::', contingencyId);
        var action = component.get("c.transferAmount");
        action.setParams({
            isLeftToRight: component.get('v.isLeftToRight'),
            budgetId: budgetId,
            budgetLineId: budgetLineId,
            budgetAmount: budgetAmount,
            contingencyId: contingencyId,
            contingencyAmount: contingencyAmount,
            amount: amount,
            note: note
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
                            }).format(eligibleCost);
                        }
                    }
                    component.set('v.budgetItemList', result.budgetItemList);
                }
                component.set('v.isAmountToTransferOpen', false);
                component.set('v.isContingency', false);
                component.set('v.note', '');
                component.set('v.enteredAmount', '');
                component.set('v.customModalCss', 'width: 90% !important;');
            } else {
                console.log('::Error::');
            }
        });
        $A.enqueueAction(action);
    }
})