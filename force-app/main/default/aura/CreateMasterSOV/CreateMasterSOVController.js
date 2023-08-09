({
	doInit : function(component, event, helper) {	
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;            
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: "Master SOVs",
            });
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "custom:custom5",
                iconAlt: "Master SOVs"
            });
        })
        .catch(function(error) {
            console.log(error);
        });

        helper.fetchSOVs(component, event, helper);
	},
   
    closeModal: function (component, event, helper) {
        //window.close('https://btservice360-dev-ed.lightning.force.com/lightning/n/buildertek__Master_SOVs');
        //window.open('','_parent','');
        //window.close(); 
        self.close();
        console.log('self');
    },

    selectAllRfq : function (component, event, helper) {
        var checkStatus = event.getSource().get("v.checked");
        var rfqRecordList = JSON.parse(JSON.stringify(component.get("v.sovsList")));
        var getAllId = component.find("checkRFQ");
        var recordIds = [];
        if(checkStatus){
            if(rfqRecordList.length){
                if (!Array.isArray(getAllId)) {
                    component.find("checkRFQ").set("v.checked", true);
                    var Id = component.find("checkRFQ").get("v.name");
                    if(recordIds.indexOf(Id) == -1){
                        recordIds.push(Id)
                    }
                }else{
                    for (var i = 0; i < getAllId.length; i++) {
                        component.find("checkRFQ")[i].set("v.checked", true);
                        var Id = component.find("checkRFQ")[i].get("v.name");
                        if(recordIds.indexOf(Id) == -1){
                            recordIds.push(Id)
                        }
                    }
                }
                component.set("v.listOfSelectedSOVIds",recordIds);
            }
        }else{
            if(rfqRecordList.length){
                if (!Array.isArray(getAllId)) {
                    component.find("checkRFQ").set("v.checked", false);
                    var Id = component.find("checkRFQ").get("v.name");
                    if(recordIds.indexOf(Id) > -1){
                        var index = recordIds.indexOf(Id);
                        recordIds.splice(index,1);
                    }
                }else{
                    for (var i = 0; i < getAllId.length; i++) {
                        component.find("checkRFQ")[i].set("v.checked", false);
                        var Id = component.find("checkRFQ")[i].get("v.name");
                        if(recordIds.indexOf(Id) > -1){
                            var index = recordIds.indexOf(Id);
                            recordIds.splice(index,1);
                        }
                    }
                }
                component.set("v.listOfSelectedSOVIds",recordIds);
            }
        }
        console.log(recordIds);
    },
    
    selectRfq: function (component, event, helper) {
        var checkbox = event.getSource();
        var selectedRfqIds = component.get("v.listOfSelectedSOVIds");
        var getAllId = component.find("checkRFQ");
        if(checkbox.get("v.checked")){
            if(selectedRfqIds.indexOf(checkbox.get("v.name")) == -1){
                selectedRfqIds.push(checkbox.get("v.name"));
            }
            if(!Array.isArray(getAllId)) {
                if(!component.find("headCheckRFQ").get("v.checked")){
                    component.find("headCheckRFQ").set("v.checked",true);
                }
            }else{
                if(selectedRfqIds.length == getAllId.length){
                    if(!component.find("headCheckRFQ").get("v.checked")){
                        component.find("headCheckRFQ").set("v.checked",true);
                    }
                }
            }

            var sovlist =  component.get("v.sovsList");            
            for(var i=0;i<sovlist.length;i++){
                if(sovlist[i].RecordId==checkbox.get("v.name")){
                    sovlist[i].isChecked = checkbox.get("v.checked");
                }
            }
            component.set("v.sovsList",sovlist);

        }else{
            if(component.find("headCheckRFQ").get("v.checked")){
                component.find("headCheckRFQ").set("v.checked",false);
            }
            if(selectedRfqIds.indexOf(checkbox.get("v.name")) > -1){
                var index = selectedRfqIds.indexOf(checkbox.get("v.name"));
                selectedRfqIds.splice(index,1);
            }
        }
        console.log(selectedRfqIds);
        component.set("v.listOfSelectedSOVIds",selectedRfqIds);
    },
    

    handleNext: function (component, event, helper) { 
	
       if(component.get("v.listOfSelectedSOVIds").length>0){
           component.set("v.isNext",true);
        }
        else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : "Error!",
                message : 'Please select SOVs',
                type: 'error',
                duration: '1000',
                    key: 'info_alt',
                mode: 'pester'
            });
            toastEvent.fire();
        } 

    },
    
    handlePrevious: function (component, event, helper) {
        
        component.set("v.showSOVLines",false);
        component.set("v.showSOVs",true);
        component.set("v.isNext",false);
        var selectedRfqIds = component.get("v.listOfSelectedSOVIds");
        var sovlist =  component.get("v.sovsList");
        for(var i=0;i<sovlist.length;i++){
            for(var j=0;j<selectedRfqIds.length;j++){
                if(sovlist[i].RecordId==selectedRfqIds[j]){
                    sovlist[i].isChecked = true;
                } 
            }           
        }
        component.set("v.sovsList",sovlist);
        //component.set("v.listOfSelectedSOVIds",[])
    },


    selectAllSOVLines : function (component, event, helper) {
        var checkStatus = event.getSource().get("v.checked");
        var rfqRecordList = JSON.parse(JSON.stringify(component.get("v.sovsList")));
        var getAllId = component.find("checkSOVLine");
        var recordIds = [];

        
        /* only for default purpose */
         
        /* only for default purpose */
        
        if(checkStatus){
            if(rfqRecordList.length){
                if (!Array.isArray(getAllId)) {
                    component.find("checkSOVLine").set("v.checked", true);
                    var Id = component.find("checkSOVLine").get("v.name");
                    if(recordIds.indexOf(Id) == -1){
                        recordIds.push(Id)
                    }
                }else{
                    for (var i = 0; i < getAllId.length; i++) {
                        component.find("checkSOVLine")[i].set("v.checked", true);
                        var Id = component.find("checkSOVLine")[i].get("v.name");
                        if(recordIds.indexOf(Id) == -1){
                            recordIds.push(Id)
                        }
                    }
                }
                component.set("v.listOfSelectedSOVLineIds",recordIds);
            }
        }else{
            if(rfqRecordList.length){
                if (!Array.isArray(getAllId)) {
                    component.find("checkSOVLine").set("v.checked", false);
                    var Id = component.find("checkSOVLine").get("v.name");
                    if(recordIds.indexOf(Id) > -1){
                        var index = recordIds.indexOf(Id);
                        recordIds.splice(index,1);
                    }
                }else{
                    for (var i = 0; i < getAllId.length; i++) {
                        component.find("checkSOVLine")[i].set("v.checked", false);
                        var Id = component.find("checkSOVLine")[i].get("v.name");
                        if(recordIds.indexOf(Id) > -1){
                            var index = recordIds.indexOf(Id);
                            recordIds.splice(index,1);
                        }
                    }
                }
                component.set("v.listOfSelectedSOVLineIds",recordIds);
            }
        }
        console.log(recordIds);
    },
    
    selectSOVLine: function (component, event, helper) {
        var checkbox = event.getSource();
        var selectedRfqIds = component.get("v.listOfSelectedSOVLineIds");
        var getAllId = component.find("checkSOVLine");
        if(checkbox.get("v.checked")){
            if(selectedRfqIds.indexOf(checkbox.get("v.name")) == -1){
                selectedRfqIds.push(checkbox.get("v.name"));
            }
            if(!Array.isArray(getAllId)) {
                if(!component.find("headCheckSOVLines").get("v.checked")){
                    component.find("headCheckSOVLines").set("v.checked",true);
                }
            }else{
                if(selectedRfqIds.length == getAllId.length){
                    if(!component.find("headCheckSOVLines").get("v.checked")){
                        component.find("headCheckSOVLines").set("v.checked",true);
                    }
                }
            }
        }else{
            if(component.find("headCheckSOVLines").get("v.checked")){
                component.find("headCheckSOVLines").set("v.checked",false);
            }
            if(selectedRfqIds.indexOf(checkbox.get("v.name")) > -1){
                var index = selectedRfqIds.indexOf(checkbox.get("v.name"));
                selectedRfqIds.splice(index,1);
            }
        }
        console.log(selectedRfqIds);
        component.set("v.listOfSelectedSOVLineIds",selectedRfqIds);
    },
    

    handleCreateMasterSOV : function (component, event, helper){
        
        var reci = []
        var recIds = component.get("v.sovlinesList"); //RecordId
        for (var i = 0; i < recIds.length; i++) {
          reci.push(recIds[i].RecordId)
            }
        
        
        component.set("v.listOfSelectedSOVLineIds",reci);
        
        var sovlineids  = component.get("v.listOfSelectedSOVLineIds");
        //alert(component.get("v.listOfSelectedSOVLineIds"));
        if(component.get("v.listOfSelectedSOVLineIds").length>0){
            component.set("v.showPopup",true);    
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : "Error!",
                message : 'Please select SOV Lines',
                type: 'error',
                duration: '1000',
                    key: 'info_alt',
                mode: 'pester'
            });
            toastEvent.fire();
        }
        

    },

    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.showPopup", false);
     },
    
    
    handleCreateLoad: function(component, event, helper) {
       // component.find("newSovStatus").set("v.value","Approved");
     },

    handleSubmit: function(component, event, helper) {
        event.preventDefault();       // stop the form from submitting
        
        var fields = event.getParam('fields');
       
        //alert(fields["Name"]);
        //alert(fields["buildertek__Project__c"]);
        component.find('recordEditForm').submit(fields);
        
    },

    handleSuccess : function(component,event,helper) {
        // Return to the contact page and
        // display the new case under the case related list
        var record = event.getParams();  
        //console.log(record.id);
        var payload = event.getParams().response;
        var eventId = (payload.id).replace('"','').replace('"',''); 
        //alert(eventId);
        component.set("v.masterSOVId",eventId);

        helper.generateMasterSOV(component, event, helper);

        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : "Success!",
            message : 'Master SOV created successfully',
            type: 'success',
            duration: '10000',
                key: 'info_alt',
            mode: 'pester'
        });
        toastEvent.fire();
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": eventId,
            "slideDevName": "related"
        });
        navEvt.fire();

        /*var navService = component.find("navService");        
        var pageReference = {
            "type": 'standard__recordPage',         
            "attributes": {              
                "recordId": component.get("v.recordId"),
                "actionName": "view",               
                "objectApiName":"Contact"              
            }        
        };
                
        component.set("v.pageReference", pageReference);
            
        var pageReference = component.get("v.pageReference");
        navService.navigate(pageReference); */

        
    },
        AcceptSov: function (component, event, helper) { 
            
            component.set("v.isNext",false)
            
            if(component.get("v.listOfSelectedSOVIds").length>0){
                helper.fetchSOVLines(component, event, helper);
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : "Error!",
                    message : 'Please select SOVs',
                    type: 'error',
                    duration: '1000',
                    key: 'info_alt',
                    mode: 'pester'
                });
                toastEvent.fire();
            } 
            
        },
    
    
       rejectSOV: function (component, event, helper) {
        //window.close('https://btservice360-dev-ed.lightning.force.com/lightning/n/buildertek__Master_SOVs');
        //window.open('','_parent','');
        //window.close(); 
        
           var action = component.get("c.rejectSelectedSOVs");
           action.setParams({
               sovIds : component.get("v.listOfSelectedSOVIds")
           });
           action.setCallback(this, function(response){
               if(response.getState() == 'SUCCESS'){
                   var result = response.getReturnValue();
                   var dismissActionPanel = $A.get("e.force:closeQuickAction");
                   dismissActionPanel.fire();
                   
                   $A.get('e.force:refreshView').fire();
                   
                   var toastEvent = $A.get("e.force:showToast");
                   toastEvent.setParams({
                       title : 'Success',
                       message: 'Selected SOVs Rejected Successfully',
                       duration:' 5000',
                       key: 'info_alt',
                       type: 'Success',
                       mode: 'dismissible'
                   });
                   toastEvent.fire();
               }     
           });
           $A.enqueueAction(action);
           
           component.set("v.showSOVLines",false);
           component.set("v.showSOVs",true);
           var selectedRfqIds = component.get("v.listOfSelectedSOVIds");
           var sovlist =  component.get("v.sovsList");
           for(var i=0;i<sovlist.length;i++){
               for(var j=0;j<selectedRfqIds.length;j++){
                   if(sovlist[i].RecordId==selectedRfqIds[j]){
                       sovlist[i].isChecked = true;
                   } 
               }           
           }
           component.set("v.sovsList",sovlist);
           
       },
    
    



})