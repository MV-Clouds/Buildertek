({
    
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
    createItemGrid : function(component, event, helper) {
        var actions = ['Edit','Delete','transfer_budget_amount'];
        $A.createComponent("c:BT_Datatable",
                           {
                               "aura:id":"ItemList",
                               "objectName": "buildertek__Budget_Item__c",
                               "fieldSetName": "buildertek__BT_Related_List_View_Fields",
                               "filterConditions" : "AND buildertek__Budget__c = '"+component.get("v.recordId")+"' ORDER BY buildertek__Group__r.Name ASC"
                           },
                           function(grid){
                               if (component.isValid()) {
                                   var targetCmp = component.find('budgetItem');
                                   var body = targetCmp.get("v.body");
                                   body.push(grid);
                                   targetCmp.set("v.body", body); 
                               }
                           }
                          );
    },
    
    createForceRecordEditComp: function(component, event, helper, recordId, action, title, objAPI, obj) {
        $A.createComponent("c:BT_Force_Record_Edit",{
            "aura:id":"btNewItemEdit",
            "title": title,
            "objectApi":objAPI,
            "parentId":component.get("v.recordId"),
            "parentApi":"buildertek__Budget__c",
            "newRecordName":"Budget Item",
            "saveCallBack":component.get("v.refreshGridAction"),
            "newRecordId":recordId,
            "defaultValue":obj,
            "action":action
        },
                           function(grid){
                               if (component.isValid()) {
                                   var targetCmp = component.find('newItem');
                                   var body = targetCmp.get("v.body");
                                   body.push(grid);
                                   targetCmp.set("v.body", body); 
                               }
                           }
                          );
    },
    
    createRFQ : function(component, event, helper) {
        var action;
        action = component.get("c.createRFQFromBudget");
        action.setParams({
            budget: component.get("v.sampleNewRecord"),
            rfq: component.get("v.newRFQ"),
            rfqItemsJson: JSON.stringify(component.get("v.newRFQItems"))
        });
        action.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === "SUCCESS") {
                component.find('notifLib').showNotice({
                    "variant": "success",
                    "header": "RFQ has been created!",
                    "message": "RFQ created",
                    closeCallback: function() {
                    }
                });
            } else {
                component.find('notifLib').showNotice({
                    "variant": "error",
                    "header": "Error!",
                    "message": response.getError()[0].message,
                    closeCallback: function() {
                    }
                });
            }
        });
        
        $A.enqueueAction(action);
    },
    
    
    addSelectedProducts : function(component, event, helper, items) {
        var action;
        action = component.get("c.createBudgetItem");
        action.setParams({
            budgetItemsJSON: JSON.stringify(items)
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
                var grid = component.find('ItemList');
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
        
        $A.enqueueAction(action);
    },
    
    getProductDetails:function(component,event,helper){
        var action = component.get("c.getProductPrice");
        var productId = component.get("v.productId");
        var productName = component.get("v.productName");
        console.log("----productId",productId);
        action.setParams({"productId":productId});
        action.setCallback(this,function(respo){
            var res = respo.getReturnValue(); 
            console.log("----respo---",res.length);
            var getProductDetails = component.get("v.newBudgetLine");
            delete getProductDetails.buildertek__Grouping__r;
            console.log("@Budgetline@",component.get("v.recordId"));
            getProductDetails.buildertek__Budget__c = component.get("v.recordId");
            console.log("getprodct----",JSON.stringify(getProductDetails));
            if(res.length>=1) {
                getProductDetails.buildertek__Unit_Price__c = res[0].UnitPrice;
            }else{
                getProductDetails.buildertek__Unit_Price__c = 0;
            }
            getProductDetails.buildertek__Product__c = productId;
            
            getProductDetails.Name = productName;
            component.set("v.newBudgetLine",getProductDetails);
            
            console.log("getprodct----",JSON.stringify(getProductDetails));
            
            console.log("----log",res);
        });
        $A.enqueueAction(action);
    },
    
    deleteRecord: function(component, event,helper) {
        var deleteString = component.get("v.deleteRecords");
        //alert('deleteString ----------> '+JSON.stringify(deleteString));
        var action = component.get("c.deleteLineItems");
        action.setParams({ budgetItemIds : deleteString });
        action.setCallback(this, function(response) {
            component.set("v.selectedRows",[]);
            component.set("v.selectedCol",[]);
            $A.get('e.force:refreshView').fire();
            var grid = component.find('ItemList');
            grid.refreshData();
            component.refreshData();
            
        });
        $A.enqueueAction(action);
    }
})