({
    createRFQ: function (component, helper) {
        console.log('createRFQ');
        var action = component.get("c.createRFQFromWT");
        action.setParams({ walkThroughId: component.get("v.recordId") });

        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('prject id:',result.projectId);
                $A.get("e.force:closeQuickAction").fire();
                if (result.Status === 'Success') {
                    component.find('notifLib').showNotice({
                        "variant": "success",
                        "header": "Success",
                        "message": result.Message,
                        closeCallback: function () {
                            $A.get('e.force:refreshView').fire();
                            // var event = $A.get('e.force:navigateToSObject');
                            // event.setParams({
                            //     'recordId': result.newRecordId
                            // }).fire();
                            if(result.projectId){
                    window.location.href='/lightning/r/buildertek__Project__c/'+result.projectId+'/related/buildertek__RFQs__r/view?'

                            }else{
                    window.location.href = '/lightning/o/buildertek__RFQ__c/list?';
                            }
                        }
                    });
                } else {
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

    groupTradeTypeHelper: function (component, selectedValue, helper) {
        console.log('record Id ', component.get("v.recordId"));
        console.log('selectedValue ', selectedValue);
        var action = component.get("c.groupRrqTradeType");
        action.setParams({ walkThroughId: component.get("v.recordId"), grpType: selectedValue });

        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state: ', state);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result: ', result);
                console.log('prject id:',result.projectId);
                $A.get("e.force:closeQuickAction").fire();
                if (result.Status === 'Success') {
                    component.find('notifLib').showNotice({
                        "variant": "success",
                        "header": "Success",
                        "message": result.Message,
                         closeCallback: function () {
                            $A.get('e.force:refreshView').fire(); 
                            if(result.projectId){
                    window.location.href='/lightning/r/buildertek__Project__c/'+result.projectId+'/related/buildertek__RFQs__r/view?'

                            }else{
                    window.location.href = '/lightning/o/buildertek__RFQ__c/list?';
                            }
                        }
                    });
                } else {
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
})