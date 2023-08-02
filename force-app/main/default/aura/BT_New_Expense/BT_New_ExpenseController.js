({
    doInit: function (component, event, helper) {
        component.set('v.isLoading' , true);
        var value = helper.getParameterByName(component, event, 'inContextOfRef');
        var context = '';
        var parentRecordId = '';
        component.set("v.parentRecordId", parentRecordId);
        if (value != null) {
            context = JSON.parse(window.atob(value));
            parentRecordId = context.attributes.recordId;
            component.set("v.parentRecordId", parentRecordId);
            helper.setbudgetData(component, helper, event, parentRecordId);
        } else {
            var relatedList = window.location.pathname;
            var stringList = relatedList.split("/");
            parentRecordId = stringList[4];
            if (parentRecordId == 'related') {
                var stringList = relatedList.split("/");
                parentRecordId = stringList[3];
            } 
            if (parentRecordId != 'list') {
                component.set("v.parentRecordId", parentRecordId);
                helper.setbudgetData(component, helper, event, parentRecordId);
            }
        }  

        var action = component.get("c.getFieldSet");
        action.setParams({
            objectName: 'buildertek__Expense__c',
            fieldSetName: 'buildertek__New_Expense_Field_Set'
        });
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                var listOfFields = JSON.parse(response.getReturnValue());
                console.log(listOfFields);
                component.set("v.listOfFields", listOfFields);
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);

    },

    getBudgetvalue:function (component, event, helper) {
       var getId = event.getSource().get('v.value');
        if (typeof getId != 'string' && getId.length >0) {
            getId = getId[0];
        }
        console.log('New getId ==> '+getId);
        helper.setbudgetData(component, helper, event, getId);
    },

    budgetchange:function (component, event, helper) {
        console.log('budgetchange');
        var budgetName = component.get("v.budgetName");
        console.log('budgetNameStr ==> '+budgetName);
        var action = component.get("c.getBudgetline");
		action.setParams({
            recordId:budgetName
        });
		action.setCallback(this, function (response) {
           component.set('v.budgetLineList' , response.getReturnValue());
           console.log(component.get('v.budgetLineList'));
        })
        $A.enqueueAction(action);
    },

    closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle" 
          var workspaceAPI = component.find("workspace");
          workspaceAPI.getFocusedTabInfo().then(function(response) {
              var focusedTabId = response.tabId;
              workspaceAPI.closeTab({tabId: focusedTabId});
          })
          .catch(function(error) {
              console.log(error);
          });
          $A.get("e.force:closeQuickAction").fire();
          component.set("v.isOpen", false);
          window.setTimeout(
              $A.getCallback(function() {
                  $A.get('e.force:refreshView').fire();
              }), 1000
          );
     },

     handlesubmit: function(component, event, helper) {
        component.set("v.disableNewBtn", true);
        component.set("v.isLoading", true);
        console.log('handleSumit');
        event.preventDefault();
        var fields = event.getParam('fields');
        fields["buildertek__Budget__c"] = component.get("v.budgetName");
        fields["buildertek__Budget_Line__c"] = component.get("v.budgetLineName");
        var expenseAmount = fields["buildertek__Amount__c"];
        var expenseType;
        if (fields["buildertek__Type__c"] == undefined) {
            expenseType = component.get("v.typevalue");
        } else{
            expenseType = fields["buildertek__Type__c"];
        }
        var expensePaymentMethod = fields["buildertek__Payment_Method__c"];
        var expenseDescription = fields["buildertek__Description__c"];
        var action = component.get("c.duplicateExpense")
        action.setParams({
            "expenseAmount": expenseAmount,
            "expenseType": expenseType,
            "expensePaymentMethod": expensePaymentMethod,
            "expenseDescription": expenseDescription
        });
        action.setCallback(this, function(response) {
            component.set("v.disableNewBtn", false);
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result: ' + result);
                if (result == true) {
                    component.set("v.expenseData", fields);
                    component.set("v.isLoading", false);
                    component.set("v.isDuplicate", true);
                } else {
                    helper.saveExpense(component, event, helper, fields);
                }
            } else{
                helper.saveExpense(component, event, helper, fields);
            }
        });
        $A.enqueueAction(action);
     },

     handlesaveandnew: function(component, event, helper) {
        console.log('handlesaveandnew');
        component.set("v.SaveNnew", true);
     },

     handlesave: function(component, event, helper) {
        console.log('handlesave');
        component.set("v.SaveNnew", false);
     },

	closeBtn : function(component, event, helper) {
        	component.set("v.displayModal", false);
	},
	createDuplicate : function(component, event, helper) {
        component.set("v.disableDuplicate", true);
        component.set("v.isDuplicate", false);
        component.set("v.isLoading", true);
        var fields = component.get("v.expenseData");
        helper.saveExpense(component, event, helper, fields);
	},

    closeDuplicateModel: function(component, event, helper) {
        component.set("v.isDuplicate", false);
	},

})