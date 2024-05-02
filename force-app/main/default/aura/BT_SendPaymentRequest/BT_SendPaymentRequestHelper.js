({
    getOwnerNameAndCompanyName: function(component, recordId) {
        var action = component.get("c.getOwnerNameAndCompanyName");
        action.setParams({
            recordId: recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var response = response.getReturnValue();
                console.log('response: ' + JSON.stringify(response));
                //whatever is before the - is the response
                var ownerName = response.split('-')[0];
                var companyName = response.split('-')[1];
                if (ownerName != null && ownerName != '') {
                    console.log('ownerName: ' + ownerName);
                    component.set('v.orgName', ownerName);
                }
                if (companyName != null && companyName != '' && companyName != 'null') {
                    console.log('companyName: ' + companyName);
                    component.set('v.companyName', companyName);
                }
            } else {
                console.log('Error in getting owner name and company name');
            }
        });
        $A.enqueueAction(action);
    },
})