({
    doInit: function (component, event, helper) {
        component.set('v.isLoading' , true);
        component.set("v.parentRecordId", component.get("v.recordId"));
        // helper.getName(component, event, helper);
        helper.getFields(component, event, helper);
        helper.getparentrecord(component, event, helper);
        // setTimeout(helper.handleChangeProjectHelper(component, event, helper), 3000);


    },
    reInit: function (component, event, helper) {
        $A.get('e.force:refreshView').fire();
    },

    closeModel: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    handleLoad: function (component, event, helper) {
       helper.handleLoad(component, event, helper);
    },
    submitForm: function (component, event, helper) {
        document.getElementById('submitForm').click();
        component.set("v.duplicateExp", false);
    },
    handleSubmit: function (component, event, helper) {
        component.set('v.isLoading' , true);
        let budgetLineId=component.get('v.selectedBudgetLineId');
        let budgetId=component.get('v.selectedBudgetId');

        let budgetName=component.get('v.selectedBudgetName');
        let budgetLineName=component.get('v.selectedBudgetLineName');

        event.preventDefault(); // stop form submission
        var eventFields = event.getParam("fields");
        var expenseDescription = eventFields["buildertek__Description__c"];
        var expenseType = component.get("v.typevalue");
        var expensePaymentMethod = eventFields["buildertek__Payment_Method__c"];
        if (eventFields["buildertek__Amount__c"] != null && eventFields["buildertek__Amount__c"] != '') {
            var expenseAmount = eventFields["buildertek__Amount__c"];
        } else {
            var expenseAmount = null;
        }
        console.log({budgetName});
        if(budgetLineName == '' || budgetLineId == ''){
            eventFields["buildertek__Budget_Line__c"] = '';
        }else{
            eventFields["buildertek__Budget_Line__c"] = component.get("v.selectedBudgetLineId");
        }
        
        if(budgetName =='' ||  budgetId == ''){
            eventFields["buildertek__Budget__c"] = '';
        }else{
            eventFields["buildertek__Budget__c"] = component.get("v.selectedBudgetId");
        }

      
        if (component.get("v.duplicateExp") == false) {
            var action = component.get("c.duplicateExpense");
            action.setParams({
                "expenseDescription": expenseDescription,
                "expenseType": expenseType,
                "expensePaymentMethod": expensePaymentMethod,
                "expenseAmount": expenseAmount,
            });
            action.setCallback(this, function (response) {
                if (response.getState() === "SUCCESS") {
                    var result = response.getReturnValue();
                    if (result == 'DuplicateExpense') {
                        //component.set("v.isnew", false);
                        component.set("v.duplicateExp", true);
                    } else {
                        if (component.get('v.parentobjectName') == 'buildertek__Project__c') {
                            eventFields["buildertek__Project__c"] = component.get("v.parentRecordId");
                        }
                        // component.set('v.isLoading', true);
                        component.find('recordViewForm').submit(eventFields); // Submit form
                        helper.getbtadminrecord(component, event, helper);
                    }
                }
            });
            $A.enqueueAction(action);
        }
        else {
            console.log({eventFields});

            if (component.get('v.parentobjectName') == 'buildertek__Project__c') {
                eventFields["buildertek__Project__c"] = component.get("v.parentRecordId");
            }
            component.set('v.isLoading', true);
            component.find('recordViewForm').submit(eventFields); // Submit form
            helper.getbtadminrecord(component, event, helper);
        }
    },

    onRecordSuccess: function (component, event, helper) {
        let isSaveNew = component.get('v.isSaveNew');
        console.log('isSaveNew ',isSaveNew);

        
        if (isSaveNew) {
            var a = component.get('c.doInit');
            $A.enqueueAction(a);  
    
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                mode: 'sticky',
                message: 'Expense created successfully',
                messageTemplate: "Expense created successfully.",
                type: 'success',
                duration: '10000',
                mode: 'dismissible'
            });
            toastEvent.fire();  
        }else{

            var recordId = event.getParams().response;
            var expenseId = (recordId.id).replace('"', '').replace('"', '');
            component.set("v.expenseRecordId", recordId.id);
            component.set("v.expenseRecordName", recordId.Name);
            if (component.get('v.btadminvalue') == 'Message') {
                component.set("v.ismessage", true);
                component.set("v.isnew", false);
                helper.getMessage(component, event, helper);
            } else {
                // component.set("v.isnew",false);             
                var workspaceAPI = component.find("workspace");
                workspaceAPI.getFocusedTabInfo().then(function (response) {
                    var focusedTabId = response.tabId;
                    // workspaceAPI.closeTab({
                    //     tabId: focusedTabId
                    // });
                }).catch(function (error) {
                    console.log('Error', JSON.stringify(error));
                });
    
                // setTimeout(function () {
                var url = location.href;
                var baseURL = url.substring(0, url.indexOf('/', 14));
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'sticky',
                    message: 'Expense created successfully',
                    messageTemplate: "Expense created successfully.",
                    messageTemplateData: [{
                        url: baseURL + '/lightning/r/buildertek__Expense__c/' + escape(recordId.id) + '/view',
                        label: recordId.name,
                    }],
                    type: 'success',
                    duration: '10000',
                    mode: 'dismissible'
                });
                toastEvent.fire();
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": recordId.id,
                    "slideDevName": "related"
                });
                navEvt.fire();
                // }, 200);
            }
        }

    },

    saveAndNew: function (component, event, helper) {
        component.set('v.isSaveNew', true);
    }, 

    save: function (component, event, helper) {
        component.set('v.isSaveNew', false);
    }, 

    clickHandlerBudget: function(component, event, helper){
        console.log('clickHandlerBudget');
        component.set('v.displayBudget', false);
        var recordId = event.currentTarget.dataset.value;
        console.log('recordId ==> '+recordId);
        component.set('v.selectedBudgetId', recordId);

        var budgetList = component.get("v.budgetList");
        budgetList.forEach(element => {
            console.log('element => ',element);
            if (recordId == element.Id) {
                component.set('v.selectedBudgetName', element.Name);

            }
        });
    },
    searchBudgetData : function(component, event, helper) {
        console.log('searchBudgetData');
        component.set('v.loaded', true);
        component.set('v.displayBudget', true);
        component.set('v.displayBudgetLine', false);
        console.log(component.find("projectlookupid").get("v.value"));
        helper.handleChangeProjectHelper(component, event, helper);
        event.stopPropagation();
 
    },
    keyupBudgetData:function(component, event, helper) {

            console.log('selectedBudgetId=====', component.get('v.selectedBudgetId'));
            var allRecords = component.get("v.budgetList");
            var listOfAllRecords=component.get('v.allBudgetRecords');

            var searchFilter = event.getSource().get("v.value").toUpperCase();
            console.log({searchFilter});
            var tempArray = [];

            var i;
            console.log("ok");
            for (i = 0; i < listOfAllRecords.length; i++) {
                console.log(listOfAllRecords[i].Name);
                console.log(listOfAllRecords[i].Name.toUpperCase().indexOf(searchFilter) != -1);
                if ((listOfAllRecords[i].Name && listOfAllRecords[i].Name.toUpperCase().indexOf(searchFilter) != -1)) {
                        tempArray.push(listOfAllRecords[i]);
                }else{
                    component.set('v.selectedBudgetId' , ' ')
                }
            }

            component.set("v.budgetList", tempArray);
            console.log({searchFilter});
            if(searchFilter == undefined || searchFilter == ''){
                component.set("v.budgetList", listOfAllRecords);
            }

    },

    clickHandlerBudgetLine: function(component, event, helper){
        console.log('clickHandlerBudgetLine');
        component.set('v.displayBudgetLine', true);
        var recordId = event.currentTarget.dataset.value;
        console.log('recordId ==> '+recordId);
        component.set('v.selectedBudgetLineId', recordId);

        var budgetList = component.get("v.budgetLineList");
        budgetList.forEach(element => {
            console.log('element => ',element);
            if (recordId == element.Id) {
                component.set('v.selectedBudgetLineName', element.Name);
            }
        });
    },
    searchBudgetLineData : function(component, event, helper) {
        console.log('searchBudgetData');
        component.set('v.loaded', true);
        component.set('v.displayBudgetLine', true);
        component.set('v.displayBudget', false);
        helper.handleBudgetHelper(component, event, helper);
        event.stopPropagation();
 
    },
    keyupBudgetLineData:function(component, event, helper) {

        var allRecords = component.get("v.budgetLineList");
        var listOfAllRecords=component.get('v.allbudgetLine');

        var searchFilter = event.getSource().get("v.value").toUpperCase();
        console.log({searchFilter});
        var tempArray = [];

        var i;
        console.log("ok");
        for (i = 0; i < listOfAllRecords.length; i++) {
            console.log(listOfAllRecords[i].Name);
            console.log(listOfAllRecords[i].Name.toUpperCase().indexOf(searchFilter) != -1);
            if ((listOfAllRecords[i].Name && listOfAllRecords[i].Name.toUpperCase().indexOf(searchFilter) != -1)) {
                    tempArray.push(listOfAllRecords[i]);
            }else{
                component.set('v.selectedBudgetLineId' , ' ')
            }
        }

        component.set("v.budgetLineList", tempArray);
        console.log({searchFilter});
        if(searchFilter == undefined || searchFilter == ''){
            component.set("v.budgetLineList", listOfAllRecords);
        }
        console.log(component.get('v.selectedBudgetLineId'));

    },
    changeProject:function(component, event, helper) {
        console.log('displayBudget');
        component.set('v.displayBudget', false);
        component.set('v.selectedBudgetName' , '');
        component.set('v.selectedBudgetId' , '');
        helper.handleChangeProjectHelper(component, event, helper);

    },
    hideList:function(component, event, helper){
        
        component.set('v.displayBudget', false);
        component.set('v.displayBudgetLine', false);
    },



})