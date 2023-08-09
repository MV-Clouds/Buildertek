({
    getParameterByName: function (component, event, name) {
        name = name.replace(/[\[\]]/g, "\\$&");
        var url = window.location.href;
        var regex = new RegExp("[?&]" + name + "(=1\.([^&#]*)|&|#|$)");
        var results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    },
    getFields: function (component, event, helper) {
        var action = component.get("c.getFieldSet");
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                var listOfFields = JSON.parse(response.getReturnValue());
                component.set("v.listOfFields", listOfFields);
                component.set('v.Spinner', false);
                //    

            } else {
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
    },
    // vendorsAndProject: function (component, event, helper) {
    //     var parentId = component.get("v.parentpurchaseRecordId")
    //     var action = component.get("c.getNames");
    //     action.setParams({
	// 				RecordId: parentId
	// 			});
    //     action.setCallback(this, function (response) {
    //         console.log(response.getState());
    //         console.log(response.getError());
    //         component.set('v.Spinner', false);

    //         if (response.getState() == 'SUCCESS') {                
    //            var NameOfVendor = response.getReturnValue();
    //            console.log({NameOfVendor});
    //            console.log(JSON.stringify(NameOfVendor));
    //            for(var i in NameOfVendor){
    //             console.log(i);
    //             console.log(NameOfVendor[i]);
    //                 if(NameOfVendor[i]== 'Vendor'){
    //                     component.set("v.NameOfVendor", i);
    //                 }

    //                 if(NameOfVendor[i] == 'Project'){
    //                     component.set("v.NameOfProject", i);
    //                 }

    //                 // component.set('v.isDisable' , true);

    //            }
                
    //             // component.set("v.NameOfVendor", NameOfVendor);
    //         } else {
    //             console.log('Error');
    //         }
    //          });
    //     $A.enqueueAction(action);
    // }
    closePopupHelper : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.isConsoleNavigation().then(function(response) {
            if (response == true) {
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.closeTab({
                        tabId: focusedTabId
                    });

                    var recordId = component.get("v.parentRecordId");
                    //get record id of parent record from 


                    if (recordId != 'list' && recordId != null && recordId != 'home' && recordId.includes('0000')) {
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": recordId,
                            "slideDevName": "detail"
                        });
                        navEvt.fire();
                    } else {
                        var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                            "url": "/lightning/o/buildertek__Pricing_Request_Line_Details__c/list?filterName=Recent"
                        });
                        urlEvent.fire();


                        $A.get("e.force:closeQuickAction").fire();
                        window.setTimeout(
                            $A.getCallback(function() {
                                $A.get('e.force:refreshView').fire();
                            }), 1000
                        );
                    }

                })
                .catch(function(error) {
                    console.log(error);
                });
            } else {
                var recordId = component.get("v.recordId");
                if (recordId) {
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": recordId,
                        "slideDevName": "detail"
                    });
                    navEvt.fire();
                } else {
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": "/lightning/o/buildertek__Pricing_Request_Line_Details__c/list?filterName=Recent"
                    });
                    urlEvent.fire();


                    $A.get("e.force:closeQuickAction").fire();
                    window.setTimeout(
                        $A.getCallback(function() {
                            $A.get('e.force:refreshView').fire();
                        }), 1000
                    );
                }

            }

        });

    },
        
        
})