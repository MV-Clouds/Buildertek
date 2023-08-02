({
    doInit: function (component, event, helper) {
        
        var parentRecordId = '';
        var now = new Date();
        var todayDateTime =$A.localizationService.formatDate(now, "YYYY-MM-ddThh:mm:ssZ");
        component.set("v.todayDateTime",todayDateTime);
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
        /*   var value = helper.getParameterByName(component, event, 'inContextOfRef');
        var context = '';
        var parentRecordId = '';
        var now = new Date();
        var todayDateTime =$A.localizationService.formatDate(now, "YYYY-MM-ddThh:mm:ssZ");
        //var todayDateTime = Date.parse(todayDateTimeString);
        console.log('current Date Time::',todayDateTime);
        console.log('current Date Time type::',typeof todayDateTime);
        component.set("v.todayDateTime",todayDateTime);
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
            console.log('parentRecordId::',parentRecordId);
            component.set("v.parentRecordId", parentRecordId);
        }*/
     
        if(parentRecordId != null && parentRecordId != ''){
            var action = component.get("c.getobjectName");
            action.setParams({
                recordId: parentRecordId,
            });
            action.setCallback(this, function (response) {
                if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                    var objName = response.getReturnValue();
                    if(objName == 'buildertek__Project__c'){
                        component.set("v.parentprojectRecordId", parentRecordId);
                      
                        var action4 = component.get("c.getRecordField");
                      
                        action4.setParams({
                            recordId: parentRecordId
                        });
                     
                        action4.setCallback(this, function (response) {
                          
                         
                            if (response.getState() == 'SUCCESS') {
                                if(response.getReturnValue() != 'Empty'){
                                 component.set("v.parentContactRecordId", response.getReturnValue());
                                }
                            }
                        });
                      
                                              $A.enqueueAction(action4);
                    }else if(objName == 'buildertek__Project_Task__c'){
                        component.set("v.parentprojecttaskRecordId", parentRecordId);
                        helper.getprojectschedule(component,event,helper);
                    }else if(objName == 'Contact'){
                        component.set("v.parentContactRecordId", parentRecordId);
                    }else if(objName == 'buildertek__Budget__c'){
                        component.set("v.parentbudgetRecordId", parentRecordId);
                        helper.getprojectbudget(component,event,helper);
                    }else if(objName == 'buildertek__Budget_Item__c'){
                        component.set("v.parentbudgetlineRecordId", parentRecordId);
                        helper.getprojectbudgetline(component,event,helper);
                    }
                } 
            });
            $A.enqueueAction(action);
        }
        if (navigator.geoLocation) {
            console.log("capability is there");
        } else {
            console.log("No Capability");
        }
        navigator.geolocation.getCurrentPosition(function (position) {
            var latit = position.coords.latitude;
            var longit = position.coords.longitude;
            component.set("v.latitude", latit);
            component.set("v.longitude", longit);
            //helper.submit(component, event, helper);
        }, function () {
            component.set("v.islocationaccess", false);
            helper.showErrorToast(component, event, helper, 'Warning!', 'Please Grant Location Access!');
        }, {
            maximumAge: 600000
        });
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
        // debugger
          event.preventDefault(); 
        var loc = component.get("v.islocationaccess");
       // alert(loc);
        if(loc == true){
           // alert("hhhh");
            component.set('v.isLoading', true);
            /* var fields = event.getParam("fields");
        event.preventDefault(); // Prevent default submit
        component.find('recordViewForm').submit(fields); // Submit form
      // helper.getbtadminrecord(component,event,helper); */
            var budgetitem = component.get('v.parentbudgetlineRecordId');
            var budget = component.get('v.parentbudgetRecordId');
            var contract = component.get('v.parentContactRecordId');
            var projecttask = component.get('v.parentprojecttaskRecordId');
            var project = component.get('v.parentprojectRecordId');
            var fields = event.getParam("fields");
            var lat = component.get("v.latitude");
            var lng = component.get("v.longitude");
            if(project != null){ 
                // alert("vvv");
                fields["buildertek__Project__c"] = project;
            }if(projecttask != null){
                fields["buildertek__Schedule_Item__c"] = projecttask;
            }
            if(contract != null){
                fields["buildertek__Resource__c"] = contract;
            }
            if(budget != null){
                fields["buildertek__Budget__c"] = budget;
            }if(budgetitem != null){
                fields["buildertek__Budget_Line__c"] = budgetitem;
            }//if(budgetitem != null){
            //  fields["buildertek__Start_Time__c"] = budgetitem;
            // }
            if(lat != null){
                fields["buildertek__Start_Location__Latitude__s"] = lat;
            }if(lng != null){
                fields["buildertek__Start_Location__Longitude__s"] = lng;
            } 
            /* if(lat == null && lng == null){
            fields["buildertek__Start_Time__c"] = null;
         }else{
             
         }*/
            //var fields = event.getParam("fields");
            fields["RecordTypeId"] =  component.get("v.RecordTypeId");
          // Prevent default submit  
            component.find('recordViewForm').submit(fields); // Submit form
        }else{
           // alert('hi');
            helper.showErrorToast(component, event, helper, 'Warning!', 'Please Grant Location Access!'); 
        }
    },
    onRecordSuccess: function (component, event, helper) {
        // debugger
        var loc = component.get("v.islocationaccess");
        //alert(loc);
        if(loc == true){
            var payload = event.getParams().response;
            var expenseId = (payload.id).replace('"','').replace('"',''); 
            /*  component.set("v.timecardRecordId",payload.id);
        component.set("v.timecardRecordName",payload.Name);
        if(component.get('v.btadminvalue') == 'Message'){
            component.set("v.ismessage",true);
            component.set("v.isnew",false);    
            helper.getMessage(component, event, helper);
        }else{*/
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
                    message: 'Time Card created successfully',
                    messageTemplate: "Time Card created successfully.",
                    messageTemplateData: [{
                        url: baseURL + '/lightning/r/buildertek__Time_Cards__c/' + escape(payload.id) + '/view',
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
        }else{
           // alert('hi');
            helper.showErrorToast(component, event, helper, 'Warning!', 'Please Grant Location Access!');
        }
    },
    saveAndNew: function (component, event, helper) {
        // debugger;
        var loc = component.get("v.islocationaccess");
       // alert(loc);
        if(loc == true){
            component.set('v.isLoading', true);
            event.preventDefault(); // Prevent default submit
            var fields = event.getParam("listOfFields");
            component.find('recordViewForm').submit(fields); // Submit form
            $A.get('e.force:refreshView').fire();
        }else{
            //alert('hi');
            helper.showErrorToast(component, event, helper, 'Warning!', 'Please Grant Location Access!');}
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