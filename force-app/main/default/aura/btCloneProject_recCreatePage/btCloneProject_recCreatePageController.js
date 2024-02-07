({
  // ================== TO Solve "TOO many SOQL : 101" =================
    doInit : function(component, event, helper) {

      console.log('County_Text : ', component.get("v.County_Text"));
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

                        
    createCloneProject : function(component, event, helper){
      try {
        var fields = event.getParam('fields');
        console.log('fields ', JSON.parse(JSON.stringify(fields)));
        
      } catch (error) {
        console.log("error in createCloneProject : ", error.stack);
      }
    },

    closeModel : function(component, event, helper){
      helper.closeModelHelper(component, event, helper);
    },

    
})