({
    searchHelper: function(component, event, getInputkeyWord) {
        console.log('searchHelper');
        console.log('getInputkeyWord' + getInputkeyWord);
        console.log(component.get("v.objectAPIName"));
        console.log(component.get('v.recordId'));

        // call the apex class method 
        var action = component.get("c.fetchLookUpValues");
        // set param to method  
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'ObjectName': component.get("v.objectAPIName"),
            'ExcludeitemsList': component.get("v.lstSelectedRecords"),
            'isPreQual': component.get("v.isPreQualProcess"),
            'recId': component.get("v.recordId")
        });
        // set a callBack    
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            console.log('state' + state);
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log('storeResponse' + storeResponse);
                // if storeResponse size is equal 0 ,display No Records Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Records Found...');
                } else {
                    component.set("v.Message", '');
                    // set searchResult list with return value from server.
                }
                component.set("v.listOfSearchRecords", storeResponse);
            }
        });
        // enqueue the Action  
        $A.enqueueAction(action);
    },
    onblur: function(component, event, helper) {

        component.set("v.listOfSearchRecords", null);
        component.set("v.SearchKeyWord", '');
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');

},
})