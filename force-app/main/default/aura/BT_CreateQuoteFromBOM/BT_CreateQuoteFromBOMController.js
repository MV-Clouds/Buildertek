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
                // var navEvent = $A.get("e.force:navigateToSObject");
                // navEvent.setParams({
                //     "recordId": result,
                // });
    
                // navEvent.fire();
                var workspaceAPI = component.find("workspace"); //get the workspace component
                // workspaceAPI.getFocusedTabInfo().then(function(response) {
                // console.log('response ',{response});
                // console.log('response.parentTabId ',response.parentTabId);
                  //workspaceAPI.openSubtab({ //open sub tab
                  //  focus: true, //make the tab in focus
                  //  parentTabId : response.parentTabId, //parent tab
                  //  pageReference: {
                  //    "type": "standard__recordPage",
                  //    "attributes": {
                  //        "recordId": result,
                  //        "actionName":"view"
                  //    }
                  //  },
                  //})
                  //  .catch(function(error) { //catch errors
                  //    console.log('Error here >> ' + error);
                  //    //if(error == 'Error: API `openTab` is not currently supported in this application.'){
                  //    var urlEvent = $A.get("e.force:navigateToSObject");
                  //    urlEvent.setParams({
                  //        "recordId": result,
                  //        "isredirect": "true"
                  //    });
                  //    urlEvent.fire();
                  //  });
                // })
                // .catch(function(error) {
                //     console.log(error);
                // });
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                  var focusedTabId = response.tabId;
                  console.log(focusedTabId);

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
