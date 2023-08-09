({
    doInit : function(component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "HIDE"
        }).fire();
        var recordId = component.get("v.mainObjectId");

      /*  var action = component.get("c.getRFQ"); 
        action.setParams({
    		"recId": recordId
    	});
        action.setCallback(this, function(response){
           
            if(response.getState() === "SUCCESS"){
                var result  = response.getReturnValue();
                alert(result);
                component.find("description").set("v.value", result.buildertek__Description__c);
            }     
        });
        $A.enqueueAction(action);  */
        
        
        
        //alert(recordId);
        //var rfqname = component.get("v.rfqLineToInsert.buildertek__RFQ_Package__c");
        component.find("rfqId").set("v.value", recordId);
        helper.getAllTradeTypes(component, event, helper);
        
        var value = helper.getParameterByName(component, event, 'inContextOfRef');
        var context = '';
        var parentRecordId = '';
        component.set("v.parentRecordId", parentRecordId);
        if (value != null) {
            context = JSON.parse(window.atob(value));
            parentRecordId = context.attributes.recordId;
            // alert('parentId in doinit'+parentRecordId );
            component.set("v.parentRecordId", parentRecordId);
        } else {
            var relatedList = window.location.pathname;
            var stringList = relatedList.split("/");
            parentRecordId = stringList[4];
            if (parentRecordId == 'related') {
                var stringList = relatedList.split("/");
                parentRecordId = stringList[3];
            }
            
            component.set("v.parentRecordId", parentRecordId);
        }
        helper.fetchpricebooks(component, event, helper);
        
        var RFQ = component.get("v.newRFQLine.Name");
        component.set("v.newRFQLine.buildertek__Description__c",RFQ);
        
        
        
    },
    
    handleComponentEvent : function(component, event, helper) {
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        component.set("v.newRFQLine.Name",selectedAccountGetFromEvent.Name);
        component.set("v.newRFQLine.buildertek__Product__c",selectedAccountGetFromEvent.Id);
        component.set("v.newRFQLine.buildertek__Description__c",selectedAccountGetFromEvent.Name);
    },
    
    handleComponentEvents : function(component, event, helper) {
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        // alert(selectedAccountGetFromEvent);
        component.set("v.newRFQLine.Name",selectedAccountGetFromEvent.Name);
        component.set("v.newRFQLine.buildertek__Product__c",selectedAccountGetFromEvent.Id);
        component.set("v.newRFQLine.buildertek__Description__c",selectedAccountGetFromEvent.Name);
        
    },
    handleComponentEvt : function(component, event, helper) {
        var valueFromChild = event.getParam("seletcedOption");
        var value = valueFromChild.split("_")[0];
        var selectBox = valueFromChild.split("_")[2];
        var selecetedName = valueFromChild.split("_")[1];
        if(selectBox == "tradeTypeULId" || selectBox == "tradeTypeId"){
            if(value == '' && selecetedName== ''){
                document.getElementById("tradeTypeId").value = '';
                component.set("v.selectedTradeTypeId",'All');
                component.set("v.selectedTradeTypeIdName",'All');
            }else{
                document.getElementById("tradeTypeId").value = selecetedName;
                component.set("v.selectedTradeTypeId",value);
                component.set("v.selectedTradeTypeIdName",selecetedName);
            }
        }
    },
    
    
    changedescription : function(component, event, helper) {
        //alert("haiiiiiiii");
        var RFQ = component.get("v.newRFQLine.Name");
        component.set("v.newRFQLine.buildertek__Description__c",RFQ);
        
      /*  var id = component.get("v.newRFQLine");
        alert(id);
        var action = component.get("c.RFQITEM"); 
          action.setParams({
              "recordId" : component.get("v.newRFQLine"),
        });
        action.setCallback(this, function(response){
            alert("helooo");
            if(response.getState() === "SUCCESS"){
                alert("getState")
       
                alert(JSON.stringify(response.getReturnValue()));
            	component.set("v.newRFQLine.buildertek__Description__c", response.getReturnValue());    
                
            }     
        });
        $A.enqueueAction(action); */
        

        
        
        
    },
    
    doSave : function(component, event, helper) {
        //  alert('%%%'+component.get("v.selectedTradeTypeId"));
        component.set("v.Spinner", true);
        var rfqLineToInsert = JSON.stringify(component.get("v.newRFQLine"));
        //alert(rfqLineToInsert);
        var Name = component.get("v.newRFQLine.Name");
        var rfqId = component.get("v.mainObjectId");
        var rfqname = component.find("rfqId").get("v.value");
        //alert("eee : "+rfqname);
        var selectedCostCode = component.get("v.selectedCostCode");
        var selectedTradeType = component.get("v.selectedTradeTypeId");
        var costcode;
        if(selectedCostCode != undefined){
            costcode = selectedCostCode.Id;     
        }else{
            costcode = null;
        }
        if(selectedTradeType != undefined && selectedTradeType != 'All'){
            selectedTradeType =  selectedTradeType;
        }else{
            selectedTradeType = null;
        }
        // for(var i=0;i < Name.length;i++){
        // alert('hii'+ Name.length);
        // if(component.get("v.isName") == true){
        // alert(rfqname);
        if( rfqname == ''){
            //alert("1");
            component.set("v.Spinner", false);
            component.set("v.isName", true);
               /* var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message: 'Please assign  .',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'dismissible'
                });
                toastEvent.fire();
               component.set("v.Spinner", false);*/
        }else{ 
            if( Name == undefined || Name == null || Name == "" || Name == " "){
                component.set("v.Spinner", false);
                component.set("v.isName", true);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message: 'Please assign RFQ items.',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'dismissible'
                });
                toastEvent.fire();
            }
            else{
                if(Name.length > 80){
                    //alert("2");
                    // component.set("v.Spinner", false);
                    component.set("v.isName", true);
                    // alert("5");
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message: 'Please assign RFQ items size is lessthan 80.',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                }
                else{
                    
                    component.set("v.isName", false); 
                }
            }
            //alert("4");
            //if( rfqLineToInsert.buildertek__RFQ_Package__c != undefined){ 
        }
        if(component.get("v.isName") == false){
            //if( rfqname != ''){
            var action = component.get("c.saveRFQItem");
            action.setParams({
                rfqLines : rfqLineToInsert,
                costCode : costcode,
                tradetype : selectedTradeType,
                rfqId : rfqId
            });
            action.setCallback(this, function(response){
                
                var state = response.getState();
                //alert(JSON.stringify(state));
                if(state === "SUCCESS"){
                    component.set("v.Spinner", false);

                    var res = response.getReturnValue();
                    console.log('res',res);
                    if(res.length > 20){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            message: res,
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'dismissible'
                        });
                        // component.get("v.onSuccess")(); 
                        toastEvent.fire();
                    }
                    else{
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            message: 'RFQ Item created successfully.',
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'success',
                            mode: 'dismissible'
                        });
                        component.get("v.onSuccess")(); 
                        toastEvent.fire();
                    }
                    /* component.set("v.rfqItemId", response.getReturnValue());
                    
                    
                    var urlEvent = $A.get("e.force:navigateToURL");
                    var recordId = component.get("v.rfqItemId");
                    // alert(recordId);
                    urlEvent.setParams({
                        "url": '/lightning/r/buildertek__RFQ_Items__c/'+recordId+'/view'
                    });
                    urlEvent.fire();*/
                } 
                
            });
            $A.enqueueAction(action);
            // }
        }
        
    },
    
    doSaveAndNew : function(component, event, helper) {
        component.set("v.Spinner", true);
        var Name = component.get("v.newRFQLine.Name");
        var rfqLineToInsert = JSON.stringify(component.get("v.newRFQLine"));
        var rfqId = component.get("v.mainObjectId");
        var rfqname = component.find("rfqId").get("v.value");
        var selectedCostCode = component.get("v.selectedCostCode");
        var selectedTradeType = component.get("v.selectedTradeTypeId");
        var costcode;
        if(selectedCostCode != undefined){
            costcode = selectedCostCode.Id;     
        }else{
            costcode = null;
        }
        if(selectedTradeType != undefined && selectedTradeType != 'All'){
            selectedTradeType =  selectedTradeType;
        }else{
            selectedTradeType = null;
        }
        if( rfqname == ''){
            //alert("1");
            // component.set("v.Spinner", false);
            component.set("v.isName", true);
        }else{ 
            if( Name == undefined || Name == null || Name == "" || Name == " "){
                // component.set("v.Spinner", false);
                component.set("v.isName", true);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message: 'Please assign RFQ items.',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'dismissible'
                });
                toastEvent.fire();
            }
            else{
                if(Name.length > 80){
                    //alert("2");
                    // component.set("v.Spinner", false);
                    component.set("v.isName", true);
                    // alert("5");
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message: 'Please assign RFQ items size is lessthan 80.',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                }
                else{
                    component.set("v.isName", false); 
                }
            }
            //alert("4");
        }
        if(component.get("v.isName") == false){
            var action = component.get("c.saveRFQItem");
            action.setParams({
                rfqLines : rfqLineToInsert,
                costCode : costcode,
                tradetype : selectedTradeType,
                rfqId : rfqId
            });
            action.setCallback(this, function(response){
                
                var state = response.getState();
                if(state === "SUCCESS"){
                    component.set("v.Spinner", false);
                    var res = response.getReturnValue();
                    console.log('res',res);
                    if(res.length > 20){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            message: res,
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'dismissible'
                        });
                        toastEvent.fire();
                        // component.set("v.Spinner", false);
                        // component.get("v.onSuccess")();
                    }
                    else{
                        var product = component.get('v.selectedLookUpRecord');
                        var compEvent = $A.get('e.c:BT_CLearLightningLookupEvent');
                        compEvent.setParams({"recordByEvent" : product });  
                        compEvent.fire();
                        component.set("v.newRFQLine.buildertek__Quantity__c", '1');
                        component.set("v.newRFQLine.Name", '');
                        component.set("v.newRFQLine.buildertek__Master_Item__c", false);
                        component.set("v.newRFQLine.buildertek__Description__c", '');
                        component.set("v.newRFQLine.buildertek__Trade_Type__c", null);
                        component.set("v.newRFQLine.buildertek__Cost_Code__c", null);
                        component.set("v.newRFQLine.buildertek__Unit_Price__c", null);
                        // component.set("v.Spinner", false);
                        //$A.get('e.force:refreshView').fire();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            mode: 'sticky',
                            message: 'RFQ Line created successfully',
                            type : 'success',
                            duration: '10000',
                            mode: 'dismissible'
                        });
                        toastEvent.fire();
                    }    
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    doCancel : function(component, event, helper) {
        component.get("v.onCancel")();    
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "HIDE"
        }).fire();
    },
    
    changeEvent: function (component, event, helper) {
        
        var product = component.get('v.selectedLookUpRecord');
        var compEvent = $A.get('e.c:BT_CLearLightningLookupEvent');
        compEvent.setParams({
            "recordByEvent": product
        });
        compEvent.fire();
        
        var pribooknames = component.get("v.pricebookName");
        var action = component.get("c.getProductfamilyRecords");
        // set param to method  
        action.setParams({
            'ObjectName': "Product2",
            'parentId': component.get("v.pricebookName")
        });
        // set a callBack    
        action.setCallback(this, function (response) {
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
                
                if (component.get("v.listofproductfamily").length > 0) {
                    component.set("v.productfamily", component.get("v.listofproductfamily")[0].productfamilyvalues);
                }
                
            }
            
        });
        // enqueue the Action  
        $A.enqueueAction(action);
    },
    changefamily: function (component, event, helper) {
        
        var product = component.get('v.selectedLookUpRecord');
        var compEvent = $A.get('e.c:BT_CLearLightningLookupEvent');
        compEvent.setParams({
            "recordByEvent": product
        });
        compEvent.fire();
        component.set('v.newPOItem.Name', '');
        component.set('v.newPOItem.buildertek__Unit_Price__c', '');
        
    },
    
    
    
})