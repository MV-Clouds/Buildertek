({
	doInit : function(component, event, helper) {
	    component.set("v.isOpen", true);
		//component.find('MQId').set("v.value", parentRecordId);
	}, 
	
	handleComponentEvent : function(component, event, helper) {
	    var selectedAccountGetFromEvent = event.getParam("recordByEvent");
	    component.set("v.newQuoteItem.buildertek__Master_Quote_Item_Name__c",selectedAccountGetFromEvent.Name);
	    component.set("v.newQuoteItem.buildertek__Product__c",selectedAccountGetFromEvent.Id);
	    component.set("v.productId", selectedAccountGetFromEvent.Id);
		component.set("v.productName", selectedAccountGetFromEvent.Name);
	    helper.getProductDetails(component, event, helper);
    },
    
    handleComponentEvents : function(component, event, helper) {
	    var selectedAccountGetFromEvent = event.getParam("recordByEvent");
	    component.set("v.newQuoteItem.buildertek__Master_Quote_Item_Name__c",selectedAccountGetFromEvent.Name);
	    component.set("v.newQuoteItem.buildertek__Product__c",selectedAccountGetFromEvent.Id);
	    component.set("v.productId", selectedAccountGetFromEvent.Id);
		component.set("v.productName", selectedAccountGetFromEvent.Name);
	    helper.getProductDetails(component, event, helper);
    },
	
	closeModel: function(component, event, helper) {
      // for Hide/Close Model,set the "isOpen" attribute to "Fasle" 
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
        $A.get("e.force:closeQuickAction").fire();
        component.set("v.isOpen", false);
        var parentRecordId = component.get("v.parentRecordId");
        if(parentRecordId != undefined){
               
        }else{
            var url = location.href;
            var baseURL = url.substring(0, url.indexOf('/', 14));
            //alert('baseURL -------> '+baseURL);
            window.open(baseURL+'/lightning/o/buildertek__Master_Quote_Item__c/list?filterName=Recent', '_self');
        }
        
   },
   
   save : function(component, event, helper) {
        var selectedCostCode = component.get("v.selectedCostCode");
        var costcode;
        if(selectedCostCode != undefined){
            costcode = selectedCostCode.Id;     
        }else{
            costcode = null;
        }
        var selectedAccount = component.get("v.selectedAccount");
        var selAccount;
        if(selectedAccount != undefined){
            selAccount = selectedAccount.Id;
        }else{
            selAccount = null;
        }
        
        var selectedGroup = component.get("v.selectedGroup");
        var selGroup;
        if(selectedGroup != undefined){
            selGroup = selectedGroup.Id;
        }else{
            selGroup = null;
        }
        var selectedMasterQuote = component.get("v.selectedMasterQuote");
        var selectedMQ;
        if(selectedMasterQuote != undefined){
            selectedMQ = selectedMasterQuote.Id;
        }else{
            selectedMQ = null;
        }
        component.set("v.newQuoteItem.buildertek__Contractor__c", selAccount);
       // component.set("v.newQuoteItem.buildertek__Trade_Type__c", selTradeType);
        component.set("v.newQuoteItem.buildertek__Quote_Line_Group__c", selGroup);
        component.set("v.newQuoteItem.buildertek__Cost_Code__c", costcode);
        component.set("v.newQuoteItem.buildertek__Master_Quote__c", selectedMQ);
       var mastername = component.get("v.newQuoteItem.buildertek__Master_Quote_Item_Name__c");
      // alert('hi'+component.get("v.newQuoteItem.buildertek__Master_Quote_Item_Name__c"));
        var MQLineToInsert = JSON.stringify(component.get("v.newQuoteItem"));
        if(selectedMQ != undefined && selectedMQ != null && mastername != null && mastername != undefined){
            component.set("v.Spinner", true);
            var action = component.get("c.saveMQItem");
            action.setParams({
                MQLines : MQLineToInsert,
                MQId : selectedMQ
            });
            action.setCallback(this, function(response){
                var state = response.getState(); 
                if(state === "SUCCESS"){
                    var url = location.href;
                    var baseURL = url.substring(0, url.indexOf('/', 14));
                    var result = response.getReturnValue();
                    $A.get("e.force:closeQuickAction").fire();
                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then(function(response) {
                        var focusedTabId = response.tabId;
                         workspaceAPI.closeTab({tabId: focusedTabId});
                    })
                    .catch(function(error) {
                        console.log(error);
                    });
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        message: 'Master Quote Line was created ',
                        messageTemplate: "Master Quote Line {0} was created",
                        messageTemplateData: [{
                        url: baseURL+'/lightning/r/buildertek__Master_Quote_Item__c/'+escape(result.Id)+'/view',
                        label: result.Name,
                        }],
                        type : 'success',
                        duration: '10000',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                        
                    window.open ("/"+result.Id,"_Self");     
                }
            });
            $A.enqueueAction(action);    
        }else{
            var pillTarget = component.find("errorId"); 
            $A.util.addClass(pillTarget, 'showErrorMessage');    
            var pillTarget1 = component.find("nameerrorId"); 
            $A.util.addClass(pillTarget1, 'showErrorMessage');
        }
        
   },
   saveAndNew : function(component, event, helper) {
        
        var selectedCostCode = component.get("v.selectedCostCode");
        var costcode;
        if(selectedCostCode != undefined){
            costcode = selectedCostCode.Id;     
        }else{
            costcode = null;
        }
        var selectedAccount = component.get("v.selectedAccount");
        var selAccount;
        if(selectedAccount != undefined){
            selAccount = selectedAccount.Id;
        }else{
            selAccount = null;
        }
        
        var selectedGroup = component.get("v.selectedGroup");
        var selGroup;
        if(selectedGroup != undefined){
            selGroup = selectedGroup.Id;
        }else{
            selGroup = null;
        }
        var selectedMasterQuote = component.get("v.selectedMasterQuote");
        var selectedMQ;
        if(selectedMasterQuote != undefined){
            selectedMQ = selectedMasterQuote.Id;
        }else{
            selectedMQ = null;
        }
        component.set("v.newQuoteItem.buildertek__Contractor__c", selAccount);
        //component.set("v.newQuoteItem.buildertek__Trade_Type__c", selTradeType);
        component.set("v.newQuoteItem.buildertek__Master_Budget_Item_Group__c", selGroup);
        component.set("v.newQuoteItem.buildertek__Cost_Code__c", costcode);
       var mastername = component.get("v.newQuoteItem.buildertek__Master_Quote_Item_Name__c");
        //component.set("v.newQuoteItem.buildertek__Master_Budget__c", selectedMQ);
        var MQLineToInsert = JSON.stringify(component.get("v.newQuoteItem"));
        if(selectedMQ != undefined && selectedMQ != null && mastername != null && mastername != undefined){
            component.set("v.Spinner", true);
            var action = component.get("c.saveMQItem");
            action.setParams({
                MQLines : MQLineToInsert,
                MQId : selectedMQ
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    var url = location.href;
                    var baseURL = url.substring(0, url.indexOf('/', 14));
                    var result = response.getReturnValue();
                    component.set("v.newQuoteItem", null); 
                    component.set("v.Spinner", false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        message: 'Master Quote Line was created',
                        messageTemplate: "Master Quote Line {0} was created",
                        messageTemplateData: [{
                        url: baseURL+'/lightning/r/buildertek__Master_Quote_Item__c/'+escape(result.Id)+'/view',
                        label: result.Name,
                        }],
                        type : 'success',
                        duration: '10000',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    window.location.reload(true);
                }
            });
            $A.enqueueAction(action);    
        }else{
            var pillTarget = component.find("errorId"); 
            $A.util.addClass(pillTarget, 'showErrorMessage');    
            var pillTarget1 = component.find("nameerrorId"); 
            $A.util.addClass(pillTarget1, 'showErrorMessage');
        }
            
   }
})