({
    getParameterByName: function (component, event, name) {
        console.log("Name" , name);
        name = name.replace(/[\[\]]/g, "\\$&");
        var url = window.location.href;
        console.log('url', url);
        if(url != null){
            //if condition to check if the url has the string 'buildertek__Project__c' in it
            if(url.indexOf('%2Fbuildertek__Project__c%2F') != -1){
                var newurl2 = url.substring(url.indexOf('%2Fbuildertek__Project__c%2F') + 28, url.indexOf('%2Fview'));
                if(newurl2 != null){
                    console.log('newurl2', newurl2);
                    component.set("v.parentRecordId", newurl2);
                }
            }
        }
        var regex = new RegExp("[?&]" + name + "(=1\.([^&#]*)|&|#|$)");
        console.log("regax" , regex);
        var results = regex.exec(url);
        console.log("result" , results);
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
            } else {
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
    }
})