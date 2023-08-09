({
	getDetails : function(component, event, helper) {
		var action;
		action = component.get("c.getQuoteGrouping");
        action.setParams({
            quoteId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === "SUCCESS") {
            	//component.set("v.QuoteLineGroups",response.getReturnValue());
			}
        });
        
        $A.enqueueAction(action);
	},
	
	createQuoteItemGrid : function(component, event, helper) {
		var actions = ['Edit','Delete'];
		$A.createComponent("c:BT_GridComponent",
							            {
							            	"aura:id":"quoteItemList",
							                "objectName": "buildertek__Quote_Item__c",
							                "fieldSetName": "buildertek__BT_Related_List_View_Fields",
							                "filterConditions" : "AND buildertek__Quote__c = '"+component.get("v.recordId")+"' ORDER BY buildertek__GROUPING__R.NAME ASC",
							                "TableId":"quoteItemList"+component.get("v.recordId")+"tabel",
							                "PagerId":"quoteItemListPager"+component.get("v.recordId")+"pager",
							                "Pagination": false,
							                "multiselect": true,
							                "ColumnChooser": false,
							                "CheckAll":true,
							                "Grouping":false,
							                "GroupingColumns":['buildertek__Grouping__r.Name'],
							                "showGroupingsummery":true,
							                "ShowGroupingColumns":[false],
							                "groupText":['{0}'],
							                "singleSelectGrouping":false,
							                "GroupingCollapse": false,
							                "AllowExpandAllCollapseAll":true,
							                "Height":"auto",
							                "defaultSelectAll":false,
							                "Searching": false,
							                "isGridDefaultValuesToCheck":true,
							                "RecordsToShowPerPage":10000,
							                "rowList":[],
							                "Frozen":true,
							                "ViewRecordsInfo":true,
							                //"editableColumnList":['buildertek__Quantity__c','buildertek__Unit_Cost__c'],
							                "actions": actions
							            },
							            function(grid){
							               if (component.isValid()) {
							                    var targetCmp = component.find('quoteItem');
							                    var body = targetCmp.get("v.body");
							                    body.push(grid);
							                    targetCmp.set("v.body", body); 
							                }
							            }
							        );
	},
	createProductItemPicker: function(component, event, helper, groupId) {
		var overlayLib;
		$A.createComponents([
								["c:BT_ProductsAdder",{
					            	"aura:id":"btSelectProducts",
					                "recordId":component.get("v.recordId"),
	                                "_gFiled":"buildertek__Grouping__c",
	                                "_gSobject":"buildertek__Quote_Item__c",
	                                "_gFilter":"",
					                "saveCallback":function(Items){
					                	console.log('items',Items);
					                	var newQuoteItems = [];
					                	for (var i = 0; i < Items.length; i++) { 
						                	var newQi = new Object();
						                		newQi.buildertek__Quote__c = component.get("v.recordId"),
					                			newQi.buildertek__Grouping__c = Items[i].groupid;
											    newQi.buildertek__Product__c = Items[i].productId;
											    newQi.Name = Items[i].productName;
											    newQi.buildertek__budget__c = component.get("v.recordId");
											    newQi.buildertek__Unit_Price__c = Items[i].salesPrice;
											    newQi.buildertek__quantity__c = Items[i].quantity;
											    newQuoteItems.push(newQi);
									    }
									    overlayLib.close();
									    $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
									    helper.addSelectedProducts(component, event, helper, newQuoteItems);
					                },
					                "cancelCallback":function(){
					                	overlayLib.close();
					                }
				                }],
				                
							],
			                function(components, status, errorMessage){
				                if (status === "SUCCESS") {
				                   component.find('overlayLib').showCustomModal({
                                       header: "Add Product(s) in Quote",
                                       body: components[0], 
                                       footer:"",
                                       showCloseButton: true,
                                       cssClass: "btmodal_80",
                                       closeCallback: function() {
                                       
                                       }
                                   }).then(function (overlay) {
                                	   overlayLib = overlay;
                                   });
				                }
				            }
				        );
					
	},
	
	createRFQPicker: function(component, event, helper) {
		var overlayLib;
		$A.createComponents([
								["c:BT_RFQSelection",{
					            	"aura:id":"btSelectRFQ",
					                "projectId":"",
					                "quotId":component.get("v.recordId"),
					                "saveCallback":function(Items){
					                  console.log('TestSAKINA', Items);
					                	 $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
					                	overlayLib.close();
										var action = component.get("c.createQuoteItem");
								            action.setParams({ quoteItemsJSON : JSON.stringify(Items) });
								            action.setCallback(this, function(response) {
								                var state = response.getState();
								                if (state === "SUCCESS") {
								                   var grid = component.find('quoteItemList');
								                   grid.refreshData();
								                }
								                else if (state === "INCOMPLETE") {
								                    // do something
								                }
								                else if (state === "ERROR") {
								                    var errors = response.getError();
								                    if (errors) {
								                        if (errors[0] && errors[0].message) {
								                            console.log("Error message: " + 
								                                     errors[0].message);
								                        }
								                    } else {
								                        console.log("Unknown error");
								                    }
								                }
								            });
								            $A.enqueueAction(action);
					                },
					                "cancelCallback":function(){
					                	overlayLib.close();
					                }
				                }],
				                
							],
			                function(components, status, errorMessage){
				                if (status === "SUCCESS") {
				                   component.find('overlayLib').showCustomModal({
                                       header: "Select RFQ's",
                                       body: components[0], 
                                       footer:components[0].find("footer"),
                                       showCloseButton: true,
                                       cssClass: "btmodal_60",
                                       closeCallback: function() {
                                       
                                       }
                                   }).then(function (overlay) {
                                	   overlayLib = overlay;
                                   });
				                }
				            }
				        );
					
	},
	
	createForceRecordEditComp: function(component, event, helper, recordId, action, title, obj) {
		$A.createComponent("c:BT_Force_Record_Edit",{
					            	"aura:id":"btNewQuoteItemEdit",
					                "title": title,
					                "objectApi":"buildertek__Quote_Item__c",
					                "parentId":component.get("v.recordId"),
					                "parentApi":"buildertek__Quote__c",
					                "newRecordName":"Quote Item",
					                "saveCallBack":component.get("v.refreshGridAction"),
					                "newRecordId":recordId,
					                "defaultValue":obj,
					                "action":action
				                },
				                function(grid){
					               if (component.isValid()) {
					                    var targetCmp = component.find('newQuoteItem');
					                    var body = targetCmp.get("v.body");
					                    body.push(grid);
					                    targetCmp.set("v.body", body); 
					                }
					            }
					        );
	},
	
	addSelectedProducts: function(component, event, helper, items) {
	
		var action;
		action = component.get("c.createQuoteItem");
        action.setParams({
            quoteItemsJSON: JSON.stringify(items)
        });
        action.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === "SUCCESS") {
            	var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
	                "title": "",
	                "message": "Product Added succesfully.",
	                "type": "success"
	            });
	            toastEvent.fire();
	            var grid = component.find('quoteItemList');
	            grid.refreshData();
			} else {
				var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
	                "type":"error",
	                "title": "Error!",
	                "message":  response.getError()[0].message
	            });
	             toastEvent.fire();
			}
        });
        $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
        $A.enqueueAction(action);
	},
         // get an Price from 
    getProductDetails:function(component,event,helper){
        var action = component.get("c.getProductPrice");
        var productId = component.get("v.productId");
        var productName = component.get("v.productName");
        console.log("----productId",productId);
        action.setParams({"productId":productId});
        action.setCallback(this,function(respo){
            var res = respo.getReturnValue(); 
            console.log("----respo---",res.length);
            var getProductDetails = component.get("v.newQuote");
            delete getProductDetails.buildertek__Grouping__r;
            console.log("@quote@",component.get("v.recordId"));
            getProductDetails.buildertek__Quote__c = component.get("v.recordId");
            console.log("getprodct----",JSON.stringify(getProductDetails));
            if(res.length>=1) {
                getProductDetails.buildertek__Unit_Cost__c = res[0].UnitPrice;
            }else{
                getProductDetails.buildertek__Unit_Cost__c = 0;
            }
            getProductDetails.buildertek__Product__c = productId;
            
            getProductDetails.Name = productName;
            component.set("v.newQuote",getProductDetails);
            
            console.log("getprodct----",JSON.stringify(getProductDetails));
			
            console.log("----log",res);
        });
        $A.enqueueAction(action);
    },
        
    setSortIds : function(component, event, helper, groups) {
        console.log(groups);
        
        if(groups && groups.length > 0) {
            
            var updatedSections = [];
            updatedSections = helper.convert(groups, updatedSections, 1, '', '', 0, false);
            
            var action = component.get("c.updateGroupsOrder");
            action.setParams({ groups : updatedSections });
            action.setCallback(this, function(response) {});
            $A.enqueueAction(action); 
        }
    },
    // Convert JSON object to sObject List
    convert:function(sections, updatedSections, level, parentID, parentSortId, hierarchyLevel, isChildren) {
        
        var item, key, accordion, sortid, sortvalue;
        for( key in sections) {
            if( typeof sections.hasOwnProperty === 'function' && !sections.hasOwnProperty(key) ) continue;
            item = sections[key];
            sortvalue =  this.sortIdFormat(level, 3).trim();
            level++;
            
            sortid =  parentSortId+' '+sortvalue;
            
            if(typeof item.children !== 'object' && !isChildren){
                hierarchyLevel = 0;
            }
            
            accordion = { Id: item.id, 
                         buildertek__Sort_Id__c:sortid.trim()
                        };
            updatedSections.push(accordion);
            
            
            
            if( typeof item.children === 'object' ) {
                isChildren = true;
                hierarchyLevel ++;
                this.convert(item.children, updatedSections, 1, item.id, sortid, hierarchyLevel, isChildren);
                hierarchyLevel --;
            }
        }
        
        return updatedSections;
    },
    
    sortIdFormat: function(number, width) {
        
        width -= number.toString().length;
        if(width > 0) {
            return ' ' + new Array(width + (/\./.test(number) ? 2 : 1)).join('0') + number;
        }
        return ' ' + number;
        
    },
    
    deleteRecord: function(component, event,helper) {
        var deleteString = component.get("v.deleteRecords");
        var action = component.get("c.deleteLineItems");
        action.setParams({ quoteItemIds : deleteString });
        action.setCallback(this, function(response) {
            var grid = component.find('quoteItemList');
            grid.refreshData();
            $A.get('e.force:refreshView').fire();
            component.set("v.selectedRows",[]);
            component.set("v.selectedCol",[]);
            $A.get("e.force:refreshView").fire();
            var grid = component.find('quoteItemList');
			grid.refreshData();
			component.refreshData();
        });
        $A.enqueueAction(action);
    }
        
})