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
      console.log('cloneFlag : ', component.get("v.cloneFlag"));

      //  check --> process of checking exception for child(rollback method) is completed
      //    if yes....
      //        check --> did we get any exception from child object cloning)
      //              if yes... show error message
      //              else... create project along with all child object
      //    else...
      //        turn on spinner... And recall this method again after 2...
      //        again check this process...
       
        if(component.get("v.cloneFlag") == true){
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
              // fields['buildertek__Source_Project__c'] = component.get("v.Source_Project");
              console.log('fields', JSON.parse(JSON.stringify(fields)));
    
              component.set("v.isLoading", true);
              component.set("v.isError", false);
              component.set("v.isErrorModal", false);
              component.find('recordEditForm').submit(fields);
            
          }
        }       
         else{
          if(component.get("v.noOfcloneFlag") < 5){
            component.set("v.noOfcloneFlag", (component.get("v.noOfcloneFlag") + 1));
            component.set("v.isLoading", true);
            window.setTimeout(function () {
              helper.helperCreateCloneProject(component, event, helper);
            }, 2000)
          }
          else{
            // if, after hit save button and its after 10 sec rollback method still in progress the show belowd error...
            helper.toastHelper(component, event, helper, 'Error', 'Process taking too long. Please try again!', 'error', 5000);
            component.set("v.isLoading", false);
          }
          
        }
    },

    helperCloneChildObj: function(component, event, helper, cloneProjectId, childObj, isLast){

      console.log('inside helper clone project');
      var action = component.get("c.cloneChildObj")
        action.setParams({
          clonedProjectId : cloneProjectId,
          sourceProjectId : component.get("v.recordId"),
          objName : childObj,
          roll_back : false,
        });
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            console.log(childObj ," -- result -- ", result);
            if(isLast == true){
              component.set("v.isLoading", false);
              helper.toastHelper(component, event, helper, 'Success', 'Project cloned successfully!', 'success', 3000);
              // redirect to created project...
              helper.closeModelHelper(component, event, helper, cloneProjectId)
            }
            // else{
            //   var toast = $A.get("e.force:showToast");
            //     toast.setParams({
            //         title: "Error",
            //         message: result,
            //         type: "error"
            //     });
            //     toast.fire();
            // }
        });
		    $A.enqueueAction(action);
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

      // This method will create Project(for temparary basis) for checking child object is throwing any exception or not during the clone project....
      helperCreateRollBackProject: function(component, event, helper){
        try {
          var action = component.get("c.createRollBackProject");
          action.setParams({
            sourceProjectId : component.get("v.recordId"),
            ObjectList : component.get("v.objsToCreateList"),
            roll_back : false
          });
          action.setCallback(this, function(response){
            var result = response.getReturnValue();
            console.log('reult of createRollBackProject : ', result);
            if(result != null){
              try {
                var objsToCreateList = component.get('v.objsToCreateList');
                console.log('objsToCreateList : ', objsToCreateList);
                for(var i in objsToCreateList){
                  var isLast = i == (objsToCreateList.length - 1) ? true : false;
                  helper.checkCloneChildRollBack(component, event, helper, result, objsToCreateList[i], isLast);
                }
              } catch (error) {
                // why we have use tryCatch here....
                // when you got any error after create project...then immediately delete it....
                component.set("v.cloneFlag", true);
                helper.deleteRollbackProject(component, event, helper, result);
              }
            }
            else{
              component.set("v.cloneFlag", true);
              console.log('error in create roll back project');
            }
          });
          $A.enqueueAction(action);
          
        } catch (error) {
          console.log('error in createRollBackProject : ', error.stack);
          
        }
      },

      // This method use to check the is cloning of any child object thow any exception...
      // if yes... exception message will edded in list and will dispay on UI on save button click
      // else.. it will set "cloneFlag" to "True" for further process...
      checkCloneChildRollBack: function(component, event, helper, rollBackProjectId, childObj, isLast){
        try {
          var action = component.get("c.cloneChildObj")
          action.setParams({
            clonedProjectId : rollBackProjectId,
            sourceProjectId : component.get("v.recordId"),
            objName : childObj,
            roll_back : true,
          });
          action.setCallback(this, function(response){
              var result = response.getReturnValue();
              console.log(childObj ," --roll back result-- ", result);
              var errorMessages = component.get("v.errorMessages");
              if(result != 'success'){
                errorMessages.push(childObj+': '+ result);
              }
              if(errorMessages.length > 0){
                component.set("v.errorMessages", errorMessages);
              }
              if(isLast){
                component.set("v.cloneFlag", true);
                helper.deleteRollbackProject(component, event, helper, rollBackProjectId);
              }
          });
          $A.enqueueAction(action);
        } catch (error) {
          console.log('errror in checkCloneChildRollBack : ', error.stack);
          component.set("v.cloneFlag", true);
          helper.deleteRollbackProject(component, event, helper, rollBackProjectId);
        }
      },

      // This method used delete craete project(Roll Back Project) for purposed of child object exception checking...
      deleteRollbackProject: function(component, event, helper, rollBackProjectId){
        var action = component.get("c.deleteRollbackProject")
        action.setParams({
          rollBackProjectId : rollBackProjectId,
        });
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            console.log('result of deleteRollbackProject : ', result);
        });
		    $A.enqueueAction(action);
      }
})