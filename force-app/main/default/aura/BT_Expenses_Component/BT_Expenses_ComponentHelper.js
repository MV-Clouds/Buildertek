({

    getProjects : function(component) {
        var action = component.get("c.getProjects");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                console.log(response.getReturnValue());
                //add none option
                var noneOption = {
                    Name: "--None--",
                    Id: '',
                };
                component.set("v.projectId", null);
                var projects = response.getReturnValue();
                projects.unshift(noneOption);
                component.set("v.projectsOptions", projects);
            }
        });
        $A.enqueueAction(action);
    },

    tabName : function(component) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then((response) => {
            let opendTab = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: opendTab,
                label: "Mass Transaction"
            });
            workspaceAPI.setTabIcon({
                tabId: opendTab,
                icon: 'standard:link',
                iconAlt: 'Mass Transaction'
            });
        }); 

    },

    getExpenses : function(component) {
        var action = component.get("c.getExpenses");
        action.setParams({
            "projectId": component.get("v.projectId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                console.log(response.getReturnValue());
                var expenses = response.getReturnValue();
                expenses.forEach(function(expense){
                    expense.selected = false;
                    expense.buildertek__Budget_Line__c = "";
                    expense.buildertek__Budget__c = "";
                });
                component.set("v.expenses", expenses);
                component.set("v.tableDataList", expenses);
                component.set("v.Spinner", false);
            }
        });
        $A.enqueueAction(action);
    },

    handleSelectedExpenses : function(component) {
        var expenses = component.get("v.expenses");
        console.log('expenses => ',expenses);
        var selectedExpenses = [];
        expenses.forEach(function(expense){
            if(expense.selected){
                selectedExpenses.push(expense);
            }
        }
        );
        component.set("v.selectedExpenses", selectedExpenses);
        console.log('selectedExpenses => ',selectedExpenses);
    },

    getBudegts : function(component) {
        var action = component.get("c.getBudgets");
        action.setParams({
            "projectId": component.get("v.projectId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var budgets = response.getReturnValue();
                console.log('budgetsOptions => ',budgets);
                if(budgets.length > 0){
                    component.set("v.budgetsOptions", budgets);
                }
                // if(budgets.length == 1){
                //     component.set("v.selectedBudgetId", budgets[0].Id);
                //     component.set("v.budgetsOptions", budgets);
                //     this.getBudgetLines(component);
                // }
            }
        });
        $A.enqueueAction(action);
    },

    getBudgetLines : function(component) {
        var action = component.get("c.getBudgetLines");
        action.setParams({
            "budgetId": component.get("v.selectedBudgetId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var budgetLines = response.getReturnValue();
                console.log('budgetLinesOptions => ',budgetLines);
                component.set("v.budgetLinesOptions", budgetLines);
                component.set("v.Spinner", false);
            }
        });
        $A.enqueueAction(action);
    },

    saveExpenses : function(component) {
        component.set("v.selectedExpenses", component.get("v.selectedExpenses").map(function(expense){
            if(!expense.buildertek__Budget_Line_Item__c){
                expense.buildertek__Budget_Line_Item__c = null;
            }
            return expense;
        }));
        if(component.get("v.selectedBudgetId")){
            component.set("v.Spinner", true);
            var expenses = component.get("v.selectedExpenses");
            console.log('exp length-->',expenses.length);

            var selectedBudget = component.get("v.selectedBudgetId");
            component.set("v.selectedBudgetName", component.get("v.budgetsOptions").find(function(budget){
                return budget.Id == selectedBudget;
            }).Name);
            var budgetvalue = component.get("v.selectedBudgetName");
            console.log('selectedBudgetName => '+component.get("v.selectedBudgetName"));

            var saveExp = component.get("c.saveExp");
            saveExp.setParams({
                "expenses": expenses
            });
            saveExp.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    console.log('response => ',response.getReturnValue());
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Success',
                        message: expenses.length+' Lines have been created for Budget '+budgetvalue,
                        duration: ' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    var recordId = component.get("v.recordId");
                    if(recordId == null || recordId == ''){
                        window.location.reload();
                    }
                }
                component.set("v.Spinner", false);
                $A.get("e.force:closeQuickAction").fire();
            }
            );
            $A.enqueueAction(saveExp);
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Error',
                message: 'Please select a Budget.',
                duration: ' 2000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }

    },

    getTimeCards : function(component) {
        var action = component.get("c.getTimeCards");
        action.setParams({
            "projectId": component.get("v.projectId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var timeCards = response.getReturnValue();
                timeCards.forEach(function(timeCard){
                    timeCard.selected = false;
                    timeCard.buildertek__Budget_Line__c = "";
                    timeCard.buildertek__Budget__c = "";
                });
                console.log('timeCards => ',timeCards);
                component.set("v.timeCards", timeCards);
                component.set("v.tableDataList", timeCards);
                component.set("v.Spinner", false);
            }
        });
        $A.enqueueAction(action);
    },

    ExpensesPage2 : function(component, event, helper) {
        helper.handleSelectedExpenses(component);
        if(component.get("v.selectedExpenses").length > 0){    
            component.set("v.Page1", false);
            component.set("v.SelectExp", false);
            component.set("v.SelectBLines", true);
            component.set("v.Page2", true);
            helper.getBudegts(component);
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Error',
                message: 'Please select at least one Expense.',
                duration: ' 2000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }
    },

    handleSelectedTimeCards : function(component) {
        var timeCards = component.get("v.timeCards");
        console.log('timeCards => ',timeCards);
        var selectedTimeCards = [];
        timeCards.forEach(function(timeCard){
            if(timeCard.selected){
                selectedTimeCards.push(timeCard);
            }
        }
        );
        component.set("v.selectedTimeCards", selectedTimeCards);
        console.log('selectedTimeCards => ',selectedTimeCards);
    },

    TimeCardsPage2 : function(component, event, helper) {
        helper.handleSelectedTimeCards(component);
        if(component.get("v.selectedTimeCards").length > 0){    
            component.set("v.Page1", false);
            component.set("v.SelectTC", false);
            component.set("v.Page2", true);
            component.set("v.TimeCardP2", true);
            helper.getBudegts(component);
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Error',
                message: 'Please select at least one Time Card.',
                duration: ' 2000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }
    },

    ExpensesPage1 : function(component, event, helper) {
        component.set("v.Page1", true);
        component.set("v.SelectExp", true);
        component.set("v.SelectBLines", false);
        component.set("v.Page2", false);
    },

    changeBudgetExpenses : function(component, event, helper) {
        component.set("v.Spinner", true);
        var selectedBudget = component.find("selectedBudget").get("v.value");
        component.set("v.selectedBudgetId", selectedBudget);
        console.log('selectedBudget => '+selectedBudget);
        if(selectedBudget){    
            component.set("v.selectedExpenses", component.get("v.selectedExpenses").map(function(expense){
                expense.buildertek__Budget__c = selectedBudget;
                return expense;
            }));
            console.log('selectedExpenses => '+JSON.stringify(component.get("v.selectedExpenses")));
            this.getBudgetLines(component);
        }else{
            component.set("v.selectedBudgetName", '');
            component.set("v.selectedExpenses", component.get("v.selectedExpenses").map(function(expense){
                expense.buildertek__Budget__c = '';
                return expense;
            }
            ));
            console.log('selectedExpenses => '+JSON.stringify(component.get("v.selectedExpenses")));
            component.set("v.budgetLinesOptions", []);
            component.set("v.Spinner", false);
        }
    },

    changeBudgetTimeCards : function(component, event, helper) {
        component.set("v.Spinner", true);
        var selectedBudget = component.find("selectedBudget").get("v.value");
        component.set("v.selectedBudgetId", selectedBudget);
        console.log('selectedBudget => '+selectedBudget);
        if(selectedBudget){    
            component.set("v.selectedBudgetName", component.get("v.budgetsOptions").find(function(budget){
                return budget.Id == selectedBudget;
            }).Name);
            console.log('selectedBudgetName => '+component.get("v.selectedBudgetName"));
            component.set("v.selectedTimeCards", component.get("v.selectedTimeCards").map(function(timeCard){
                timeCard.buildertek__Budget__c = selectedBudget;
                return timeCard;
            }));
            console.log('selectedTimeCards => '+JSON.stringify(component.get("v.selectedTimeCards")));
            this.getBudgetLines(component);
        }else{
            component.set("v.selectedBudgetName", '');
            component.set("v.selectedTimeCards", component.get("v.selectedTimeCards").map(function(timeCard){
                timeCard.buildertek__Budget__c = '';
                return timeCard;
            }
            ));
            console.log('selectedTimeCards => '+JSON.stringify(component.get("v.selectedTimeCards")));
            component.set("v.budgetLinesOptions", []);
            component.set("v.Spinner", false);
        }
        
    },

    TimeCardsPage1 : function(component, event, helper) {
        component.set("v.Page1", true);
        component.set("v.SelectTC", true);
        component.set("v.TimeCardP2", false);
        component.set("v.Page2", false);
    },

    saveTimeCards : function(component, event, helper) {
        component.set("v.selectedTimeCards", component.get("v.selectedTimeCards").map(function(timecard){
            if(!timecard.buildertek__Budget_Line__c){
                timecard.buildertek__Budget_Line__c = null;
            }
            return timecard;
        }));
        if(component.get("v.selectedBudgetId")){
            component.set("v.Spinner", true);
            var TimeCard = component.get("v.selectedTimeCards");
            console.log('TimeCard-->>',TimeCard.length);
            var action = component.get("c.saveTC");

            var selectedBudget = component.get("v.selectedBudgetId");
            component.set("v.selectedBudgetName", component.get("v.budgetsOptions").find(function(budget){
                return budget.Id == selectedBudget;
            }).Name);
            var budgetvalue = component.get("v.selectedBudgetName");
            console.log('selectedBudgetName => '+component.get("v.selectedBudgetName"));

            action.setParams({
                "TimeCard": TimeCard
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Success',
                        message: TimeCard.length+' Lines have been created for Budget '+budgetvalue,
                        duration: ' 2000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    var recordId = component.get("v.recordId");
                    if(recordId == null || recordId == ''){
                        window.location.reload();
                    }
                }
                console.log('TimeCard => '+JSON.stringify(TimeCard));
                component.set("v.Spinner", false);
                $A.get("e.force:closeQuickAction").fire();
            });
            $A.enqueueAction(action);
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Error',
                message: 'Please select a Budget.',
                duration: ' 2000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }
    },

    getInvoices : function(component, event, helper) {
        component.set("v.Spinner", true);
        var action = component.get("c.getInvoices");
        action.setParams({
            "projectId": component.get("v.projectId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var invoices = response.getReturnValue();
                invoices = invoices.map(function(invoice){
                    invoice.selected = false;
                    invoice.buildertek__Budget__c = '';
                    invoice.buildertek__Budget_Line__c = '';
                    return invoice;
                });
                console.log('invoices => '+JSON.stringify(invoices));
                component.set("v.invoices", invoices);
                component.set("v.tableDataList", invoices);
                component.set("v.Spinner", false);
            }
        });
        $A.enqueueAction(action);
    },

    handleSelectedInvoices : function(component, event, helper) {
        var invoices = component.get("v.invoices");
        console.log('invoices => ',invoices);
        var selectedInvoices = [];
        invoices.forEach(function(invoice){
            if(invoice.selected){
                selectedInvoices.push(invoice);
            }
        }
        );
        component.set("v.selectedInvoices", selectedInvoices);
        console.log('selectedInvoices => ',selectedInvoices);
    },
    handleSelectedCO : function(component, event, helper) {
        var changeOrder = component.get("v.changeOrder");
        console.log('changeOrder => ',changeOrder);
        var selectedCOs = [];
        changeOrder.forEach(function(changeOrder){
            if(changeOrder.selected){
                selectedCOs.push(changeOrder);
            }
        }
        );
        component.set("v.selectedCOs", selectedCOs);
        console.log('selectedCOs => ',selectedCOs);
    },


    InvoicesPage2 : function(component, event, helper) {
        helper.handleSelectedInvoices(component);
        if(component.get("v.selectedInvoices").length > 0){
            component.set("v.Page2", true);
            component.set("v.SelectInv", false);
            component.set("v.InvoiceP2", true);
            component.set("v.Page1", false);
            helper.getBudegts(component);
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Error',
                message: 'Please select at least one Invoice.',
                duration: ' 2000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }
    },
    changeOrderPage2 : function(component, event, helper) {
        console.log('co page 2');
        helper.handleSelectedCO(component);
        console.log(component.get('v.selectedCOs'));
        if(component.get("v.selectedCOs").length > 0){
            component.set("v.Page2", true);
            component.set("v.SelectCO", false);
            component.set("v.coPage2", true);
            component.set("v.Page1", false);
            helper.getBudegts(component);
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Error',
                message: 'Please select at least one Change Order.',
                duration: ' 2000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }
    },

    changeBudgetInvoices : function(component, event, helper) {
        component.set("v.Spinner", true);
        var selectedBudget = component.get("v.selectedBudgetId");
        console.log('selectedBudget => '+selectedBudget);
        if(selectedBudget){
            component.set("v.selectedInvoices", component.get("v.selectedInvoices").map(function(invoice){
                invoice.buildertek__Budget__c = selectedBudget;
                return invoice;
            }));
            console.log('selectedInvoices => '+JSON.stringify(component.get("v.selectedInvoices")));
            this.getBudgetLines(component);
         }
        else{
            component.set("v.selectedBudgetName", '');
            component.set("v.selectedInvoices", component.get("v.selectedInvoices").map(function(invoice){
                invoice.buildertek__Budget__c = '';
                return invoice;
            }
            ));
            console.log('selectedInvoices => '+JSON.stringify(component.get("v.selectedInvoices")));
            component.set("v.budgetLinesOptions", []);
            component.set("v.Spinner", false);
        }
    },
    changeBudgetChangeOrder : function(component, event, helper) {
        component.set("v.Spinner", true);
        var selectedBudget = component.get("v.selectedBudgetId");
        console.log('selectedBudget => '+selectedBudget);
        if(selectedBudget){
            component.set("v.selectedCOs", component.get("v.selectedCOs").map(function(changeOrder){
                changeOrder.buildertek__Budget__c = selectedBudget;
                return changeOrder;
            }));
            console.log('selectedCOs => '+JSON.stringify(component.get("v.selectedCOs")));
            this.getBudgetLines(component);
         }
        else{
            component.set("v.selectedBudgetName", '');
            component.set("v.selectedCOs", component.get("v.selectedCOs").map(function(changeOrder){
                changeOrder.buildertek__Budget__c = '';
                return changeOrder;
            }
            ));
            console.log('selectedCOs => '+JSON.stringify(component.get("v.selectedCOs")));
            component.set("v.budgetLinesOptions", []);
            component.set("v.Spinner", false);
        }
    },

    InvoicesPage1 : function(component, event, helper) {
        component.set("v.Page1", true);
        component.set("v.SelectInv", true);
        component.set("v.InvoiceP2", false);
        component.set("v.Page2", false);
    },
    changeOrderPage1 : function(component, event, helper) {
        component.set("v.Page1", true);
        component.set("v.SelectCO", true);
        component.set("v.coPage2", false);
        component.set("v.Page2", false);
    },

    saveInvoices : function(component, event, helper) {
        component.set("v.selectedInvoices", component.get("v.selectedInvoices").map(function(invoice){
            if(!invoice.buildertek__Budget_Line__c){
                invoice.buildertek__Budget_Line__c = null;
            }
            return invoice;
        }));
        if(component.get("v.selectedBudgetId")){
            component.set("v.Spinner", true);
            var Invoices = component.get("v.selectedInvoices");

            var selectedBudget = component.get("v.selectedBudgetId");
            component.set("v.selectedBudgetName", component.get("v.budgetsOptions").find(function(budget){
                return budget.Id == selectedBudget;
            }).Name);
            var budgetvalue = component.get("v.selectedBudgetName");
            console.log('selectedBudgetName => '+component.get("v.selectedBudgetName"));

            var action = component.get("c.saveInv");
            action.setParams({
                "Invoices": Invoices
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Success',
                        message: Invoices.length+' Lines have been created for Budget '+budgetvalue,
                        duration: ' 2000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    var recordId = component.get("v.recordId");
                    if(recordId == null || recordId == ''){
                        window.location.reload();
                    }
                }
                console.log('Invoices => '+JSON.stringify(Invoices));
                component.set("v.Spinner", false);
                $A.get("e.force:closeQuickAction").fire();
            });
            $A.enqueueAction(action);
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Error',
                message: 'Please select a Budget.',
                duration: ' 2000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }
    },
    saveChangeOrder : function(component, event, helper) {
        component.set("v.selectedCOs", component.get("v.selectedCOs").map(function(changeOrder){
            if(!changeOrder.buildertek__Budget_Line__c){
                changeOrder.buildertek__Budget_Line__c = null;
            }
            return changeOrder;
        }));
        if(component.get("v.selectedBudgetId")){
            component.set("v.Spinner", true);
            var changeOrders = component.get("v.selectedCOs");

            var selectedBudget = component.get("v.selectedBudgetId");
            component.set("v.selectedBudgetName", component.get("v.budgetsOptions").find(function(budget){
                return budget.Id == selectedBudget;
            }).Name);
            var budgetvalue = component.get("v.selectedBudgetName");
            console.log('selectedBudgetName => '+component.get("v.selectedBudgetName"));

            var action = component.get("c.saveChangeOrder");
            action.setParams({
                "changeOrderList": changeOrders
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Success',
                        message: changeOrders.length+' Lines have been created for Budget '+budgetvalue,
                        duration: ' 2000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    var recordId = component.get("v.recordId");
                    if(recordId == null || recordId == ''){
                        window.location.reload();
                    }
                }
                console.log('changeOrders => '+JSON.stringify(changeOrders));
                component.set("v.Spinner", false);
                $A.get("e.force:closeQuickAction").fire();
            });
            $A.enqueueAction(action);
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Error',
                message: 'Please select a Budget.',
                duration: ' 2000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }
    },

    getPurchaseOrders : function(component, event, helper) {
        component.set("v.Spinner", true);
        var action = component.get("c.getPurchaseOrders");
        action.setParams({
            "projectId": component.get("v.projectId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var purchaseOrders = response.getReturnValue();
                purchaseOrders = purchaseOrders.map(function(purchaseOrder){
                    purchaseOrder.selected = false;
                    purchaseOrder.buildertek__Budget__c = '';
                    purchaseOrder.buildertek__Budget_Line__c = '';
                    return purchaseOrder;
                });
                console.log('purchaseOrders => '+JSON.stringify(purchaseOrders));
                component.set("v.purchaseOrders", purchaseOrders);
                component.set("v.tableDataList", purchaseOrders);
                component.set("v.Spinner", false);
            }
        });
        $A.enqueueAction(action);
    },

    selectedPurchaseOrders : function(component, event, helper) {
        var purchaseOrders = component.get("v.purchaseOrders");
        var selectedPurchaseOrders = [];
        purchaseOrders.forEach(function(purchaseOrder){
            if(purchaseOrder.selected){
                selectedPurchaseOrders.push(purchaseOrder);
            }
        }
        );
        component.set("v.selectedPurchaseOrders", selectedPurchaseOrders);
        console.log('selectedPurchaseOrders => '+JSON.stringify(selectedPurchaseOrders));
    },


    PurchaseOrdersPage2 : function(component, event, helper) {
        helper.handleSelectedPurchaseOrders(component);
        if(component.get("v.selectedPurchaseOrders").length > 0){
            component.set("v.Page2", true);
            component.set("v.SelectPO", false);
            component.set("v.PurchaseOrderP2", true);
            component.set("v.Page1", false);
            helper.getBudegts(component);
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Error',
                message: 'Please select at least one Purchase Order.',
                duration: ' 2000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }
    },

    handleSelectedPurchaseOrders : function(component){
        var purchaseOrders = component.get("v.purchaseOrders");
        var selectedPurchaseOrders = [];
        purchaseOrders.forEach(function(purchaseOrder){
            if(purchaseOrder.selected){
                selectedPurchaseOrders.push(purchaseOrder);
            }
        }
        );
        component.set("v.selectedPurchaseOrders", selectedPurchaseOrders);
        console.log('selectedPurchaseOrders => '+JSON.stringify(selectedPurchaseOrders));
    },

    changeBudgetPurchaseOrders : function(component, event, helper) {
        component.set("v.Spinner", true);
        var selectedBudget = component.get("v.selectedBudgetId");
        console.log('selectedBudget => '+selectedBudget);
        if(selectedBudget){
            component.set("v.selectedPurchaseOrders", component.get("v.selectedPurchaseOrders").map(function(purchaseOrder){
                purchaseOrder.buildertek__Budget__c = selectedBudget;
                return purchaseOrder;
            }));
            console.log('selectedPurchaseOrders => '+JSON.stringify(component.get("v.selectedPurchaseOrders")));
            this.getBudgetLines(component);
        }
        else{
            component.set("v.selectedBudgetName", '');
            component.set("v.selectedPurchaseOrders", component.get("v.selectedPurchaseOrders").map(function(purchaseOrder){
                purchaseOrder.buildertek__Budget__c = '';
                return purchaseOrder;
            }));
            console.log('selectedPurchaseOrders => '+JSON.stringify(component.get("v.selectedPurchaseOrders")));
            component.set("v.budgetLinesOptions", []);
            component.set("v.Spinner", false);
        }

    },

    PurchaseOrdersPage1 : function(component, event, helper) {
        component.set("v.Page1", true);
        component.set("v.SelectPO", true);
        component.set("v.PurchaseOrderP2", false);
        component.set("v.Page2", false);
    },

    savePurchaseOrders : function(component, event, helper) {
        component.set("v.selectedPurchaseOrders", component.get("v.selectedPurchaseOrders").map(function(purchaseOrder){
            if(!purchaseOrder.buildertek__Budget_Line__c){
                purchaseOrder.buildertek__Budget_Line__c = null;
            }
            return purchaseOrder;
        }));
        if(component.get("v.selectedBudgetId")){
            component.set("v.Spinner", true);
            var purchaseOrders = component.get("v.selectedPurchaseOrders");
            var action = component.get("c.savePO");
            action.setParams({
                "PurchaseOrder": purchaseOrders
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Success',
                        message: 'Purchase Orders have been saved.',
                        duration: ' 2000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    var recordId = component.get("v.recordId");
                    if(recordId == null || recordId == ''){
                        window.location.reload();
                    }
                }
                console.log('purchaseOrders => '+JSON.stringify(purchaseOrders));
                component.set("v.Spinner", false);
                $A.get("e.force:closeQuickAction").fire();
            });
            $A.enqueueAction(action);
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Error',
                message: 'Please select a Budget.',
                duration: ' 2000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }
    },


    getChangeOrders : function(component, event, helper) {
        component.set("v.Spinner", true);
        var action = component.get("c.getChangeOrders");
        action.setParams({
            "projectId": component.get("v.projectId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var changeOrder = response.getReturnValue();
                console.log({changeOrder});
                changeOrder = changeOrder.map(function(changeOrder){
                    changeOrder.selected = false;
                    changeOrder.buildertek__Budget__c = '';
                    changeOrder.buildertek__Budget_Line__c = '';
                    return changeOrder;
                });
                console.log('changeOrder => '+JSON.stringify(changeOrder));
                component.set("v.changeOrder", changeOrder);
                component.set("v.tableDataList", changeOrder);
                component.set("v.Spinner", false);
            }
        });
        $A.enqueueAction(action);
    },


    getProjectData : function(component, event, helper) {
        var selectedTransactionType = component.get("v.selectedTransactionType");
        component.set("v.Spinner", true);
        if(selectedTransactionType == 'Expense'){
            helper.getExpenses(component);
        }else if(selectedTransactionType == 'Time Card'){
            helper.getTimeCards(component);
        }else if(selectedTransactionType == 'Purchase Order'){
            helper.getPurchaseOrders(component);
        }else if(selectedTransactionType == 'Invoice(AP)'){
            helper.getInvoices(component);
        }else if(selectedTransactionType == 'Change Order'){
            helper.getChangeOrders(component);
        }else{
            component.set("v.Spinner", false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Error',
                message: 'Please select Transaction Type.',
                duration: ' 2000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }
  
        component.set("v.checkedAll", false);
    },



})