({
   	// ================== TO Solve "TOO many SOQL : 101" =================
    
       getFieldSetHelper: function(component, event, helper){
        try {

            var action = component.get("c.getFieldSet");
            action.setParams({
                
            });
            action.setCallback(this, function(response){
                console.log('inside get fieldsSet');
                var result = response.getReturnValue();
                console.log("result of get Field set : ", JSON.parse(result));
                component.set("v.listOfFields", JSON.parse(result));
            });
		    $A.enqueueAction(action);
            
        } catch (error) {
            console.log('error in getFieldSetHelper : ' , error.stack);
            
        }
    },

    setTabIconHelper: function(component, event, helper){
        try {
            console.log('inside setTabIconHelper');
            window.setTimeout(function () {
                var workspaceAPI = component.find("workspace");
                workspaceAPI
                  .getFocusedTabInfo()
                  .then(function (response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.setTabLabel({
                      tabId: focusedTabId,
                      label: "New BT Project",
                    });
                    workspaceAPI.setTabIcon({
                      tabId: focusedTabId,
                      icon: "custom:custom24",
                    });
                  })
                  .catch(function (error) {
                    console.log("sub tab error::", error);
                    // alert(error);
                  });
              }, 1000);
            
        } catch (error) {
            console.log('error in setTabIconHelper : ', error.stack);
            
        }
    },

    closeModelHelper: function (component, event, helper) {
  
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          recordId: component.get("v.recordId"),
          slideDevName: "detail",
        });
        navEvt.fire();
    
            var workspaceAPI = component.find("workspace");
            workspaceAPI
              .getFocusedTabInfo()
              .then(function (response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({
                  tabId: focusedTabId,
                });
              })
              .catch(function (error) {
                // console.log("Error", error);
              });
      },
})