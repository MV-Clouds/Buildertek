({
     //showSpinner: this will call on aura waiting hendler 
    showSpinner: function (component, event, helper) {
        var spinner = component.find("BTSpinner");
        $A.util.addClass(spinner, 'slds-show');
        $A.util.removeClass(spinner, 'slds-hide');
    },

    //hideSpinner: this will call on aura doneWaiting hendler
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("BTSpinner");
        $A.util.addClass(spinner, 'slds-hide');
        $A.util.removeClass(spinner, 'slds-show');
    },
    
    replaceAll: function (str, term, replacement) {
	  return str.replace(new RegExp(this.escapeRegExp(term), 'g'), replacement);
	},
	escapeRegExp: function escapeRegExp(string){
	    return string.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
	},
     
    createItemPicker: function (component, event, helper, parentId, objectName, fieldSetName, 
    		 					filterConditions, TableId, PagerId, title, cardTitle, pickerName){
    		 					
		 	$A.createComponents([["c:BT_ItemPicker",{
							        "title": title,
					                "itemPickerName": pickerName,
					                "parentId": parentId,
					                "parentComponentAction": component.get("v.refreshRelatedList")
							    }],
							    ["c:BT_GridComponent",{
							    	"aura:id":"LHS_"+parentId,
							        "objectName": objectName,
					                "fieldSetName": fieldSetName,
					                "filterConditions": filterConditions,
					                "TableId": TableId + "left",
					                "PagerId": PagerId + "left",
					                "Pagination": false,
					                "RecordsToShowPerPage": 100,
					                "rowList": new Object(),
					                "multiselect": true,
					                "ColumnChooser": false,
					                "CheckAll": true,
					                "Grouping": false,
					                "parentId": parentId,
					                "gridType": pickerName+"_LHS",
					                "showSpinner":false,
							    }],
							    ["c:BT_GridComponent",{
							    	"aura:id":"RHS_"+parentId,
							        "objectName": objectName,
					                "fieldSetName": fieldSetName,
					                "filterConditions": filterConditions,
					                "TableId": TableId + "rigth",
					                "PagerId": PagerId + "rigth",
					                "Pagination": false,
					                "RecordsToShowPerPage":100,
					                "rowList": new Object(),
					                "multiselect": true,
					                "ColumnChooser": false,
					                "CheckAll": true,
					                "Grouping": false,
					                "parentId": parentId,
					                "gridType": pickerName+"_RHS",
					                "showSpinner":false,
							    }]], function(components, status, errorMessage){
							        if (status === "SUCCESS") {
							            if (component.isValid()) {
						                    var targetCmp = component.find('ModalDialogPlaceholder');
						                    var body = targetCmp.get("v.body");
						                    
						                    components[0].set("v.leftSideComponent",components[1]);
						                    components[0].set("v.rightSideComponent",components[2]);
						                    
						                    body.push(components[0]);
						                    
						                    component.find('overlayLib').showCustomModal({
						                        header: 'Select Items From Budge',
						                        body: body,
						                        footer:'',
						                        showCloseButton: true,
						                        cssClass: 'uiModal--large'
						                    });
						                    //targetCmp.set("v.body", body); 
						                }
							        }
							        else if (status === "INCOMPLETE") {
							            console.log("No response from server or client is offline.")
							            // Show offline error
							        }
							        else if (status === "ERROR") {
							            console.log("Error: " + errorMessage);
							            // Show error message
							        }
							    });
     },
     
    createRelatedList:function(component, event, helper, auraId, objectName, fieldSetName, filterConditions, TableId, PagerId,
     							Pagination, RecordsToShowPerPage, rowList, multiselect, ColumnChooser, CheckAll, Grouping, Searching, 
     							Frozen, actionsToShow){
    	 
    	 $A.createComponent("c:BT_GridComponent",
				            {
				            	"aura:id":"relatedList",
				                "objectName": component.get("v.relatedObjectAPI"),
				                "fieldSetName": component.get("v.relatedObjectFieldsSetName"),
				                "filterConditions" : filterConditions,
				                "TableId":component.get("v.relatedObjectAPI"),
				                "PagerId":component.get("v.relatedObjectAPI")+"pagerId",
				                "Pagination": false,
				                "RecordsToShowPerPage":1000,
				                "rowList":new Object(),
				                "multiselect": true,
				                "ColumnChooser": false,
				                "CheckAll":true,
				                "Grouping":false,
				                "Searching": false,
				                "Frozen":true,
				                "actions": actionsToShow
				            },
				            function(grid){
				               if (component.isValid()) {
				                    var targetCmp = component.find('relatedListholder');
				                    var body = targetCmp.get("v.body");
				                    body.push(grid);
				                    targetCmp.set("v.body", body); 
				                }
				            }
				        );
    	 
     }
})