({
    getContentVersionId : function(component,event,helper,selectionChoices,documentId,rowNumber) {
        var action = component.get("c.retriveContentVersionId");
        action.setParams({
            documentId: documentId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS" && response.getReturnValue() && response.getReturnValue()!='Error') {
                selectionChoices[rowNumber].buildertek__Image_Id__c = response.getReturnValue();
                selectionChoices[rowNumber].buildertek__Document_Id__c = documentId;
            } else if (state === "ERROR") {
                console.log('A Problem Occurred: ' + JSON.stringify(response.error));
            }
        });
        $A.enqueueAction(action);
    }
})