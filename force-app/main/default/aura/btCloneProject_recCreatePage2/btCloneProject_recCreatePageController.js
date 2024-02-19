({
  // ================== TO Solve "TOO many SOQL : 101" =================
    doInit : function(component, event, helper) {

      component.get("v.projects", projects);
      // var projects = component.get("v.projects");
      var projects = [
        {
            "Id": "a1Q1K000004OIswUAG",
            "Name": "The Villa at Grand Station",
            "buildertek__County__c": "Bronx",
            "buildertek__Type__c": "Standard",
            "buildertek__Customer__c": "0011K00002fVW68QAG",
            "buildertek__Customer_Contact__c": "0031K00003KooaEQAR",
            "buildertek__Address__c": "111 Main ST"
        }
    ];
    component.set("v.projects", projects);

      console.log('projects : ', JSON.parse(JSON.stringify(projects)));
      
      // var Source_Project = component.get("v.Source_Project");
      var Source_Project = 'a1Q1K000004OIswUAG~Budget,Inspections,Quote,Punch List,Project Vendors,Contract,Warranty,Purchase Order,Selection,Schedule';
      console.log('Source_Project : ', Source_Project);
      if(Source_Project){
        var sourceProjectId = Source_Project.split('~')[0];
        component.set("v.recordId", sourceProjectId)
        var objectTocreate = Source_Project.split('~')[1];
        if(objectTocreate.length > 0){
          component.set("v.objsToCreateList", objectTocreate.split(","));
        }
      }


		  helper.getFieldSetHelper(component, event, helper);
      helper.setTabIconHelper(component, event, helper);
      if(component.get("v.objsToCreateList").length > 0){
        helper.helperCreateRollBackProject(component, event, helper);
      }
      else{
        component.set("v.cloneFlag", true);
      }
    },

    loadSuccess: function(component, event, helper){
      console.log('Load Success');
      component.set("v.isLoading", false)
    },

    handleError: function(component, event, helper){
      try {
        component.set("v.isErrorModal", true);
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
            var fieldError = errorOutput.fieldErrors;
            if(fieldError.Id.length > 0){
              var errorDetail = fieldError.Id;
              for(var i in errorDetail){
                errorMessages.push(errorDetail[i].message);
              }
            }
          }
          else{
            errorMessages.push(event.getParam("message"));
          }
          component.set("v.isError", true);
          component.set("v.errorMessages", errorMessages);
        }
        else{
          helper.toastHelper(component, event, helper, 'Error', 'Error while loading record create page.', 'error', 3000);
        }
        component.set("v.isLoading", false);
      } catch (error) {
        console.log('error in handleError : ', error.stack);
        
      }
    },
                        
    createCloneProject : function(component, event, helper){
      try {
        event.preventDefault();
        helper.helperCreateCloneProject(component, event, helper);
        
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
          var objsToCreateList = component.get('v.objsToCreateList');
          console.log('objsToCreateList : ', objsToCreateList);
  
          if(objsToCreateList.length > 0){
              for(var i in objsToCreateList){
                var isLast = i == (objsToCreateList.length - 1) ? true : false;
                helper.helperCloneChildObj(component, event, helper, cloneProjectId, objsToCreateList[i], isLast);
              }
          }
          else{
            component.set("v.isLoading", false);
            helper.toastHelper(component, event, helper, 'Success', 'Project cloned successfully!', 'success', 3000);
          }
        }
        else{
          helper.toastHelper(component, event, helper, 'Error', 'error while cloning project', 'error', 3000);
          component.set("v.isLoading", false);
          helper.closeModelHelper(component, event, helper, cloneProjectId);
        }

        
      } catch (error) {
        console.log("error in handleSuccess : ", error.stack);
      }

    },

    closeModel : function(component, event, helper){
      helper.closeModelHelper(component, event, helper, component.get("v.recordId"));
    },

    handleErrorModal: function(component, event, helper){
      try {
        component.set("v.isErrorModal", !component.get("v.isErrorModal"));
      } catch (error) {
        console.log('error in handleErrorModal : ', error.stack);
        
      }
    }

    
})