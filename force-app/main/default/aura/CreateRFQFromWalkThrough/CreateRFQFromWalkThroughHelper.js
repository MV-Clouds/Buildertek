({
	createRFQ : function(component, helper){
        console.log('createRFQ');
        var action = component.get("c.createRFQFromWT");
        action.setParams({ walkThroughId : component.get("v.recordId") });

        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                var result = response.getReturnValue();
                $A.get("e.force:closeQuickAction").fire();
                if(result.Status === 'Success'){
                    component.find('notifLib').showNotice({
                        "variant": "success",
                        "header": "Success",
                        "message": result.Message,
                        closeCallback: function() {
                            $A.get('e.force:refreshView').fire();
                            var event = $A.get('e.force:navigateToSObject' );
                            event.setParams({
                                'recordId' : result.newRecordId
                            }).fire();
                        }
                    });
                }else{
                    component.find('notifLib').showNotice({
                        "variant": "error",
                        "header": "Error",
                        "message": result.Message
                    });
                }
            }
        });

        $A.enqueueAction(action);
	},

    groupTradeTypeHelper : function(component, event, helper){
        console.log('groupTradeTypeHelper');
        var action = component.get("c.groupRrqTradeType");
        action.setParams({ walkThroughId : component.get("v.recordId") });

        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result: ', result);
            }
        });

        $A.enqueueAction(action);
    },
})