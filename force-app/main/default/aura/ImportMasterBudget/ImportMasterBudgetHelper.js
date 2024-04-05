({
	doSearchHelper : function(component, event, helper) {
        var searchKeyword = component.get('v.searchKeyword');
        var action = component.get("c.getMasterBudgets");
        action.setParams({		
			'recordId': component.get("v.recordId"),	
            'searchKeyword' : searchKeyword
        });
		action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                console.log('result ==> ',{result});
				component.set("v.disableBtn", false);
				var pageSize = component.get("v.pageSize");
				var result = response.getReturnValue();
				console.log('Budget =>',{result});
				component.set("v.masterBudgetsList", result);
				component.set("v.totalRecords", component.get("v.masterBudgetsList").length);
				component.set("v.startPage",0);
				component.set("v.endPage",pageSize-1);
				var PaginationList = [];
				for(var i=0; i< pageSize; i++){
					if(component.get("v.masterBudgetsList").length> i)
						PaginationList.push(result[i]);    
				}
				component.set('v.PaginationList', PaginationList);
				component.set("v.Spinner", false);
				var pag = component.get('v.PaginationList');
				console.log({pag});
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
		// >>>>>>>>>>>>>> CHB - 78, 80 <<<<<<<<<<<<<<<<<<<
		Check_Create_User_Access: function(component, event, helper){
			var action1 = component.get("c.CheckUserAccess");
			action1.setParams({
				AccessType: 'Create'
			});
			action1.setCallback(this, function(response) {
				console.log('CheckUserHaveAcces >> ',response.getReturnValue());
				if(response.getReturnValue() == 'True'){
				   component.set("v.HaveCreateAccess", true);
				}
				else if(response.getReturnValue() == 'False'){
					component.set("v.HaveCreateAccess", false);
				}
			});
			$A.enqueueAction(action1);
		},

})