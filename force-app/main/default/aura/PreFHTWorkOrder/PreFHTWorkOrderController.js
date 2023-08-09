({
    doInit: function (component, event, helper) {
        var flow = component.find("flowData");
        var recordId = component.get("v.recordId");
        //If launched from case
        if(recordId!=undefined && recordId.startsWith("500")){
            var inputVariables = [
                {
                    name : "VarCaseId",
                    type : "String",
                    value : recordId
                }            
            ];
            console.log('In Case flow');
            //Start your flow. Reference the flow's Unique Name.
            flow.startFlow("Pre_FHT_Work_Order", inputVariables );
        }//if launched from customer site execute else block
        else if(recordId!=undefined && !recordId.startsWith("500")){
            var inputVariables = [
                {
                    name : "VarCustomerSiteID",
                    type : "String",
                    value : recordId
                }            
            ];
            console.log('in others');
            //Start your flow. Reference the flow's Unique Name.
            flow.startFlow("New_Functional_Hardware_Testing_Work_Order", inputVariables );
        }
        
        
    },
    handleStatusChange : function (component, event,helper) {
        if(event.getParam("status") === "FINISHED") {
            var workOrderId;
            var outputVariables = event.getParam("outputVariables");
            var outputVar;
            for(var i = 0; i < outputVariables.length; i++) {
                outputVar = outputVariables[i];
                if(outputVar.name === "VarWorkOrder") {
                    workOrderId = outputVar.value.Id;
                }
            }
            if(workOrderId!= null && workOrderId != undefined){
                var redirectToWorkOrder = component.get("v.vrRedirectMethod");
                redirectToWorkOrder(workOrderId, function(){
                });
            }
        }
    }
})