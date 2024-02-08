({
   	// ================== TO Solve "TOO many SOQL : 101" =================
    
       getFieldSetHelper: function(component, event, helper){
        try {

            var action = component.get("c.getFieldSet");
            action.setParams({
                
            });
            action.setCallback(this, function(response){
                var result = response.getReturnValue();

                if(result != null){
                  var listOfFields =  JSON.parse(result);
                  var sourceProject = component.get("v.projects").length > 0 ? component.get("v.projects")[0] : {};
                  // console.log('sourceProject : ', sourceProject);
  
                  for(var i in listOfFields){
                    var fieldName = listOfFields[i].name;
                    listOfFields[i]['value'] = sourceProject[fieldName];
                  }
                  // console.log('listOfFields updated : ', listOfFields);
                  component.set("v.listOfFields", listOfFields);
                }
                else{
                  helper.toastHelper(component, event, helper, 'Error', 'error while retriving data', 'error', 3000);
                  component.set("v.isLoading", false);
                }
            });
		    $A.enqueueAction(action);
            
        } catch (error) {
            console.log('error in getFieldSetHelper : ' , error.stack);
            
        }
    },

    helperCreateCloneProject: function(component, event, helper){

        if(component.get("v.errorMessages").length > 0){
          component.set("v.isLoading", true);
          window.setTimeout(function () {
            component.set("v.isError", true);
            component.set("v.isErrorModal", true);
            component.set("v.isLoading", false);
          }, 500)
        }
        else{
          var fields = event.getParam("fields");
          fields['buildertek__Source_Project__c'] = component.get("v.Source_Project");
          console.log('fields', JSON.parse(JSON.stringify(fields)));

          component.set("v.isLoading", true);
          component.set("v.isError", false);
          component.set("v.isErrorModal", false);
          component.find('recordEditForm').submit(fields);
        }

    },

    setTabIconHelper: function(component, event, helper){
        try {
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

    closeModelHelper: function (component, event, helper, recordId) {
  
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          recordId: recordId,
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

      toastHelper: function(component, event, helper, Title, Message, Type, Duration){
        var toast = $A.get("e.force:showToast");
              toast.setParams({
                  title: Title,
                  message: Message,
                  type: Type
              }, Duration);
          toast.fire();
      },

})