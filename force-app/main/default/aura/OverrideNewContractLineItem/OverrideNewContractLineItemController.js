({
	doInit : function(component, event, helper) {
	    component.set("v.isOpen", true);
	  //  component.set("v.Spinner", true);
	    var value = helper.getParameterByName(component , event, 'inContextOfRef');
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
           // alert('stringList---'+stringList);
		    parentRecordId = stringList[4];
            if(parentRecordId == 'related'){
                var stringList = relatedList.split("/");
                parentRecordId = stringList[3];
            }
		    component.set("v.parentRecordId",parentRecordId);
		}
        
        component.find('quantityId').set("v.value", 1);
        //alert('parent-------'+ parentRecordId);
        if(parentRecordId !=null && parentRecordId !=undefined ){
	    component.find('COId').set("v.value", parentRecordId);  
        }
		component.find('quantityId').set("v.value", 1);
		helper.fetchpricebooks(component, event, helper);
		//component.set("v.Spinner", false);
	}, 
	
	handleComponentEvent : function(component, event, helper) {
	    var selectedAccountGetFromEvent = event.getParam("recordByEvent");
	    component.set("v.newCoitem.Name",selectedAccountGetFromEvent.Name);
	    component.set("v.newCoitem.buildertek__Product__c",selectedAccountGetFromEvent.Id);
	    component.set("v.productId", selectedAccountGetFromEvent.Id);
		component.set("v.productName", selectedAccountGetFromEvent.Name);
	    helper.getProductDetails(component, event, helper);
        //alert('test');
    },
    ClearhandleComponentEvent: function (component, event, helper) {
        
    },
    handleComponentEvents : function(component, event, helper) {
	    var selectedAccountGetFromEvent = event.getParam("recordByEvent");
	    component.set("v.newCoitem.Name",selectedAccountGetFromEvent.Name);
	    component.set("v.newCoitem.buildertek__Product__c",selectedAccountGetFromEvent.Id);
	    component.set("v.productId", selectedAccountGetFromEvent.Id);
		component.set("v.productName", selectedAccountGetFromEvent.Name);
	    helper.getProductDetails(component, event, helper);
        //alert('test handler');
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
        window.setTimeout(
            $A.getCallback(function() {
                $A.get('e.force:refreshView').fire();
            }), 1000
        );
   },
    
    save : function(component, event, helper) {
        var selectedCostCode = component.get("v.selectedCostCode");
        
        var selectedGroup = component.get("v.selectedGroup");
        var contractlinegroup;
        if(selectedGroup != undefined){
            contractlinegroup = selectedGroup.Id;
        }else{
            contractlinegroup = null;
        }
        
       
        var selectedcontract = component.get("v.selectedCORecord");
        var parentRecordId = component.get("v.parentRecordId");
        var selectedCORecordId;
        if(parentRecordId != undefined){
            selectedCORecordId =  parentRecordId;   
        }else{
            if(selectedcontract != undefined){
                selectedCORecordId = selectedcontract.Id;    
            }
        }
       
      
        component.set("v.newCoitem.buildertek__Contract_Item_Group__c", contractlinegroup);
       
       
        var contractlinestoinsert = JSON.stringify(component.get("v.newCoitem"));
        if(selectedCORecordId != undefined){
            component.set("v.Spinner", true);
            var action = component.get("c.savecontractlineItemrec");
            action.setParams({
                Colines : contractlinestoinsert,
                contractId : selectedCORecordId
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
                         //$A.get('e.force:refreshView').fire();
                    })
                    .catch(function(error) {
                        console.log(error);
                    });
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        message: 'contract Line was created ',
                        messageTemplate: "contract Line {0} was created",
                        messageTemplateData: [{
                        url: baseURL+'/lightning/r/buildertek__Contract_Item__c/'+escape(result.Id)+'/view',
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
        
        var selectedGroup = component.get("v.selectedGroup");
        var contractlinegroup;
        if(selectedGroup != undefined){
            contractlinegroup = selectedGroup.Id;
        }else{
            contractlinegroup = null;
        }
        
        
        var selectedcontract = component.get("v.selectedCORecord");
        var parentRecordId = component.get("v.parentRecordId");
        var selectedCORecordId;
        if(parentRecordId != undefined){
            selectedCORecordId =  parentRecordId;   
        }else{
            if(selectedcontract != undefined){
                selectedCORecordId = selectedcontract.Id;    
            }
        }
      
        component.set("v.newCoitem.buildertek__Contract_Item_Group__c", contractlinegroup);
        component.set("v.newCoitem.buildertek__Contract__c", selectedCORecordId);
        
        var contractlinestoinsert = JSON.stringify(component.get("v.newCoitem"));
        if(selectedCORecordId != undefined){
        var action = component.get("c.savecontractlineItemrec");
        action.setParams({
                Colines : contractlinestoinsert,
                contractId : selectedCORecordId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var url = location.href;
                var baseURL = url.substring(0, url.indexOf('/', 14));
                var result = response.getReturnValue();
                component.set("v.newCoitem", null); 
                component.set("v.Spinner", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'sticky',
                    message: 'contract Line was created',
                    messageTemplate: "contract Line {0} was created",
                    messageTemplateData: [{
                    url: baseURL+'/lightning/r/buildertek__Contract_Item__c/'+escape(result.Id)+'/view',
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
        }
   },
     changefamily : function(component, event, helper) {
        
        var product = component.get('v.selectedLookUpRecord');
                var compEvent = $A.get('e.c:BT_CLearLightningLookupEvent');
                compEvent.setParams({"recordByEvent" : product });  
                compEvent.fire();
       component.set('v.newCoitem.Name', '');
       component.set('v.newCoitem.buildertek__Unit_Price__c', '');
        
         
        
    },
    changeEvent: function(component, event, helper) {
         
                var product = component.get('v.selectedLookUpRecord');
                var compEvent = $A.get('e.c:BT_CLearLightningLookupEvent');
                compEvent.setParams({"recordByEvent" : product });  
                compEvent.fire();
              
        var pribooknames = component.get("v.pricebookName");
          var action = component.get("c.getProductfamilyRecords");
      // set param to method  
        action.setParams({ 
            'ObjectName' : "Product2",
            'parentId' : component.get("v.pricebookName")
          });
      // set a callBack    
        action.setCallback(this, function(response) {
          $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
               // helper.fetchPickListVal(component, event, helper);
                var storeResponse = response.getReturnValue();
              // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                // set searchResult list with return value from server.
                component.set("v.listofproductfamily", storeResponse);
                
                if(component.get("v.listofproductfamily").length >0){
                 component.set("v.productfamily",component.get("v.listofproductfamily")[0].productfamilyvalues);
                }
                 
            }
 
        });
      // enqueue the Action  
        $A.enqueueAction(action);
    },
})