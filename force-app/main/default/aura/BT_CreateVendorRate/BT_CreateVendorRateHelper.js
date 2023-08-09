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
		action.setParams({
			objectName: 'buildertek__Rates__c',
			fieldSetName: 'buildertek__Rate_Field_Set'
		});
		action.setCallback(this, function (response) {
             //alert(response.getState());
             //alert(response.getReturnValue());
			if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
				var listOfFields = JSON.parse(response.getReturnValue());
				component.set("v.listOfFields", listOfFields);
                /*var listofchange = component.get("v.listOfFields");
                var collist = [];
                for (var i = 0; i < listofchange.length; i++) {                   
                    component.set("v.listOfFields",collist);
                }*/
                //alert(JSON.stringify(listOfFields));
            } else {
                console.log('Error');
            }
		});
		$A.enqueueAction(action);
	},
    geterror: function (component, event, helper) {
		var workspaceAPI = component.find("workspace");
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
     
     getMessage : function (component, event, helper) {
        component.set('v.isLoading', false);
        setTimeout(function () {
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function (response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({
                    tabId: focusedTabId
                });
            }).catch(function (error) {
                console.log('Error', JSON.stringify(error));
            });
           // setTimeout(function () {
           // component.set("v.ismessage",false);
            var url = location.href;
            var baseURL = url.substring(0, url.indexOf('/', 14));
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                mode: 'sticky',
                message: 'Time Card created successfully',
                messageTemplate: "Time Card created successfully.",
                messageTemplateData: [{
                    url: baseURL + '/lightning/r/buildertek__Rates__c/' + escape(component.get("v.timecardRecordId")) + '/view',
                    label: component.get("v.timecardRecordName"),
                }],
                type: 'success',
                duration: '10000',
                mode: 'dismissible'
            });
            toastEvent.fire();
               // $A.get("e.force:closeQuickAction").fire();
             setTimeout(function () {
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": component.get("v.timecardRecordId"),
                "slideDevName": "related"
            });
            navEvt.fire(); 
        }, 100);
            component.set("v.ismessage",false); 
        }, 2000);
    },
    showErrorToast: function (component, event, helper,title,message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            duration: '5000',
            type: 'warning',
            mode: 'pester'
        });
        toastEvent.fire();
    },
})