({
	getParameterByName: function (component, event, name) {
		name = name.replace(/[\[\]]/g, "\\$&");
		var url = window.location.href;
		var regex = new RegExp("[?&]" + name + "(=1\.([^&#]*)|&|#|$)");
		var results = regex.exec(url);
		if (!results) return null;
		if (!results[2]) return '';
		return decodeURIComponent(results[2].replace(/\+/g, " "));
	},
	getFields: function (component, event, helper) {
		var action = component.get("c.getFieldSet");
		action.setParams({
			objectName: 'buildertek__Warranty__c',
			fieldSetName: 'buildertek__New_Warranty_Field_Set'
		});
		action.setCallback(this, function (response) {
			if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
				var listOfFields = JSON.parse(response.getReturnValue());
                component.set("v.listOfFields", listOfFields);
			} else {
				console.log('Error');
			}
		});
		$A.enqueueAction(action);
	},
    getparentrecord : function (component, event, helper) {
     /*   var action = component.get("c.getParentObjRec");
          action.setParams({ 
            parentrecordid :  component.get("v.parentRecordId")
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var response = response.getReturnValue();
                var lookuprec = response.LookupRec;
                var ObjName = response.ObjectName;
                component.set('v.parentobjectName',ObjName);
            }
            });
            $A.enqueueAction(action);*/
        var action = component.get("c.getNames");
          action.setParams({ 
            parentrecordid :  component.get("v.parentRecordId")
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var response = response.getReturnValue();
                component.set('v.effectiveDate',response.buildertek__Estimated_Completion_Date__c);
            }
            });
            $A.enqueueAction(action);
        },
    savehelper: function (component, event) {
        var warrantyValue = component.get("v.value");
      //  alert('***********'+warrantyValue);
       var lagvalue =  component.get("v.lagValue");
       // alert('&&&&&&&&&'+lagvalue);
        var action = component.get("c.getwarrantyRec");
        action.setParams({
            warrantyvalue : warrantyValue,
            lagvalue : lagvalue
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                var result = response.getReturnValue();
                if( lagvalue != null){
                    var data_in = result.buildertek__Due_Date__c;
                    var data_out = new Date(data_in);
                    data_out.setDate(data_out.getDate() + result.buildertek__Lag_Value__c);
                    component.set("v.effectiveDate",data_out.toISOString());
                    
                }else{
                   component.set("v.effectiveDate", result.buildertek__Due_Date__c); 
                }
                component.set("v.nextwarranty", result.buildertek__Warranty__c);
            } else {
                console.log("There was a problem : " + response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    getpreviousWarrantyRec: function (component, event, helper) {
         var warrantyRec = component.get("v.parentRecordId"); 
       // var warrantyRec = component.find("projectlookupid").get("v.value");
        if(warrantyRec != ''){
            var action = component.get("c.warrantydetails");
            action.setParams({
                projectrecId: warrantyRec
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                   // alert(JSON.stringify(result));
                    if(result != ''){
                        component.set("v.warrantyList",result);
                        component.set("v.isWarranty",true); 
                        component.set("v.isnewwarranty",false); 
                    }
                    else {
                        component.set("v.isWarranty",false);
                        component.set("v.isnewwarranty",true); 
                    }
                }
            });
            $A.enqueueAction(action); 
        }
        else if(warrantyRec == ''){
            component.set("v.isWarranty",false);
            component.set("v.isnewwarranty",true); 
        }
    },
    updateDueDate :  function (component, event, helper) {
       var newwarrantyId = component.get("v.newwarrantyId"); 
        var selectedwarrantyId = component.get("v.value");
        var action = component.get("c.newWarranty");
            action.setParams({
                warrantyId: newwarrantyId,
                selectedwarrantyId : selectedwarrantyId
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                }
            });
            $A.enqueueAction(action); 
    },
})