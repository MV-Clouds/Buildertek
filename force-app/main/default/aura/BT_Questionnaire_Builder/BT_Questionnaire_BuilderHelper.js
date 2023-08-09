({
    
	setSortIds : function(component, event, helper, sections) {
		//$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();

		var updatedSections = [];
		updatedSections = helper.convert(sections, updatedSections, 1, '', '', 0, false);
		
		var action = component.get("c.updateCitationOrder");
            action.setParams({ citations : updatedSections });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                   //$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
                   var refreshTreeNode = $A.get("e.c:BT_RefreshTreeNodeEvent");
                   refreshTreeNode.setParams({"key" : "ALL_TREE"});
                   refreshTreeNode.fire();
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
	// Convert JSON object to sObject List
	convert:function(sections, updatedSections, level, parentID, parentSortId, hierarchyLevel, isChildren) {
		
		var item, key, accordion, sortid, sortvalue;
		for( key in sections) {
		    if( !sections.hasOwnProperty(key) ) continue;
		    item = sections[key];
		    sortvalue =  this.sortIdFormat(level, 3).trim();
		    level++;
		    
		    sortid =  parentSortId+' '+sortvalue;
		    
		    if(typeof item.children !== 'object' && !isChildren){
		    	hierarchyLevel = 0;
		    }
		    
		    accordion = { Id: item.id, 
		    			  buildertek__Sort_Id__c:sortid.trim(),
		    			  buildertek__Sort_Value__c:sortvalue,
		    			  buildertek__Hierarchy_Level__c:hierarchyLevel,
		    			  buildertek__Parent__c:parentID
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
	
	/* Get the default query string for the section tree. */
	defaultTreeFilterCondition : function(component) {
        var action = component.get("c.getTreeQueryParamters");
        var adId = component.get("v.recordId");
        action.setParams({selectionSheetId : adId});
        
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.defaultTreeFilterCondition",response.getReturnValue());
                console.log('getTreeQueryParamters::',response.getReturnValue());
                component.set("v.isJsLoad", true);
            }
        });
        $A.enqueueAction(action);
	}
})