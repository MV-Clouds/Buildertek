({
    doSearchHelper : function(component, event, helper) {
        var searchKeyword = component.get('v.searchKeyword');
        var action = component.get("c.getMasterProjectTakeoff");
        action.setParams({		
            'recordId' : component.get('v.recordId'),
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
				console.log('Takeoffs =>',{result});
				component.set("v.masterprojecttakeofflist", result);
				component.set("v.totalRecords", component.get("v.masterprojecttakeofflist").length);
				component.set("v.startPage",0);
				component.set("v.endPage",pageSize-1);
				var PaginationList = [];
				for(var i=0; i< pageSize; i++){
					if(component.get("v.masterprojecttakeofflist").length> i)
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
})