({
	initialize : function(component, event, helper) {
		//$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
       /* var recordId = component.get("v.recordId");
             $('#'+recordId+'groups').nestable({ maxDepth:1,
                                           handleClass:'av-section-handle', 
                                           listClass:'av-list', 
                                           threshold:15,
                                           group:1}).on('change', function(e) {
            var list   = e.length ? e : $(e.target);
            helper.setSortIds(component, event, helper, list.nestable('serialize'));
            
        });*/
        
		//helper.createQuoteItemGrid(component, event, helper);
	}, 
	
	doInit: function(component, event, helper) {
	    	     $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();

		var groupFilter = "buildertek__Quote__c ='"+component.get("v.recordId")+"'";
        component.set("v.groupFilter",groupFilter);
        component.set("v.selectedRows", []);
        component.set("v.selectedCol", []);
	},
	
	handleSaveSuccess:function(component, event, helper){
		if(event){
			if(event.getParams().message && event.getParams().message.indexOf('was saved') != -1){
				$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
				var grid = component.find('quoteItemList');
				grid.refreshData();
				$A.get("e.force:refreshView").fire();
			}
		} 
	},
	
	handlelocationchange:function(component, event, helper){
		console.log('----destroy---');
		component.destroy();
	},
	
	newLineItem: function(component, event, helper){
		var evt = $A.get("e.force:createRecord");
	        evt.setParams({
	            'entityApiName':'buildertek__Quote_Item__c',
	            'defaultFieldValues': {
	                'buildertek__Quote__c':component.get("v.recordId"),
	                'Name':'Quote Item'
	            },
	            'panelOnDestroyCallback':function(){
						                	 $A.enqueueAction(component.get("v.refreshGridAction"));
						                },
	            'navigationLocation': 'RELATED_LIST'
	            //'recordTypeId':YOUR_RECORDTYPE_ID_HERE
	        });
	        evt.fire();
		//helper.createForceRecordEditComp(component, event, helper, "", "NEW", "New Quote Item",new Object());
	},
	
	eventAction: function(component, event, helper) {
		var action, grpID = event.getParam("groupId");
		action = event.getParam("action");
		
		if(action == 'NEW_ITEM'){
			var evt = $A.get("e.force:createRecord");
	        evt.setParams({
	            'entityApiName':'buildertek__Quote_Item__c',
	            'defaultFieldValues': {
	                'buildertek__Quote__c':component.get("v.recordId"),
	                'buildertek__Grouping__c':grpID,
	                'Name':'Quote Item'
	            },
	            'panelOnDestroyCallback':function(e){
	            							 console.log(e);
						                	 $A.enqueueAction(component.get("v.refreshGridAction"));
						                },
	            'navigationLocation': 'RELATED_LIST'
	            //'recordTypeId':YOUR_RECORDTYPE_ID_HERE
	        });
	        evt.fire();
			//helper.createForceRecordEditComp(component, event, helper, "", "NEW", "New Quote Item", obj);
		} else if(action == "ADD_PRODUCTS") {
			helper.createProductItemPicker(component, event, helper, grpID);
		
		} else if (action == "EDIT_GROUP") {
			
			//helper.createForceRecordEditComp(component, event, helper, grpID, "EDIT", "Edit Group", new Object());
			var editRecordEvent = $A.get("e.force:editRecord");
				editRecordEvent.setParams({
					 "recordId": grpID
				});
				editRecordEvent.fire();
		}
	},
	
	saveQuoteItems: function(component, event, helper) {
	    alert('hi');
		var grid = component.find('quoteItemList');
		grid.saveGrid();
	},
	
	deleteSelectedItem: function(component, event, helper) {
		/*var result = {}, grid = component.find('quoteItemList');
    	 var result =  component.get("v.selectedCol"); 
    	 //grid.getSelectedRecords(result);
    	 if(!result || result.length < 1) { 
             component.find('notifLib').showNotice({
                    "variant": "error",
                    "header": "Please Select Quote Line!",
                    "message": "Please select the Quote Line you would like to Delete.",
                    closeCallback: function() {
                    }
                    });
        } else {
           $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
            var setRows = [];
            for (var i = 0; i < result.length; i++){
                setRows.push(result[i].Id);
            }
           component.set("v.deleteRecords", setRows)
           helper.deleteRecord(component,event,helper);
        }*/
        
        var selCol = component.get("v.selectedCol");
        var finalString = JSON.stringify(selCol).replace(/\s/g, "");
        
        finalString = finalString.replace('[[', '[');
        finalString = finalString.replace(']]', ']');
        for(var i=0; i<200; i++){
            finalString = finalString.replace('}],[{', '},{');    
        }
        if(finalString.includes('[],')){
            finalString = finalString.replace('[],', '');        
        }
        if(finalString.includes(',[]')){
            finalString = finalString.replace(',[]', '');        
        }
        
        
        if(finalString.includes('\'')){
            finalString = finalString.replace('\'', '');    
        }
        var quoteItems = JSON.parse(finalString);
        var NewQUotes = [];
        for(var i=0, j= quoteItems.length-1;i <= j;j--){
            NewQUotes.push(quoteItems[j]);
        }
        var selectedRows = component.get("v.selectedRows");
        var i,  n, rowData;
        var newRFQItems = [];  
                        
		if(NewQUotes.length > 0){
		    var GroupList = [];
            var QuoteIds = [];
            for (i = 0, n = NewQUotes.length; i < n; i++) {
                rowData = NewQUotes[i].GroupId;
                if(!GroupList.includes(NewQUotes[i].GroupId)){
                    GroupList.push(NewQUotes[i].GroupId);
                    for(var j = 0;j< NewQUotes[i].lineItems.length;j++){
                        QuoteIds.push(NewQUotes[i].lineItems[j].Id);
                    }
                }
            }
            if(QuoteIds.length > 0){
				$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
				var setRows = [];
				// for (var i = 0; i < result.length; i++){
				// 	setRows.push(result[i].Id);
				// }
			   component.set("v.deleteRecords", QuoteIds); 
			   helper.deleteRecord(component,event,helper);
			}
			else{
				component.find('notifLib').showNotice({
                "variant": "error",
                "header": "Please Select Quote Line!",
                "message": "Please select the Quote Line you would like to Delete.",
                closeCallback: function() {
                }
				});
			}
			
		}
		else{
			component.find('notifLib').showNotice({
                "variant": "error",
                "header": "Please Select Quote Line!",
                "message": "Please select the Quote Line you would like to Delete.",
                closeCallback: function() {
                }
			});
		}
	},
	
	getsetparams:function(component, event, helper) {
	    var showresultvalue= event.getParam("selectedRows");
        component.set("v.selectedRows",showresultvalue);
	},
	
	addProduct:function(component, event, helper) {
		helper.createProductItemPicker(component, event, helper);
	},
	
	addRFQ:function(component, event, helper) {
		helper.createRFQPicker(component, event, helper);
	},
	
	refreshQuoteItemList:function(component, event, helper) {
		$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
		var grid = component.find('quoteItemList');
		grid.refreshData();
	},
	
	hideAddProduct:function(component, event, helper) {
		
		JQ$("#productPicketPopUp").hide();
		component.find('productpicker').set("v.body",[]);
	},
	
	onRender: function(component, event, helper) {
		
	},
	handleDestroy: function (component, event, helper) {
    	
    },
    
    
    newGroup: function(component, event, helper){
		$A.createComponents(
            [
                ["aura:html", {
                    "tag": "h2",
                    "body": "New Quote Group",
                    "HTMLAttributes": { 
                        "class": "slds-text-heading_medium slds-hyphenate" 
                    }
                }],
                ["c:BT_NewQuoteGroup", {
                    "quoteId" : component.get("v.recordId"),
                    "onSuccess" : function(){
                        var grid = component.find('quoteItemList');
                        grid.refreshData();
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
	
	handleValueChange : function (component, event, helper) {
        var previousValue = event.getParam("oldValue");
        var currentValue = event.getParam("value");
        var selectedValue = [];
        selectedValue.push(previousValue, currentValue);
        //alert('Selected Value --------> '+JSON.stringify(selectedValue));
        var selectedCol = component.get("v.selectedCol");
        //alert('selectedCol --------> '+selectedCol);
        if(selectedCol != null){
            selectedCol.push(currentValue);   
            component.set("v.selectedCol", selectedCol);
        }else{
            component.set("v.selectedCol", selectedValue);    
        }
        
        //component.set("v.selectedRows", selectedValue);
    }, 
    
})