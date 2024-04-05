({
  // ================== TO Solve "TOO many SOQL : 101" =================
    doInit : function(component, event, helper) {

      var projects = component.get("v.projects");
      // console.log('projects : ', JSON.parse(JSON.stringify(projects)));
      console.log('Source_Project : ', component.get("v.Source_Project"));

      var Source_Project = component.get("v.Source_Project");
      if(Source_Project){
        var sourceProjectId = Source_Project.split('~')[0];
        component.set("v.recordId", sourceProjectId)
        var objectTocreate = Source_Project.split('~')[1];
        if(objectTocreate.length > 0){
          component.set("v.objsToCreateList", objectTocreate.split(","));
        }
      }


		  helper.getFieldSet_Helper(component, event, helper);
      helper.setTabIcon_Helper(component, event, helper);
    },

    loadSuccess: function(component, event, helper){
      console.log('Load Success');
      component.set("v.isLoading", false)
    },

    handleError: function(component, event, helper){
      try {
        console.log('error in recordedit from output: ', JSON.parse(JSON.stringify(event.getParam("output"))));
        console.log('error in recordedit from message : ', JSON.parse(JSON.stringify(event.getParam("message"))));
        var errorOutput = JSON.parse(JSON.stringify(event.getParam("output")));
        var errorMessages = [];
        var message;
        // When get error message during record creation...
        if(errorOutput.fieldErrors && errorOutput.errors){
          // When got error message from apex exception other than fields error
          if(errorOutput.errors.length > 0){
            var errorList = errorOutput.errors;
            for(var i in errorList){
              errorMessages.push(errorList[i].message);
            }
          }
          // If got error message form field filter validation
          else if(Object.keys(errorOutput.fieldErrors).length > 0){
            var fieldList = Object.keys(errorOutput.fieldErrors);
            for(var field of fieldList){
              var fieldErrList = errorOutput.fieldErrors[field];
              for(var j in fieldErrList){
                errorMessages.push(fieldErrList[j].message + `\nError on field:  ${field}`);
              }
            }
          }
          else{
            errorMessages.push(event.getParam("message"));
          }
          component.set("v.errorMessages", errorMessages);
          component.set("v.isError", true);
          helper.handleErrorModal_Helper(component, event, helper, true);
        }
        else{
          helper.toast_Helper(component, event, helper, 'Error', 'Error while loading record create page.', 'error', 3000);
        }
        component.set("v.isLoading", false);
      } catch (error) {
        console.log('error in handleError : ', error.stack);
        
      }
    },
                        
    createCloneProject : function(component, event, helper){
      try {
        event.preventDefault();
        helper.CreateCloneProject_Helper(component, event, helper);
        
      } catch (error) {
        console.log("error in createCloneProject : ", error.stack);
      }
    },
    
    // Once Project created this method will automatically... because we used standard submit method....
    handleSuccess: function(component, event, helper){
      try {
        console.log("inside success create clone project");
        
        // Return to the contact page and
        // display the new case under the case related list
        var record = event.getParams();  
        console.log('record Id ',record.id);
        var payload = event.getParams().response;
        console.log('response : ', payload);
        var cloneProjectId = (payload.id).replace('"','').replace('"',''); 
        console.log('clone project Id : ', cloneProjectId);

        if(cloneProjectId){
          helper.closeModel_Helper(component, event, helper, cloneProjectId);
        }

      } catch (error) {
        console.log("error in handleSuccess : ", error.stack);
      }

    },

    closeModel : function(component, event, helper){
      helper.closeModel_Helper(component, event, helper, component.get("v.recordId"));
    },

    handleErrorModal: function(component, event, helper){
      try {
        helper.handleErrorModal_Helper(component, event, helper, !component.get("v.isErrorModal"));
      } catch (error) {
        console.log('error in handleErrorModal : ', error.stack);
        
      }
    }

    
})