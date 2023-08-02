({
    
    doinit:function(component, event, helper){
    	
    },
    
    initialize:function(component, event, helper){
    	
        var auraId, objectName, fieldSetName, TableId, PagerId, filterConditions,
			Pagination, RecordsToShowPerPage, rowList, multiselect, ColumnChooser, CheckAll, Grouping, Searching, 
			Frozen, actionsToShow, action, rfq;
     	
        	auraId = "relatedList";
        	objectName = component.get("v.relatedObjectAPI");
        	fieldSetName = component.get("v.relatedObjectFieldsSetName");
        	TableId = component.get("v.relatedObjectAPI");
        	PagerId = component.get("v.relatedObjectAPI")+"pagerId";
        	Pagination = false;
        	RecordsToShowPerPage = 1000;
        	rowList = [];
        	multiselect = true;
        	ColumnChooser = false;
        	CheckAll = true;
        	Grouping = false;
        	Searching = true;
        	Frozen = true;
        	filterConditions = ' AND buildertek__RFQ_Package__c = \''+component.get("v.recordId")+'\'';
        	
        	rfq = component.get("v.rfq");
			// validate RFQ Status and add info message / hide actions / check boxes
	    	if(rfq.buildertek__Status__c != 'Awarded' && rfq.buildertek__Status__c != 'Accepted' && rfq.buildertek__Status__c != 'Request Sent'){
	        	actionsToShow = "['Edit','Delete']";
	        	
	        	component.find("infoMessage").set("v.type", "info");
	        	component.find("infoMessage").set("v.Message", $A.get("$Label.c.RFQ_Item_info_message_with_New_Status"));
	        
	        } else if(rfq.buildertek__Status__c === 'Request Sent') {
	        	component.find("infoMessage").set("v.type", "success");
	    		component.find("infoMessage").set("v.Message", $A.get("$Label.c.RFQ_Item_info_message_with_Request_Sent_Status"));
	    	
	    		multiselect = false;
	    		
	        }else if(rfq.buildertek__Status__c === 'Awarded'){
	        	component.find("infoMessage").set("v.type", "success");
	    		component.find("infoMessage").set("v.Message", $A.get("$Label.c.RFQ_Item_info_message_with_Awarded_Status"));
	    	
	        	multiselect = false;
	        	
	        } else if(rfq.buildertek__Status__c === 'Accepted'){
	        	component.find("infoMessage").set("v.type", "success");
	    		component.find("infoMessage").set("v.Message", $A.get("$Label.c.RFQ_Item_info_message_with_Accepted_Status"));
	    	
	        	multiselect = false;
	        }
	        
	    	helper.createRelatedList(component, event, helper, auraId, objectName, fieldSetName, filterConditions, TableId, PagerId,
		     							Pagination, RecordsToShowPerPage, rowList, multiselect, ColumnChooser, CheckAll, Grouping, Searching, 
		     							Frozen, actionsToShow);
		     							
    },
    
    newRFQItem:function(component, event, helper){
    	var evt = $A.get("e.force:createRecord");
        evt.setParams({
            'entityApiName':'buildertek__RFQ_Item__c',
            'defaultFieldValues': {
                'buildertek__RFQ_Package__c':component.get("v.recordId")
            }
            //'recordTypeId':YOUR_RECORDTYPE_ID_HERE
        });
        evt.fire();
    },
    
    selectFromBudget: function(component, event, helper){
        var title, cardTitle, filterConditions, budgetId, toastEvent;
    	budgetId = component.get("v.rfq").buildertek__Budget__c;
    	
    	if(!budgetId && budgetId != '') {
			toastEvent = $A.get("e.force:showToast");
	        toastEvent.setParams({
	            "type":"error",
	            "title": "Budget Missing!",
	            "message": "You have not selected the budget for this RFQ, Please go in details and select budget for this RFQ."
	        });
	        toastEvent.fire();
        } else {
	        title = "Select Items From Budget: "+component.get("v.rfq").buildertek__Budget__r.Name,
			cardTitle= component.get("v.rfq").buildertek__Budget__r.Name+" Items";
			filterConditions = 'AND buildertek__Budget__c =\''+component.get("v.rfq").buildertek__Budget__c+'\'';
			
	    	helper.createItemPicker(component, event, helper, component.get("v.recordId"), 'buildertek__Budget_Item__c', 'buildertek__BT_Item_Picker_Fields',
    							filterConditions, 'buildertek__Budget_Item__cTable', 'buildertek__Budget_Item__cPagerId',title, cardTitle, 'RFQ_BUDGET_ITEM_PICKER');
		}
	},
	
	selectFromQuote: function(component, event, helper){
		
		var title, cardTitle, filterConditions, quoteId, toastEvent;
		
		quoteId = component.get("v.rfq").buildertek__Quote__c;
		
		if(!quoteId && quoteId != '') {
			toastEvent = $A.get("e.force:showToast");
	        toastEvent.setParams({
	            "type":"error",
	            "title": "Quote Missing!",
	            "message": "You have not selected the quote for this RFQ, Please go in details and select quote for this RFQ."
	        });
	        toastEvent.fire();
        } else {
    	
	        title = "Select Items From Quote: "+component.get("v.rfq").buildertek__Quote__r.Name;
			cardTitle= component.get("v.rfq").buildertek__Quote__r.Name+" Items";
			filterConditions = 'AND buildertek__Quote__c =\''+quoteId+'\'';
			
	    	helper.createItemPicker(component, event, helper, component.get("v.recordId"), 'buildertek__Quote_Item__c', 'buildertek__BT_Item_Picker_Fields',
    							filterConditions, 'buildertek__Quote_Item__cTable', 'buildertek__Quote_Item__cPagerId',title, cardTitle, 'RFQ_QUOTE_ITEM_PICKER');
		}
	},
	
	navigateToImport: function(component, event, helper) {
		
        $A.createComponent(
            "dataImporter:diInitialStep",
            {
            	"config":{objectApiName:"buildertek__RFQ_Item__c"},
            	"objectSelection":"buildertek__RFQ_Item__c"
            },
            function(importWizard){
               if (component.isValid()) {
                    $A.createComponent(
			            "c:BT_modalDialog",
			            {
			                "title": "Import RFQ Items",
			                "body": importWizard
			            },
			            function(msgBox){
			                if (component.isValid()) {
			                    var targetCmp = component.find('ModalDialogPlaceholder');
			                    var body = targetCmp.get("v.body");
			                    body.push(msgBox);
			                    targetCmp.set("v.body", body); 
			                }
			            }
			        );
                }
            }
        );
        
        
	},
    
    deleteSelectedItems: function(component, event, helper){
    	 var result = {}, grid = component.find("relatedList");
    	 grid.getSelectedRecords(result);
    	 if(!result || result.ids == -1) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type":"error",
                "title": "",
                "message": "Please Select Records."
            });
            toastEvent.fire();
        } else {
           grid.deleteRecord(JSON.stringify(result.ids));
        }
	     
    },
    
	refreshRelatedList: function(component, event, helper){
    	 var grid = component.find("relatedList");
	     grid.refreshData();
	     return false;
    },
    
})