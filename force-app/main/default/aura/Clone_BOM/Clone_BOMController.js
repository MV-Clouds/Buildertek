({
    doInit: function (component, event, helper) {
        var action = component.get("c.getCurrentVersion");
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.currentVersion", result.buildertek__Version_Number__c);
                component.set("v.BOMNameValue", result.buildertek__Name__c);
            }
        });

        $A.enqueueAction(action);
    },


    handleClick: function (component, event, helper) {
        var regExp = /[a-zA-Z]/g;
        var reg = /[!@#$%^&*()_+\-=\[\]{};:\\|,.<>\/?]+/;

        var testString = "john";
        var vValue = component.get("v.versionValue")
        // if (component.get("v.versionValue")) {
            // if (regExp.test(component.get("v.versionValue")) || reg.test(component.get("v.versionValue")) || vValue.indexOf('"') > -1 || vValue.indexOf("'") > -1) {
            //     var toastEvent = $A.get("e.force:showToast");
            //     toastEvent.setParams({
            //         title: '',
            //         message: 'Enter a valid version number',
            //         duration: ' 5000',
            //         key: 'info_alt',
            //         type: 'error',
            //         mode: 'pester'
            //     });
            //     toastEvent.fire();
            // } else {
                component.set("v.Spinner", true);
                // alert( component.get("v.versionValue"));
                var action = component.get("c.cloneAnySobjet");
                action.setParams({
                    "recordId": component.get("v.recordId"),
                    "version": component.get("v.versionValue"),
                    "BOMName": component.get("v.BOMNameValue")
                });
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var result = response.getReturnValue();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: 'Success',
                            message: 'BOM Cloned Successfully',
                            duration: ' 5000',
                            key: 'info_alt',
                            type: 'success',
                            mode: 'pester'
                        });
                        toastEvent.fire();


                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": result,
                            "slideDevName": "Detail"
                        });
                        navEvt.fire();
                        component.set("v.Spinner", false);
                    }
                });

                $A.enqueueAction(action);

            // }
        // } 
        // else {

        //     var toastEvent = $A.get("e.force:showToast");
        //     toastEvent.setParams({
        //         title: '',
        //         message: 'Version should not be null',
        //         duration: ' 5000',
        //         key: 'info_alt',
        //         type: 'error',
        //         mode: 'pester'
        //     });
        //     toastEvent.fire();
        // }
    },
    closeModel: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
})