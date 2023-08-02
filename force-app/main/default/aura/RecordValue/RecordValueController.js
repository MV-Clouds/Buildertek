({
    doInit : function(component, event, helper) {
        var record = component.get("v.record");
        var field =  component.get("v.field");   
        var fieldAPI;
		var value;
        if(field != undefined){
            fieldAPI = field.fieldAPIName;
			value = record[fieldAPI];
        }        
        if(fieldAPI != undefined && fieldAPI.includes(".")){
            var response = fieldAPI.split(".");
            var value = record[response[0]][response[1]];
            var urlValue = record[field.urlFieldAPI];
            component.set("v.cellLabel", value);
            component.set("v.cellValue", urlValue);
        }
        else{
            component.set("v.cellLabel", value);
        }
    }
})