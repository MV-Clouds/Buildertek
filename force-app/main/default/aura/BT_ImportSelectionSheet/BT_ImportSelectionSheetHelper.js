({
    getAllMasterSelection: function(component, event, helper) {
        var action = component.get('c.getAllMaseterRecords');
        action.setParams({
             "selectionId": component.get('v.recordId'),
              'searchKeyword' : ''
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS" && response.getReturnValue()) {
                var selections = response.getReturnValue();
                var pageSize = component.get("v.pageSize");
                console.log('OUTPUT : ', { selections });

                if (selections != undefined) {
                    for (var i in selections) {
                        if (selections[i].Id != undefined) {
                            selections[i].buildertek__Is_Selected__c = false;
                        }
                    }
                    component.set('v.selectionList', selections);
                    component.set('v.totalRecords', selections.length);
                    console.log('Length::', component.get('v.totalRecords'));
                    component.set("v.startPage", 0);
                    component.set("v.endPage", pageSize - 1);
                    var PaginationList = [];
                    for (var i = 0; i < pageSize; i++) {
                        if (component.get("v.selectionList").length > i)
                            PaginationList.push(selections[i]);
                    }
                    component.set('v.PaginationList', PaginationList);
                }
            }
        });
        $A.enqueueAction(action);
    },

    doSearchHelper : function(component, event, helper) {
        var searchKeyword = component.get('v.searchKeyword');
        var action = component.get("c.getAllMaseterRecords");
        action.setParams({		
            'selectionId': component.get("v.recordId"),	
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
				console.log('PO =>',{result});
                component.set('v.Spinner',false);
				component.set("v.selectionList", result);
				component.set("v.totalRecords", component.get("v.selectionList").length);
				component.set("v.startPage",0);
				component.set("v.endPage",pageSize-1);
				var PaginationList = [];
				for(var i=0; i< pageSize; i++){
					if(component.get("v.selectionList").length> i)
						PaginationList.push(result[i]);    
				}
				component.set('v.PaginationList', PaginationList);

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

    importMasterSelections: function(component, event, helper, selectedSelectionId) {
        var action = component.get('c.importSelection');
        action.setParams({
            "currentSelectionId": component.get('v.recordId'),
            "selectedSelectionId": selectedSelectionId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS" && response.getReturnValue() === 'Success') {
                component.set('v.Spinner', false);
                $A.get("e.force:closeQuickAction").fire();
                // window.location.reload();
            } else {
                component.set('v.Spinner', false);
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    },
})