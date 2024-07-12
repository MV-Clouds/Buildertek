({
    createNewQuote: function (component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        var recordId = component.get("v.recordId");
        console.log('recordId =>', { recordId });
        var action = component.get("c.createQuote");
    
        var tst = $A.get("e.force:showToast");
    
        action.setParams({
            recordId: recordId
        });
        action.setCallback(this, function (response) {
            var result = response.getReturnValue();
            console.log('Result =>', { result });
    
            if (result == null) {
                console.log('Error =>', { result });
                tst.setParams({
                    title: 'Error',
                    message: 'Something Went Wrong',
                    type: 'Error',
                    duration: 5000
                });
                tst.fire();
            } else {
                $A.get("e.c:BT_SpinnerEvent").setParams({
                    "action": "HIDE"
                }).fire();
                tst.setParams({
                    title: 'Complete',
                    message: 'Your Quote is created',
                    type: 'success',
                    duration: 5000
                });
                tst.fire();
                
                var workspaceAPI = component.find("workspace"); //get the workspace component
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                  var focusedTabId = response.tabId;

                  //Opening New Tab
                  workspaceAPI.openSubtab({ //open sub tab
                    focus: true, //make the tab in focus
                    parentTabId : focusedTabId, //parent tab
                    pageReference: {
                      "type": "standard__recordPage",
                      "attributes": {
                          "recordId": result,
                          "actionName":"view"
                      }
                    },
                  }) 
                   .catch(function(error) {
                       console.log('error in inner block ',error);
                   });

                })
                .catch(function(error) {
                    console.log(error);
                }); 
            }

            $A.get("e.force:closeQuickAction").fire();
        });
        $A.enqueueAction(action);
    },    

    closeModal: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})
