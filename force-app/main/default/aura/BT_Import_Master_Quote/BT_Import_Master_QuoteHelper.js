({
	doSearchHelper : function(component, event, helper) {

        // var quotId = component.get("v.quotId");
		// console.log('quotId--->>>'+{quotId});
        var searchKeyword = component.get('v.searchKeyword');
        
        var action = component.get("c.getMasterQuotes");
        action.setParams({			
            'searchKeyword' : searchKeyword
        });
		action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                console.log('result ==> ',{result});
				// component.set("v.PaginationList", result);
				// if (searchKeyword == '') {
                    component.set("v.disableBtn", false);
					var pageSize = component.get("v.pageSize");
                	var result = response.getReturnValue();
                	console.log('Quote =>',{result});
                	component.set("v.masterQuotesList", result);
                	component.set("v.totalRecords", component.get("v.masterQuotesList").length);
                	component.set("v.startPage",0);
                	component.set("v.endPage",pageSize-1);
                	var PaginationList = [];
                	for(var i=0; i< pageSize; i++){
                	    if(component.get("v.masterQuotesList").length> i)
                	        PaginationList.push(result[i]);    
                	}
                	//alert('PaginationList Length ------> '+PaginationList.length);
                	component.set('v.PaginationList', PaginationList);
                	component.set("v.Spinner", false);
                	var pag = component.get('v.PaginationList');
                	console.log({pag});
                // } else{
                //     component.set("v.disableBtn", true);
                // }
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

	showToast: function(type, title, message, time) {
        try {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": title,
                "type": type,
                "message": message,
                "duration": time
            });
            toastEvent.fire();
        } catch (error) {
            console.log({ error });
        }
    },
})