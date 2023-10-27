({
    doInit : function(component, event, helper) {
        console.log('record Id :: ', component.get("v.recordId"));
        var Fields = [];
        var getFields = component.get("c.getFieldSet");
        getFields.setParams({
            objectName: 'buildertek__Purchase_Order_Item__c',
            fieldSetName: 'buildertek__Edit_Purchase_Order_Line'
        });
        getFields.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                var listOfFields = JSON.parse(response.getReturnValue());
               
                listOfFields.map(ele => {
                    Fields.push(ele.name);
                })
                console.log({listOfFields});
                component.set("v.listOfFields", listOfFields);
                component.set("v.TotalFields", listOfFields.length);
                console.log('TotalFields : ', component.get("v.TotalFields"));
                component.set("v.isLoading", false);
            }
        });
        $A.enqueueAction(getFields);
        console.log('Fields  :: ', Fields);
        console.log('Fields 2 :: ', JSON.stringify(Fields));

        // component.set("v.RecordID", component.get("v.recordId"))

        var getRecordData = component.get("c.getRecordData");
        getRecordData.setParams({
            recordId : component.get("v.recordId"),
            FieldsToQuery : JSON.stringify(Fields)
        });
        getRecordData.setCallback(this, function (response) {
            var state = response.getState();
            console.log('status :: ', state);
            console.log('error :: ', response.getError());
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result :: ', result);
                component.set("v.POline", result);
            } else {
                var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					"type": "Error",
					"title": "Error!",
					"message": "Something Went Wrong."
				});
				toastEvent.fire();
            }
        });
        $A.enqueueAction(getRecordData);

        try {
        } catch (error) {
            console.log('error in get field set :=> ', error.stack);
        }
    },

    editRecord : function(component, event, helper) {
        try {
            console.log('Edit Record');
            // helper.doInithelper(component, event, helper)
            component.set("v.viewMode", false);
            
        } catch (error) {
            console.log('error in editRecord ', error.stack);
            
        }
    },

    leaveEditForm : function(component, event, helper){
        $A.get('e.force:refreshView').fire();
        component.set("v.viewMode", true);
    }, 

    saveRecord : function(component, event, helper){
        console.log('Save Record', component.get('v.POline'));
        event.preventDefault();
        var fields = event.getParam("fields");
        console.log('fields', JSON.parse(JSON.stringify(fields)));
        console.log('recordId : ' + component.get("v.recordId"));
        var updatedData = JSON.stringify(fields);
        var action = component.get("c.updateRecord");
        action.setParams({            
            updatedData : updatedData,
            recordID : component.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            component.set("v.viewMode", true);
            var state = response.getState();
            console.log('state ==> '+state);
            if (state === "SUCCESS") {
                $A.get('e.force:refreshView').fire();
            } else {
                var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					"type": "Error",
					"title": "Error!",
					"message": "Something Went Wrong."
				});
				toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }, 
})
