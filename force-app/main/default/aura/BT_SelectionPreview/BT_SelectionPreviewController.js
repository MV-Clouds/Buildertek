({
    doInit: function (component, event, helper) {
        /*
		$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
		var retrieveAllQuestionResults = component.get("c.retrieveAllQuestionResults");
        retrieveAllQuestionResults.setParams({
            "selectionSheetid": component.get("v.recordId"),
            "sectionId":""
        });
        retrieveAllQuestionResults.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(JSON.parse(JSON.stringify(response.getReturnValue().selectionCatagorys)));
                component.set("v.selectionCatagorys",response.getReturnValue().selectionCatagorys);
                component.set("v.catagoryHeaderFields",response.getReturnValue().sectionCatagoryFields);
                component.set("v.typeHeaderFields",response.getReturnValue().sectionTypeHeaderFields);
                component.set("v.optionHeaderFields",response.getReturnValue().sectionOptionHeaderFields);
                $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
            }
        });
        $A.enqueueAction(retrieveAllQuestionResults); 
        */
        debugger;
        helper.defaultTreeFilterCondition(component);
    },
    handleTreeNodeClick: function (component, event, helper) {
        debugger;
        console.log('BT_SelectionPreview.handleTreeNodeClick :: ' + JSON.stringify(event.getParam("nodeData")));
        var nodeData = event.getParam("nodeData"),
            actionType = event.getParam("actionType");
        var key = '';
        if ((nodeData.childObjectType == undefined || nodeData.childObjectType == '') && nodeData.id != undefined) {
            var nodeId = nodeData.id.split('/');
            if (nodeId.length > 2) {
                key = nodeId[1];
            }
        }

        if (nodeData.childObjectType === 'buildertek__Section__c' || nodeData.childObjectType === 'buildertek__Question_Group__c' || (key != undefined && key != '')) {
            if (nodeData.childObjectType == 'buildertek__Section__c' || nodeData.childObjectType == 'buildertek__Question_Group__c') {
                key = nodeData.key;
            }
            if (component.get("v.sectionPrefix") != undefined || component.get("v.sectionPrefix") == '') {
                component.set("v.sectionPrefix", key.substring(0, 3));
            }
            $A.get("e.c:BT_SpinnerEvent").setParams({
                "action": "SHOW"
            }).fire();
            var retrieveAllQuestionResults = component.get("c.retrieveAllQuestionResults");
            retrieveAllQuestionResults.setParams({
                "selectionSheetid": component.get("v.recordId"),
                "sectionId": key
            });
            retrieveAllQuestionResults.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log('selectionCatagorys::', response.getReturnValue().selectionCatagorys);
                    var selectionCategorys = JSON.parse(JSON.stringify(response.getReturnValue().selectionCatagorys));
                    var jsonArr = [];
                    var uniqueName = [];

                    component.set("v.selectionCatagorys", response.getReturnValue().selectionCatagorys);
                    component.set("v.catagoryHeaderFields", response.getReturnValue().sectionCatagoryFields);
                    component.set("v.typeHeaderFields", response.getReturnValue().sectionTypeHeaderFields);
                    console.log('typeHeaderFields::', JSON.parse(JSON.stringify(component.get('v.typeHeaderFields'))));
                    component.set("v.optionHeaderFields", response.getReturnValue().sectionOptionHeaderFields);
                    $A.get("e.c:BT_SpinnerEvent").setParams({
                        "action": "HIDE"
                    }).fire();
                } else {
                    $A.get("e.c:BT_SpinnerEvent").setParams({
                        "action": "HIDE"
                    }).fire();
                }
            });
            $A.enqueueAction(retrieveAllQuestionResults);
        }
    },
    Submit: function (component, event, helper) {
        var allSelectionTypes = component.get("v.selectionCatagorys")[0].selectionTypes;
        console.log(allSelectionTypes);
    },

})