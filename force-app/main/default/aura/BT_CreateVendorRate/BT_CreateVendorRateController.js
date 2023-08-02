({
    doInit: function (component, event, helper) {
        
        var parentRecordId = '';
          component.set("v.parentRecordId", parentRecordId);
        var myPageRef = component.get("v.pageReference"); 
        var state = myPageRef.state; 
        var context = state.inContextOfRef;
       /* if (context.startsWith("1\.")) {
        	context = context.substring(2);
        	var addressableContext = JSON.parse(window.atob(context)); 
            component.set("v.parentRecordId",addressableContext.attributes.recordId);
        } else{
            component.set("v.parentRecordId",parentRecordId);
        }*/
        
        var value = helper.getParameterByName(component, event, 'inContextOfRef');
        var context = '';
        var parentRecordId = '';
        component.set("v.parentRecordId", parentRecordId);
        if (value != null) {
            context = JSON.parse(window.atob(value));
            parentRecordId = context.attributes.recordId;
            component.set("v.parentRecordId", parentRecordId);
        } else {
            var relatedList = window.location.pathname;
            var stringList = relatedList.split("/");
            parentRecordId = stringList[4];
            if (parentRecordId == 'related') {
                var stringList = relatedList.split("/");
                parentRecordId = stringList[3];
            }
            component.set("v.parentRecordId", parentRecordId);
        }
        //alert('parentRecordId'+parentRecordId);
        if(parentRecordId != null && parentRecordId != ''){
            var action = component.get("c.getobjectName");
            action.setParams({
                recordId: parentRecordId,
            });
            action.setCallback(this, function (response) {
                //alert(response.getState());
                if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                    var objName = response.getReturnValue();                    
                    if(objName == 'buildertek__Account__c'){
                        //alert('hi');                        
                        //component.set("v.isdisabled", true);
                        component.set("v.parentRecordId", parentRecordId);                        
						
                    } 
                } 
            });
            $A.enqueueAction(action);
        }       
        var action = component.get("c.getVendorAccountId");
        action.setParams({
            recordId: parentRecordId,
        });
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                var result = response.getReturnValue();
                if(result !=null && result !=''  ){
                    //alert(result);
                    component.set("v.parentRecordId", result);
                    component.set("v.isdisabled", true);

                } 
            } 
        });
        $A.enqueueAction(action);
        
        if (navigator.geoLocation) {
            console.log("capability is there");
        } else {
            console.log("No Capability");
        }
 
        helper.getFields(component, event, helper);
    },

    closeModel: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        // workspaceAPI.getAllTabInfo().then(function (response) {
        //     console.log(response);
        //     debugger;
        // }).catch(function (error) {
        //     console.log(error);
        // });
        workspaceAPI.getFocusedTabInfo().then(function (response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({
                    tabId: focusedTabId
                });
            })
            .catch(function (error) {
                console.log(error);
            });
        $A.get("e.force:closeQuickAction").fire();
        window.setTimeout(
            $A.getCallback(function () {
                $A.get('e.force:refreshView').fire();
            }), 1000
        );
    },

    handleSubmit: function (component, event, helper) {
        debugger;
        component.set('v.isLoading', true);
       /* var fields = event.getParam("fields");
        event.preventDefault(); // Prevent default submit
        component.find('recordViewForm').submit(fields); // Submit form
      // helper.getbtadminrecord(component,event,helper); */
        var parentRecordId = component.get('v.parentRecordId');
        var fields = event.getParam("fields");
        if(parentRecordId != null){ 
        	fields["buildertek__Account__c"] = parentRecordId;
        } 
        event.preventDefault(); // Prevent default submit  
        component.find('recordViewForm').submit(fields); // Submit form
    },
    onRecordSuccess: function (component, event, helper) {
        var payload = event.getParams().response;
        var expenseId = (payload.id).replace('"','').replace('"',''); 
     
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({
                tabId: focusedTabId
            });
        }).catch(function (error) {
            console.log('Error', JSON.stringify(error));
        }); 
        setTimeout(function () {
            component.set('v.isLoading', false);
           // var payload = event.getParams().response;
            var url = location.href;
            var baseURL = url.substring(0, url.indexOf('/', 14));
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                mode: 'sticky',
                message: 'Rate created successfully',
                messageTemplate: "Rate created successfully.",
                messageTemplateData: [{
                    url: baseURL + '/lightning/r/buildertek__Rates__c/' + escape(payload.id) + '/view',
                    label: payload.name,
                }],
                type: 'success',
                duration: '10000',
                mode: 'dismissible'
            });
            toastEvent.fire();
				
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": payload.id,
                "slideDevName": "related"
            });
            navEvt.fire();
        }, 200);
       // } 
    },
    saveAndNew: function (component, event, helper) {
        debugger;
        component.set('v.isLoading', true);
        event.preventDefault(); // Prevent default submit
        var fields = event.getParam("listOfFields");
        component.find('recordViewForm').submit(fields); // Submit form
        $A.get('e.force:refreshView').fire();
    },
    handleError: function(component, event, helper) {
      //  setTimeout(function () {
            var errorMsg = event.getParam("detail");
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({            
                title : 'Error',
                message : errorMsg,
                type: 'error',
            });
            toastEvent.fire();
       // }, 2000);      
        helper.geterror(component, event, helper);
    }, 
})