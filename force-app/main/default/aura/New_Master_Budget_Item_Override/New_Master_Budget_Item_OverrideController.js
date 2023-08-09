({
	doInit : function(component, event, helper) {
	    component.set("v.isOpen", true);
	    /*var value = helper.getParameterByName(component , event, 'inContextOfRef');
    	var context = '';
    	var parentRecordId = '';
    	component.set("v.parentRecordId",parentRecordId);
    	if(value != null){
    		context = JSON.parse(window.atob(value));
    		parentRecordId = context.attributes.recordId;
            component.set("v.parentRecordId",parentRecordId);
		}else{
		    var relatedList = window.location.pathname;
		    var stringList = relatedList.split("/"); 
		    parentRecordId = stringList[3]
		    component.set("v.parentRecordId",parentRecordId);
		} */
		//component.find('MBId').set("v.value", parentRecordId);
	}, 
	
	handleComponentEvent : function(component, event, helper) {
	    var selectedAccountGetFromEvent = event.getParam("recordByEvent");
	    component.set("v.newBudgetItem.buildertek__Budget_Item_Name__c",selectedAccountGetFromEvent.Name);
	    component.set("v.newBudgetItem.buildertek__Product__c",selectedAccountGetFromEvent.Id);
	    component.set("v.productId", selectedAccountGetFromEvent.Id);
		component.set("v.productName", selectedAccountGetFromEvent.Name);
	    helper.getProductDetails(component, event, helper);
    },
    
    handleComponentEvents : function(component, event, helper) {
	    var selectedAccountGetFromEvent = event.getParam("recordByEvent");
	    component.set("v.newBudgetItem.buildertek__Budget_Item_Name__c",selectedAccountGetFromEvent.Name);
	    component.set("v.newBudgetItem.buildertek__Product__c",selectedAccountGetFromEvent.Id);
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
            window.open(baseURL+'/lightning/o/buildertek__Master_Budget_Line__c/list?filterName=Recent', '_self');
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
        var selectedTradeType = component.get("v.selectedTradeType");
        var selTradeType;
        if(selectedTradeType != undefined){
            selTradeType = selectedTradeType.Id;    
        }else{
            selTradeType = null;
        }
        var selectedGroup = component.get("v.selectedGroup");
        var selGroup;
        if(selectedGroup != undefined){
            selGroup = selectedGroup.Id;
        }else{
            selGroup = null;
        }
        var selectedMasterBudget = component.get("v.selectedMasterBudget");
        var selectedMB;
        if(selectedMasterBudget != undefined){
            selectedMB = selectedMasterBudget.Id;
        }else{
            selectedMB = null;
        }
        component.set("v.newBudgetItem.buildertek__Contractor__c", selAccount);
        component.set("v.newBudgetItem.buildertek__Trade_Type__c", selTradeType);
        component.set("v.newBudgetItem.buildertek__Group__c", selGroup);
        component.set("v.newBudgetItem.buildertek__Cost_Code__c", costcode);
        //component.set("v.newBudgetItem.buildertek__Master_Budget__c", selectedMB);
        var MBLineToInsert = JSON.stringify(component.get("v.newBudgetItem"));
        if(selectedMB != undefined){
            component.set("v.Spinner", true);
            var action = component.get("c.saveMBItem");
            action.setParams({
                MBLines : MBLineToInsert,
                MBId : selectedMB
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
                        message: 'Master Budget Line was created ',
                        messageTemplate: "Master Budget Line {0} was created",
                        messageTemplateData: [{
                        url: baseURL+'/lightning/r/buildertek__Master_Budget_Line__c/'+escape(result.Id)+'/view',
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
        }
        
   },
   saveAndNew : function(component, event, helper) {
        component.set("v.Spinner", true);
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
        var selectedTradeType = component.get("v.selectedTradeType");
        var selTradeType;
        if(selectedTradeType != undefined){
            selTradeType = selectedTradeType.Id;    
        }else{
            selTradeType = null;
        }
        var selectedGroup = component.get("v.selectedGroup");
        var selGroup;
        if(selectedGroup != undefined){
            selGroup = selectedGroup.Id;
        }else{
            selGroup = null;
        }
        var selectedMasterBudget = component.get("v.selectedMasterBudget");
        var selectedMB;
        if(selectedMasterBudget != undefined){
            selectedMB = selectedMasterBudget.Id;
        }else{
            selectedMB = null;
        }
        component.set("v.newBudgetItem.buildertek__Contractor__c", selAccount);
        component.set("v.newBudgetItem.buildertek__Trade_Type__c", selTradeType);
        component.set("v.newBudgetItem.buildertek__Master_Budget_Item_Group__c", selGroup);
        component.set("v.newBudgetItem.buildertek__Cost_Code__c", costcode);
        //component.set("v.newBudgetItem.buildertek__Master_Budget__c", selectedMB);
        var MBLineToInsert = JSON.stringify(component.get("v.newBudgetItem"));
        if(selectedMB != undefined){
            var action = component.get("c.saveMBItem");
            action.setParams({
                MBLines : MBLineToInsert,
                MBId : selectedMB
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    var url = location.href;
                    var baseURL = url.substring(0, url.indexOf('/', 14));
                    var result = response.getReturnValue();
                    component.set("v.newBudgetItem", null); 
                    component.set("v.Spinner", false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        message: 'Master Budget Line was created',
                        messageTemplate: "Master Budget Line {0} was created",
                        messageTemplateData: [{
                        url: baseURL+'/lightning/r/buildertek__Master_Budget_Line__c/'+escape(result.Id)+'/view',
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
        }
            
   }
})