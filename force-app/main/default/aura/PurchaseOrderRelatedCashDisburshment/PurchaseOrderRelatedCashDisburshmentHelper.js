({
    fetchCDData: function (component,event,helper) {
        var POId = component.get("v.recordId");
        console.log("POID" , POId);
        var action = component.get("c.getCashDisbursementData");
        action.setParams({
            PORecId: POId
        });
        action.setCallback(this, function (response) {
          var state = response.getState();
          if (state === "SUCCESS") {
            console.log('Hi->',response.getReturnValue());
            var records = response.getReturnValue();
            records.forEach(function (record) {
                record['buildertek__Payment__c'] = '/' + record['Id']; // Set the URL dynamically
                record['ProjectName'] = record['buildertek__Project__r'] ? record['buildertek__Project__r']['Name'] : '';

            });
            component.set("v.data", records);
          }else {
            var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Error',
                    message: 'Some thing went wrong.',
                    duration: ' 5000',
                    type: 'error'
                });
                toastEvent.fire();
          }
        });
        $A.enqueueAction(action);
    }
});
