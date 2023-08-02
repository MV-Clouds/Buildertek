({
     getprojectRecord : function( component ) {
     var action = component.get("c.getprojectRecord"); 
         action.setParams({
             "opptyRecId" : component.get("v.recordId")
         })
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            var result = JSON.stringify(response.getReturnValue());
            if (component.isValid() && state === "SUCCESS"){
                component.set("v.projLst", response.getReturnValue());
            }
           
        });
        $A.enqueueAction(action);
    },

           /* if (result.getReturnValue() === "success"){
                component.set("v.isadmin", response.getReturnValue());
            }
                   
        });
        $A.enqueueAction(action);
                },*/
     showErrorToast: function (component, event, helper, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            duration: "5000",
            key: "info_alt",
            type: "error",
            mode: "pester",
        });
        toastEvent.fire();
    },
      showSuccessToast: function (component, event, helper, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            duration: "5000",
            key: "info_alt",
            type: "success",
            mode: "pester",
        });
        toastEvent.fire();
    },
    
     addprojects :function (component, event, helper, projectIds, oppId) {
        var action = component.get("c.updateproject");
            component.set("v.Spinner", true);
            component.set("v.showMessage", true);
        action.setParams({
            "projectIds" : projectIds,
            "oppId" : component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
                console.log(response);
                var recId = response.getReturnValue();
                helper.showSuccessToast(component,event,helper, "Success!",'Successfully updated');
                 component.set('v.openModal',false);
                 component.set("v.Spinner", false);
                component.set("v.showMessage", false);
                //$A.get("e.force:closeQuickAction").fire();
                var recordId = component.get("v.recordId");
            }else{
                helper.showErrorToast(component,event,helper,"Error occurs","Something went wrong!");
            } 
        });
            $A.enqueueAction(action);
    },
    getprojList: function (component, event, helper, pageNumber, pageSize, projectName, Community){
        var action = component.get("c.getProjects");
        var recId = component.get("v.recordId");
        action.setParams({
            "pageNumber" : pageNumber,
            "pageSize": pageSize,
            "projRecId" : recId,
            "projectName" : projectName.trim(),
            "Community" : Community.trim(),
            "opptyRecId" : component.get("v.recordId")
          //  "Address": Address.trim()
           
        });
        action.setCallback(this, function (result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS") {
                var resultData = result.getReturnValue();
                
                component.set("v.projLst", resultData.recordList);
                component.set("v.PageNumber", resultData.pageNumber);
                component.set("v.TotalRecords", resultData.totalRecords);
                component.set("v.RecordStart", resultData.recordStart);
                component.set("v.RecordEnd", resultData.recordEnd);
                component.set(
                    "v.TotalPages",
                    Math.ceil(resultData.totalRecords / pageSize)
                );
            }
        });  
        $A.enqueueAction(action);
    } 

})