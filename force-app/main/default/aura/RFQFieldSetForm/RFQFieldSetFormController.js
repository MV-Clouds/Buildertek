({
    init: function(component, event, helper) { 
        component.set("v.Spinner", true);
        var value = helper.getParameterByName(component , event, 'inContextOfRef');
    	var context = '';
    	var parentRecordId = '';
    	component.set("v.parentRecordId",parentRecordId);
    	
    	if(value != null){
    		context = JSON.parse(window.atob(value)); 
    		parentRecordId = context.attributes.recordId;
            component.set("v.parentRecordId",parentRecordId);
		}else{
		    var relatedList = window.location.pathname;
		    var stringList = relatedList.split("/");
		    parentRecordId = stringList[3]
		    component.set("v.parentRecordId",parentRecordId);
		} 
        var fieldSetName = component.get('v.fieldSetName');
        var sobjectName = component.get('v.sObjectName');
        var recordId = component.get('v.recordId');
        if (!fieldSetName) {
        	console.log('The field set is required.');
        	return;
        }
        
        
        var getFormAction = component.get('c.getForm');
        getFormAction.setParams({
            fieldSetName: fieldSetName,
            objectName: sobjectName,
            recordId: recordId
        });

        getFormAction.setCallback(this, function(response) {
            	var state = response.getState();
            	console.log('FieldSetFormController getFormAction callback');
            	console.log("callback state: " + state);
            
            	if (component.isValid() && state === "SUCCESS") {
	                var form = response.getReturnValue();
	                alert('form ---------> '+JSON.stringify(form));
	                component.set('v.fields', form.Fields); 
	                var Allvalues = [];
	                for(var i=0;i<form.Fields.length;i++){
	                    Allvalues.push({"Name":form.Fields[i].APIName, "Type":form.Fields[i].Type, "Label":form.Fields[i].Label});
	                }
	                component.set('v.Newfields',Allvalues);
	                 if(parentRecordId != '' && parentRecordId != undefined){
                            component.set('v.Newfields',Allvalues);
	                 }
	                 if(parentRecordId != undefined){
            		    var projectId = component.find("projectNameId"); 
            		    component.find("projectNameId").set("v.value", parentRecordId); 
            		}
            		component.set("v.Spinner", false);
                }
            }
        );
        $A.enqueueAction(getFormAction);
    },
    
    handleSuccess : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
             workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
        
        var params = event.getParams();
           // alert(params.response.id);
        var parentRecordId = component.get("v.parentRecordId");
         
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": params.response.id,
          "slideDevName": "detail"
        });
            
        window.open ("/"+escape(params.response.id),"_Self"); 
            
    },
   openModel: function(component, event, helper) {
      // Set isModalOpen attribute to true
      component.set("v.isModalOpen", true);
   },
  
  closeModel: function(component, event, helper) {
     // alert('hii');
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });

      $A.get("e.force:closeQuickAction").fire();
      // Set isModalOpen attribute to false  
      component.set("v.isModalOpen", false);
      var relatedListEvent = $A.get("e.force:navigateToRelatedList");
      relatedListEvent.setParams({
         "relatedListId": "buildertek__RFQs__r",
         "parentRecordId": component.get("v.parentRecordId")
      });
      relatedListEvent.fire();
     
  },
  
   submitDetails: function(component, event, helper) {
      // Set isModalOpen attribute to false
      //Add your code to call apex method or do some processing
      component.set("v.isModalOpen", false);
   },
        
})