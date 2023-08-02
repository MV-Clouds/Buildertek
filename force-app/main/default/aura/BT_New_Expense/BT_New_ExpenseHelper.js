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

    saveExpense: function (component, event, helper, fields) {
        var action = component.get("c.creteExpense");
        action.setParams({
            expenseData : fields
        });
        action.setCallback(this, function(response) {
            component.set('v.isLoading', false);
            if(response.getState() == 'SUCCESS'){
                var response = response.getReturnValue();
                var saveNnew = component.get("v.SaveNnew");
                if(saveNnew){
                    $A.get('e.force:refreshView').fire();
                }
                else{
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": response,
                        "slideDevName": "Detail"
                    });
                    navEvt.fire();

                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then(function(response) {
                        var focusedTabId = response.tabId;
                        workspaceAPI.closeTab({tabId: focusedTabId});
                    })
                }
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "Success",
                    "title": "Success!",
                    "message": "The record has been created successfully."
				});
				toastEvent.fire();
            } else{
                var error = response.getError();
                console.log('Error =>',{error});
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": 'Error',
                    "type": 'Error',
                    "message": 'Something Went Wrong',
                    "duration": '5000'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },

    setbudgetData: function (component, event, helper, parentRecordId){
        console.log('Project Id ==> '+parentRecordId);
        var action = component.get("c.getBudget");
		action.setParams({
            "recordId":parentRecordId
        });
		action.setCallback(this, function (response) {
            if(response.getState() == 'SUCCESS'){
                var result = response.getReturnValue();
                //add none option
                result.unshift({
                    Id: '',
                    Name: '--None--'
                });
                console.log('Budget Data => ',{result});
                component.set('v.budgetList' , result);
                if (result.length > 0) {
                    component.set("v.budgetName", result[0].Id);
                    var action = component.get("c.getBudgetline");
                    action.setParams({
                        recordId:result[0].Id
                    });
                    action.setCallback(this, function (response) {
                        if(response.getState() == 'SUCCESS'){
                            var budgetLineList = response.getReturnValue()
                            console.log('budgetLineList ==> ',[budgetLineList]);
                            component.set('v.budgetLineList' , budgetLineList);
                        }
                    })
                    $A.enqueueAction(action);
                }
            }
        })
        $A.enqueueAction(action);
    }

})