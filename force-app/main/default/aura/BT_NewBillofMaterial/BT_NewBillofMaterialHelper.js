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
               // component.find("Name").set("v.autocomplete","off");
            } else {
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
    },
    vendors: function (component, event, helper) {
        var parentId = component.get("v.parentRecordId")
        var action = component.get("c.getNames");
        action.setParams({
					RecordId: parentId
				});
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS') {
                
               var NameOfVendor = response.getReturnValue();
                
                component.set("v.parentprojectId", NameOfVendor);
            } else {
                console.log('Error');
            }
             });
        $A.enqueueAction(action);
    },
    
    saveandnext: function (component, event, helper) {
        var Name = component.get("v.bomName");
        var parentprojectId = component.get("v.parentprojectId");
        var action = component.get("c.gettakeoffline");
        action.setParams({
            RecordId: parentprojectId
        });
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS') {
                var result = response.getReturnValue();
                component.set("v.ImportVendorPaymentAppsList", result);
                if(result.length == 0){
                     component.set("v.islines", true);
                }else{
                    component.set("v.islines", false); 
                }
            } else {
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
    }
    
        
})