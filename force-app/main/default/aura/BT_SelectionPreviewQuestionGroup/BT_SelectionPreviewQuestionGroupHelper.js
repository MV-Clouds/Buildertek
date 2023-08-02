({
	update : function(component, event, helper ,selectionTypeobj, checkResults, answerChoices) { 
		$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
		var selectionTypeJSON = JSON.stringify(component.get("v.st"));
		
		var submitSelectionType = component.get("c.submitSelectionType");
        submitSelectionType.setParams({ 
        	"selectionType":selectionTypeobj,
            "checkresult": checkResults,
            "answerChoices":answerChoices
        });
        submitSelectionType.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            	if(response.getReturnValue()) {
            		component.find('notifLib').showNotice({
                        "variant": "success",
                        "header": "Submitted Successfully",
                        "message": "Selection option submitted successfully",
                        "closeCallback" : function(){
                        	component.set("v.st",response.getReturnValue());
                        	var refreshTreeNode = $A.get("e.c:BT_RefreshTreeNodeEvent");
		                   refreshTreeNode.setParams({"key" : "ALL_TREE"});
                            //refreshTreeNode.fire();
                            var selectionCatagory = component.get("v.selectionCatagory");
                            var sectionWiseTotalQuestionCount={};
                            var sectionWiseTotalAnswerCount={};
                            var totalOptions=0;
                            var sectionWiseTotalQuestionCountMap = new Map();
                            var sectionWiseTotalAnswerCountMap = new Map();
                            if(selectionCatagory.Id != undefined){
                                var treeNodeClickEvent = $A.get("e.c:BT_TreeNodeClickEvent");
                                if(treeNodeClickEvent){ 
                                    treeNodeClickEvent.setParams({"nodeData" : {"childObjectType":"buildertek__Section__c","key":selectionCatagory.Id}});
                                    treeNodeClickEvent.fire();
                                }
                            }
                           console.log('selectionCatagory=====>',selectionCatagory);
                        }
                    });
                    
            		$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
                } else {
                	$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
                }
            } else if (state === "ERROR") {
            	$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert(errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            
            
        });
        $A.enqueueAction(submitSelectionType);
	}
})