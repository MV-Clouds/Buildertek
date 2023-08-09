({
   
    doInit : function(component, event, helper) {
        console.log('Init');
         var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        var projectName = component.get("v.searchProjectNameFilter");
        var Community = component.get("v.searchCommunityFilter");
       // var Address = component.get("v.searchAddressFilter");
       
        var action = component.get("c.getadminvalue"); 
        console.log('action-->',action);
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            var result = response.getReturnValue();
            console.log('result-->',result);
            if (result == 'success'){
                console.log('---Success--');
                component.set("v.isadmin", true);
            }else{
                component.set("v.isadmin", false);   
            }
        });
       
        
        var opptyAction = component.get("c.opptyStageValueCheckandProject");
        opptyAction.setParams({
            "recordId" : component.get("v.recordId")
        });
        opptyAction.setCallback(this, function(response) {
            var state = response.getState(); 
            var result = response.getReturnValue();
            if (result == 'No Project'){
                $A.enqueueAction(action);
                component.set("v.showRecordData", true);
            }else{
               
                component.set("v.showRecordData", false);   
            }
             //$A.enqueueAction(action);
        });
        $A.enqueueAction(opptyAction);
        
       
        helper.getprojectRecord(component);
         helper.getprojList(component, event, helper, pageNumber, pageSize, projectName, Community);

    },
     openModal:function(component, event, helper) {
         var AccountName=component.get("v.opportunityRecord");
         var projectlist=component.get("v.projLst")
         var stageName=component.get("v.opportunityRecord");    
         if(AccountName.AccountId==null){
           component.set('v.open',true);
         }
         else if(stageName.StageName =='Closed Won'){      
           component.set('v.openModal',true);
        }
            
    },
      selectproj: function (component, event, helper) {  
        var checkbox = event.getSource();
        var selectedRfqIds = component.get("v.listOfSelectedIds");
        var getAllId = component.find("checkpj");
        if(checkbox.get("v.checked")){
            if(selectedRfqIds.indexOf(checkbox.get("v.name")) == -1){
                selectedRfqIds.push(checkbox.get("v.name"));
            }
            if(!Array.isArray(getAllId)) {
                if(!component.find("headCheckpj").get("v.checked")){
                    component.find("headCheckpj").set("v.checked",true);
                }
            }else{
                if(selectedRfqIds.length == getAllId.length){
                    if(!component.find("headCheckpj").get("v.checked")){
                        component.find("headCheckpj").set("v.checked",true);
                    }
                }
            }
        }else{
            if(component.find("headCheckpj").get("v.checked")){
                component.find("headCheckpj").set("v.checked",false);
            }
            if(selectedRfqIds.indexOf(checkbox.get("v.name")) > -1){
                var index = selectedRfqIds.indexOf(checkbox.get("v.name"));
                selectedRfqIds.splice(index,1);
            }
        }
        console.log(selectedRfqIds);
        component.set("v.listOfSelectedIds",selectedRfqIds);
    },
    
      selectAllproj : function (component, event, helper) {
        var checkStatus = event.getSource().get("v.checked");
        var projLst = JSON.parse(JSON.stringify(component.get("v.projLst")));
        var getAllId = component.find("checkpj");
        var recordIds = [];
        if(checkStatus){
            if(projLst.length){
                if (!Array.isArray(getAllId)) {
                    component.find("checkpj").set("v.checked", true);
                    var Id = component.find("checkpj").get("v.name");
                    if(recordIds.indexOf(Id) == -1){
                        recordIds.push(Id)
                    }
                }else{
                    for (var i = 0; i < getAllId.length; i++) {
                        component.find("checkpj")[i].set("v.checked", true);
                        var Id = component.find("checkpj")[i].get("v.name");
                        if(recordIds.indexOf(Id) == -1){
                            recordIds.push(Id)
                        }
                    }
                }
                component.set("v.listOfSelectedIds",recordIds);
            }
        }else{
            if(projLst.length){
                if (!Array.isArray(getAllId)) {
                    component.find("checkpj").set("v.checked", false);
                    var Id = component.find("checkpj").get("v.name");
                    if(recordIds.indexOf(Id) > -1){
                        var index = recordIds.indexOf(Id);
                        recordIds.splice(index,1);
                    }
                }else{
                    for (var i = 0; i < getAllId.length; i++) {
                        component.find("checkpj")[i].set("v.checked", false);
                        var Id = component.find("checkpj")[i].get("v.name");
                        if(recordIds.indexOf(Id) > -1){
                            var index = recordIds.indexOf(Id);
                            recordIds.splice(index,1);
                        }
                    }
                }
                component.set("v.listOfSelectedIds",recordIds);
            }
        }
        console.log(recordIds);
    },
    handleNext: function (component, event, helper) {
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        pageNumber++;
        var projectName = component.get("v.searchProjectNameFilter");
        var Community = component.get("v.searchCommunityFilter");
        var Address = component.get("v.searchAddressFilter");
       
        helper.getprojList(component, event, helper, pageNumber, pageSize, projectName, Community, Address);
    },
    
    handlePrev: function (component, event, helper) {
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        pageNumber--;
        var projectName = component.get("v.searchProjectNameFilter");
        var Community = component.get("v.searchCommunityFilter");
        var Address = component.get("v.searchAddressFilter");
        helper.getprojList(component, event, helper, pageNumber, pageSize, projectName, Community, Address);
    },
    
      addToprojects:function(component, event, helper) {  
        var records = component.get("v.projLst");
        var projectIds = component.get("v.listOfSelectedIds");
        var oppId = component.get("v.recordId");
        var Spinner = component.get("v.spinner");
        if(projectIds.length>0){
            helper.addprojects(component, event, helper, projectIds, oppId);
        }else{
            helper.showErrorToast(component,event,helper,'Error!','Please Select RFQ.');
        }
          
}, 
    doprojSearch: function (component, event, helper) {
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        var projectName = component.get("v.searchProjectNameFilter");
        var Community = component.get("v.searchCommunityFilter");
       // var Address = component.get("v.searchAddressFilter");
        helper.getprojList(component, event, helper, pageNumber, pageSize, projectName, Community);
    },
      handleCancel : function(component, event, helper) {
          component.set('v.openModal',false);
          var action = component.get("c.setopptyCheckFieldFasle")
          action.setParams({
              "oppId" : component.get("v.recordId")
          });
          action.setCallback(this,function(response){
              if(response.getState() == "SUCCESS"){
                  if(response.getReturnValue() != 'false'){
                      var workspaceAPI = component.find("workspace");
                      workspaceAPI.openTab({
                          pageReference: {
                              "type": "standard__recordPage",
                              "attributes": {
                                  "recordId": response.getReturnValue(),
                                  "actionName":"view"
                              }
                          },
                          focus: true
                      })
                      console.log(response.getReturnValue());
                  }else{
                      console.error(response.getReturnValue());
                  }
                  
              }
          });
          $A.enqueueAction(action);
    },
      Cancel : function(component, event, helper) {
        component.set('v.open',false);
    }
})