({
    /*Get the fields list form fieldset based on section record type Name */
    getFieldSet : function(component) {
        var sectionRecord = component.get("v.section")
        var fieldSet = "buildertek__Question_Group_FieldSet";
        var getFieldSet = component.get("c.getControlDetails");
        getFieldSet.setParams({fieldSetName : fieldSet});
        
        getFieldSet.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.controlDetails",response.getReturnValue());
                component.set("v.namespace",response.getReturnValue().namespacePrefix);
            }
        });
        $A.enqueueAction(getFieldSet);
    },
    listQuestionTypes : function(component) {
        var items = [];
        items.push({"label": "Single Select With Drop Down", "value": "Single Select~Drop Down"});
        items.push({"label": "Single Select With Radio", "value": "Single Select~Radio"});
        items.push({"label": "Single Select With Horizontal Radio", "value": "Single Select~Radio-lineDirection"});
        items.push({"label": "Multi Select With Checkbox", "value": "Multi Select~Checkbox"});
        items.push({"label": "Multi Select With Horizontal Checkbox", "value": "Multi Select~Checkbox-lineDirection"});
        items.push({"label": "Multi Select With Drop Down", "value": "Multi Select~Multi Select List"});
        items.push({"label": "Simple Text", "value": "Text~Simple Text"});
        items.push({"label": "Long Text", "value": "Text~Text Area"});
        items.push({"label": "Date", "value": "Date~Date Picker"});
        
        component.set("v.responsetypeOptions",items);
        component.set("v.selectedResponsetypeValue","Single Select~Radio-lineDirection");
        
    },
})