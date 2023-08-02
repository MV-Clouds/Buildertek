({
	doInit : function(component, event, helper) {
        var questionRec = JSON.parse(JSON.stringify(component.get('v.question')));

        questionRec.check != undefined && questionRec.check.buildertek__Image_Id__c != undefined ? component.set('v.imageId',questionRec.check.buildertek__Image_Id__c):'';
        questionRec.check != undefined && questionRec.check.buildertek__Question_HTML__c != undefined ? component.set('v.optionName',questionRec.check.buildertek__Question_HTML__c):'';
        questionRec.check != undefined && questionRec.check.buildertek__Additional_Cost__c != undefined ? component.set('v.additionalCost',questionRec.check.buildertek__Additional_Cost__c):'';
        questionRec.check != undefined && questionRec.check.buildertek__Color__c != undefined ? component.set('v.color',questionRec.check.buildertek__Color__c):'';
        questionRec.check != undefined && questionRec.check.buildertek__Instructions__c != undefined ? component.set('v.instructions',questionRec.check.buildertek__Instructions__c):'';
        questionRec.check != undefined && questionRec.check.buildertek__Cost__c != undefined ? component.set('v.cost',questionRec.check.buildertek__Cost__c):'';
        console.log('Image id::',component.get('v.imageId'));
        questionRec.contentDocumentLink!=undefined ? component.set('v.ContentDocument',questionRec.contentDocumentLink):'';
        
        var action = component.get("c.checkIfCustomerCommunity");
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            if (state === "SUCCESS") {
                component.set('v.isCustomerCommunity',response.getReturnValue());
            }
        });
        $A.enqueueAction(action); 
    },
    
    onShowDocument : function(component,event,helper){
        var target = event.target; 
        var documentId = target.getAttribute("data-documentId");
        if(documentId != undefined && documentId != ''){
            component.set("v.currentDocumentId",documentId);
            component.set("v.hasModalOpen",true); 
        }
    },
    
    closeModel:function(component,event,helper){
        component.set("v.hasModalOpen",false); 
    }
})