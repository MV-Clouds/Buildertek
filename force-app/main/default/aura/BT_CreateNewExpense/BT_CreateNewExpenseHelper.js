({
    getParameterByName: function (component, event, name) {
        name = name.replace(/[\[\]]/g, "\\$&");
        var url = window.location.href;
        var regex = new RegExp("[?&]" + name + "(=1\.([^&#]*)|&|#|$)");
        var results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    },
    getName: function (component, event, helper) {
        var action = component.get("c.getBudgetNameFromProject");
        action.setParams({
            recordId: component.get("v.parentRecordId")
        });
        action.setCallback(this, function (response) {
            console.log('response.getReturnValue() ',response.getReturnValue());
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                let budgetList = response.getReturnValue();
                if (budgetList.length > 0) {
                    var budgetId = budgetList[0].Id;
                    component.set("v.selectedBudgetName", budgetId);
                }
            } else {
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
    },
    getFields: function (component, event, helper) {
        var action = component.get("c.getFieldSet");
        action.setParams({
            objectName: 'buildertek__Expense__c',
            fieldSetName: 'buildertek__New_Expense_Field_Set'
        });
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                var listOfFields = JSON.parse(response.getReturnValue());
                console.log('listOfFields ',listOfFields);
                //var flag = false;
                var projectfield = '';
                for (var i in listOfFields) {
                    if (listOfFields[i].name == 'buildertek__Project__c') {
                        //flag = true;
                        //projectfield = true
                        component.set('v.isProjectFieldExist', true);
                    }
                }
                /*if(!flag){
                    var obj = {};
                    obj.name='buildertek__Project__c';
                    obj.type='REFERENCE';
                    obj.required='false';
                    obj.label ='Project';
                    listOfFields.push(obj);
                    component.set('v.isProjectFieldExist',false);
                    component.set("v.listOfFields", listOfFields);
                }*/
                component.set("v.listOfFields", listOfFields);
            } else {
                console.log('Error');

            }
        });
        $A.enqueueAction(action);
    },
    getparentrecord: function (component, event, helper) {
        var action = component.get("c.getParentObjRec");
        action.setParams({
            parentrecordid: component.get("v.parentRecordId")
        });
        action.setCallback(this, function (response) {

            if (response.getState() === "SUCCESS") {
                var response = response.getReturnValue();
                var lookuprec = response.LookupRec;
                var ObjName = response.ObjectName;
                component.set('v.parentobjectName', ObjName);
                window.setTimeout(
                    $A.getCallback(function() {
                        helper.handleChangeProjectHelper(component, event, helper)
                    }), 2000
                );
        
                
            }else{
                component.set('v.isLoading' , false);

            }
        });
        $A.enqueueAction(action);
        
    },
    getbtadminrecord: function (component, event, helper) {
        var action = component.get("c.getbudgetrecord");
        action.setParams({
            Expenserecid: component.get("v.ExpenseId")
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                var TimeCard = response.getReturnValue();
                if (TimeCard == 'Message') {
                    component.set('v.btadminvalue', TimeCard);
                }
            }
        });
        $A.enqueueAction(action);
    },
    getMessage: function (component, event, helper) {
        component.set('v.isLoading' , true);

        setTimeout(function () {
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function (response) {
                var focusedTabId = response.tabId;
                // workspaceAPI.closeTab({
                //     tabId: focusedTabId
                // });
            }).catch(function (error) {
                console.log('Error', JSON.stringify(error));
            });

            var url = location.href;
            var baseURL = url.substring(0, url.indexOf('/', 14));
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                mode: 'sticky',
                message: 'Expense created successfully',
                messageTemplate: "Expense created successfully.",
                messageTemplateData: [{
                    url: baseURL + '/lightning/r/buildertek__Expense__c/' + escape(component.get("v.expenseRecordId")) + '/view',
                    label: component.get("v.expenseRecordName"),
                }],
                type: 'success',
                duration: '10000',
                mode: 'dismissible'
            });
            toastEvent.fire();
            setTimeout(function () {
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": component.get("v.expenseRecordId"),
                    "slideDevName": "related"
                });
                navEvt.fire();
            }, 50);
            component.set("v.ismessage", false);
            component.set('v.isLoading' , false);

        }, 2000);


    },
    handleChangeProjectHelper:function(component, event, helper) {
        component.set('v.isLoading' , false);
		console.log('change project ');
		let getValue= component.find("projectlookupid").get("v.value")
        console.log({getValue});

        if(getValue!= '' && getValue != undefined){
            var action = component.get("c.getBudget");
            action.setParams({
                recordId:getValue
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log(response.getError());
                console.log({state});
                var result= response.getReturnValue();
                if (state === "SUCCESS") {

                    console.log({result});
                    component.set('v.budgetList' ,result);
                    component.set('v.allBudgetRecords' ,result);
                    console.log(result[0]);
                    // 3329 - Sakina's Changes on 12th June 2023
                    component.set('v.selectedBudgetName', result[0].Name);
                    component.set("v.selectedBudgetId", result[0].Id);
                    component.set('v.loaded', false);

                }
            });
            $A.enqueueAction(action);

        }else{
            component.set('v.loaded', false);

            // component.set('v.budgetList' ,'');

        }
        
		
     },
     handleBudgetHelper:function(component, event, helper) {
		console.log('change project ');
		let getValue= component.get("v.selectedBudgetId");
        console.log({getValue});
        console.log(component.get('v.selectedBudgetName'));

        if(getValue!= '' && getValue != undefined){

            var action = component.get("c.getBudgetline");
            action.setParams({
                recordId:getValue
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log(response.getError());
                console.log({state});
                var result= response.getReturnValue();
                if (state === "SUCCESS") {

                    console.log({result});
                    component.set('v.budgetLineList' ,result);
                    component.set('v.loaded', false);
                    component.set('v.allbudgetLine', result);



                    
                }
            });
            $A.enqueueAction(action);
        }else{
            component.set('v.loaded', false);
        }
		
     },
     handleLoad: function (component, event, helper) {
        let isSaveNew = component.get('v.isSaveNew');
        if (!isSaveNew) {
            component.set('v.typevalue', 'Material');
            var RecordId = component.get("v.parentRecordId");
            if (component.get('v.parentobjectName') == 'buildertek__Budget__c') {
               
                component.find("budgetInput").set("v.value", RecordId);
            }
            if (component.get('v.parentobjectName') == 'buildertek__Project__c' && component.get('v.isProjectFieldExist') == true) {
                component.find("projectlookupid").set("v.value", RecordId);
            }
        }
    },

})