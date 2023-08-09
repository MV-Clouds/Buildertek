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
    getFields: function (component, event, helper,selectedRecordTypeId) {    
       component.set('v.isLoading', true);
        var action = component.get("c.getFieldSet");
        action.setParams({
            selectedRecordTypeId: selectedRecordTypeId,
        });
        action.setCallback(this, function (response) {

            if (response.getState() == 'SUCCESS' ) {
                component.set('v.isLoading', false);
                //var listOfFields = JSON.parse(response.getReturnValue());
                  // $A.get('e.force:refreshView').fire();
                var result =  response.getReturnValue()+'';
            
              //  console.log("feildset : ",JSON.parse(response.getReturnValue()))
                var listOfFields = result.split('~')[0];
                var COType = result.split('~')[1];                                 
                component.set("v.listOfFields",JSON.parse(listOfFields));
                component.set("v.COType",COType);               
                
               // component.find("Name").set("v.autocomplete","off");
            } else {
                component.set('v.isLoading', false);
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
    },

    
    CustomerAccount: function (component, event, helper) {
        var parentId = component.get("v.parentprojectRecordId")
        var action = component.get("c.getNames");
        action.setParams({
					RecordId: parentId
				});
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS') {
                
               var CustomerAccountName = response.getReturnValue();
                
                component.set("v.CustomerAccountName", CustomerAccountName);
            } else {
                console.log('Error');
            }
             });
        var action1 = component.get("c.getContractNames");
        action1.setParams({
            RecordId: parentId
        });
        action1.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS') {
                var CustomerAccountName = response.getReturnValue();
                component.set("v.parentContractRecordId", CustomerAccountName);
            } else {
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
         $A.enqueueAction(action1);
    },
    getproject : function (component, event, helper) {
        var parentId = component.get("v.parentContractRecordId")
        var action = component.get("c.getproject");
        action.setParams({
					RecordId: parentId
				});
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS') {
               var projectId = response.getReturnValue();
                component.set("v.parentprojectRecordId", projectId);
            } else {
                console.log('Error');
            }
             });
        $A.enqueueAction(action);
    },
    
    getRecType : function (component, event, helper) {
        component.set('v.isLoading', true);
        var recType = component.get("c.getRecordTypeName");
        recType.setParams({
            recTypeId : component.get("v.RecordTypeId")
        });
        recType.setCallback(this, function (response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log(result);
                if(result != null){
                    component.set("v.RecordTypeId",result);
                    component.set('v.isLoading', false);
                     helper.getFields(component, event, helper,result);
                }
            }else{
                component.set('v.isLoading', false);
            }
        });
        $A.enqueueAction(recType);
    },

    setCOLines:function (component, event, helper) {
        try{
            var listofCOItems=component.get("v.coLineList");
            listofCOItems.push({
                'index':listofCOItems.length,
                'Name': '',
                'buildertek__Quantity__c': '',
                'buildertek__Unit_Price__c': '',
                'buildertek__Markup__c': '',
            });
            component.set("v.coLineList" , listofCOItems);
        }catch(error){
            console.log({error});
        }
       
    
    },
    saveCOLineItems : function(component, event, helper, recordId) {
		var listofCOItems = component.get("v.coLineList");
        console.log({listofCOItems});
		var listofCOItemsToSave = [];
		for (var i = 0; i < listofCOItems.length; i++){
            console.log(listofCOItems[i].Name);
			if (listofCOItems[i].Name != undefined && listofCOItems[i].Name != '' ) {
				// listofPOItemsToSave.push(listofPOItems[i]);
				let coLineObj = {
					'Name' : listofCOItems[i].Name,
					'buildertek__Quantity__c' : listofCOItems[i].buildertek__Quantity__c,
					'buildertek__Unit_Price__c' : listofCOItems[i].buildertek__Unit_Price__c,
					'buildertek__Markup__c' : listofCOItems[i].buildertek__Markup__c,
				}
				listofCOItemsToSave.push(coLineObj);
			}
		}
		console.log('listofPOItemsToSave-->>',{listofCOItemsToSave});
		console.log('recordId-->>',{recordId});
        if(listofCOItemsToSave.length > 0){
            var action = component.get("c.saveCOLineItems");
            action.setParams({
                listofCOItemsToSave: listofCOItemsToSave,
                recordId: recordId
            });
            action.setCallback(this, function (response) {
                console.log('response.getState()'+ response.getState());
                if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                    console.log('inserted');
                    console.log(response.getReturnValue());
                }
            });
            $A.enqueueAction(action);

        }
		

       
	},
    
})