({
  // ================== TO Solve "TOO many SOQL : 101" =================
    doInit : function(component, event, helper) {

      var projects = component.get("v.projects");
      console.log('projects : ', JSON.parse(JSON.stringify(projects)));
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


		  helper.getFieldSetHelper(component, event, helper);
      helper.setTabIconHelper(component, event, helper);
    },

    loadSuccess: function(component, event, helper){
      console.log('Load Success');
      component.set("v.isLoading", false)
    },

    handleError: function(component, event, helper){
      console.log('error in recordedit from');
      helper.toastHelper(component, event, helper, 'Error', 'error while loading page', 'error', 3000);
      component.set("v.isLoading", false);
    },
                        
    createCloneProject : function(component, event, helper){
      try {
        event.preventDefault();
        var fields = event.getParam("fields");
        fields['buildertek__Source_Project__c'] = component.get("v.Source_Project");
        console.log('fields', JSON.parse(JSON.stringify(fields)));
        // console.log('recordId : ' + component.get("v.recordId"));
        // var updatedData = JSON.stringify(fields);
        if(fields['Name'] == null || fields['Name'] ==''){
          helper.toastHelper(component, event, helper, 'Error', 'Please insert project name', 'error', 3000);
        }
        else if(fields['buildertek__Customer__c'] == null || fields['buildertek__Customer__c'] ==''){
          helper.toastHelper(component, event, helper, 'Error', 'Please Assign Customer!', 'error', 3000);
        }
        else{
          component.set("v.isLoading", true);
          component.find('recordEditForm').submit(fields);
        }
        
      } catch (error) {
        console.log("error in createCloneProject : ", error.stack);
      }
    },
    
    handleSuccess: function(component, event, helper){
      try {
        console.log("inside success create clone project");
        
        // Return to the contact page and
        // display the new case under the case related list
        var record = event.getParams();  
        console.log('record Id ',record.id);
        var payload = event.getParams().response;
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
        }
        
      } catch (error) {
        console.log("error in handleSuccess : ", error.stack);
      }

    },

    closeModel : function(component, event, helper){
      helper.closeModelHelper(component, event, helper, component.get("v.recordId"));
    },

    
})