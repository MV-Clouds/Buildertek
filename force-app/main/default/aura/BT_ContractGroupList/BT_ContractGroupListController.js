({
	init : function(component, event, helper) {
		helper.getGroups(component, event, helper);
	},
	
	groupLoaded : function(component, event, helper) {
		$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
	},
	
	newGroup: function(component, event, helper){
		$A.createComponents(
            [
                ["aura:html", {
                    "tag": "h2",
                    "body": "New Contract Group",
                    "HTMLAttributes": { 
                        "class": "slds-text-heading_medium slds-hyphenate" 
                    }
                }],
                ["c:BT_NewContractGroup", {
                    "contractId" : component.get("v.contractId"),
                    "onSuccess" : function(){
                    	helper.getGroups(component, event, helper);
                    }
                }], 
                
            ], function(components, status) {
                if (status === 'SUCCESS') {
                    component.find('overlayLib').showCustomModal({
                        header: components[0],
                        body: components[1],
                        footer:components[1].find("footer"),
                        showCloseButton: true,
                        cssClass: 'slds-modal_large'
                    });
                    
                }
            });
	},
	handleComponentEvent : function(component, event, helper) {
        // get the selected Account record from the COMPONETN event 	 
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        component.set("v.productId",selectedAccountGetFromEvent.Id);
        component.set("v.productName",selectedAccountGetFromEvent.Name);
        helper.getProductDetails(component,event,helper);
    },
    saveContractLineRecord: function (component, event, helper) {
        component.set("v.Spinner", true); 
        var quoteObject = component.get("v.newContractLine");
        var recordId = component.get("v.contractId");
        component.set("v.newContractLine.buildertek__Contract__c",recordId);
        //quoteObject.buildertek__Contract__c = component.get("v.contractId");
        
        var action = component.get("c.saveContractLineItem");
        action.setParams({"contractRecord":JSON.stringify(quoteObject)});
        action.setCallback(this,function(respo){
            if (component.isValid() && respo.getState() === "SUCCESS") {
                var group = component.find('groupId');
                group.set("v._text_value", '');
                var costCode = component.find('costCodeId');
                costCode.set("v._text_value", '');
                var product = component.get('v.selectedLookUpRecord');
                var compEvent = $A.get('e.c:BT_CLearLightningLookupEvent');
                compEvent.setParams({"recordByEvent" : product });  
                compEvent.fire();
                component.set('v.newContractLine.Name', '');
                component.set('v.newContractLine.buildertek__Unit_Price__c', null);
                component.set('v.newContractLine.buildertek__Cost_Code__c', null);
                component.set('v.newContractLine.buildertek__Contract_Item_Group__c', null);
                component.set('v.newContractLine.buildertek__Quantity__c', null);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "",
                    "message": "Contract Line Added succesfully.",
                    "type": "success"
                });
                toastEvent.fire();
                component.set("v.Spinner", false); 
                component.refreshData();
                $A.get('e.force:refreshView').fire();
                
            }
        });
        $A.enqueueAction(action);
    },
    handleEvent  : function(component, event, helper){
        var message = event.getParam("message");
        var toastEvent = $A.get("e.force:showToast");
		        toastEvent.setParams({
			        "title": "",
			        "message": message,
			        "type": "success"
		        });
		 component.refreshData();
		 $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
    },
    
    handleHeaderAction: function (component, event, helper) {
        var checkbox = component.get("v.parentAttribute");
        //alert('checkbox --> '+checkbox);
        if(checkbox == false){
            var setRows = []; 
            var grouplist = component.get("v.groups");
            var Jsonvalue = '[';
            // alert('Hiii');
            for(var i=0;i< grouplist.length;i++){
                Jsonvalue += '{"GroupId": "'+ grouplist[i].Id + '"';
                Jsonvalue += ',"lineItems" :[';
               // alert('Hiii'); 
                for (var j = 0; j < grouplist[i].buildertek__Contract_Lines__r.length; j++){
                    Jsonvalue += '{ "Id": "' + grouplist[i].buildertek__Contract_Lines__r[j].Id + '"}';
                    if(j < (grouplist[i].buildertek__Contract_Lines__r.length-1)){
                       Jsonvalue += ','; 
                    }
                }
                Jsonvalue += ']}';
                if(i < (grouplist.length-1)){
                       Jsonvalue += ','; 
                }
                //alert('Initial setRows --------> '+Jsonvalue);
                 
            }
            Jsonvalue += ']';
            var jsonparse = JSON.parse(Jsonvalue);
                 setRows = jsonparse;
                 console.log('Initial setRows --------> '+JSON.stringify(setRows));
                 console.log(setRows);
                 component.set("v.selectedRows", setRows);
            component.set("v.parentAttribute",true);
        }else{
            component.set("v.parentAttribute",false);
        }
        
    },
})