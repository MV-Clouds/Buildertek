/*
 * Copyright 2011-2018, @ thoriyas technologies.
 * All rights reserved
 */

/* Lightning CLI rule */
({
    doInit: function (component, event, helper) {
        // Auto expand up to max level to expand
        if (!component.get("v.expanded") && component.get("v.level") <= component.get("v.maxAutoExpandLevel")) {
            component.set("v.expanded", true);
            //component.get('v.expanded')?component.set('v.iconName','dash'):component.set('v.iconName','new');

        }

        // Set checkable attribute based on tree attribute
        var checkableSObjectTypes = component.get("v.checkableSObjectTypes");
        var nodeData = component.get("v.userData");
        // console.log('nodeData:::',nodeData);
        // console.log('totalOptions`:::',nodeData.totalOptions);
        // console.log('totalTestedOptions:::',nodeData.totalTestedOptions);
        var objectType = nodeData.objectType;
        var childNodeObjectType = nodeData.childObjectType;
        var nodeRecordType = nodeData.recordType;
        var checkable = nodeData.checkable;

        /* 
		If node is checkable and object type of node is available in checkable nodes or
        If node is checkable and object type + record type of node is available in checkable nodes or
        If node is checkable and child object type of node is available in checkable nodes or
        If node is checkable and child object type + record type of node is available in checkable nodes, check box will be display.
        Suppose for group node we have made node as checkable from configuration, but if child object type is not checkable then no need to display the check box for group node
        */
        if (component.get("v.checkable") && checkable && (typeof objectType !== 'undefined') && (checkableSObjectTypes.indexOf(objectType) !== -1 || checkableSObjectTypes.indexOf(objectType + '.' + nodeRecordType) !== -1 || checkableSObjectTypes.indexOf(childNodeObjectType) !== -1 || checkableSObjectTypes.indexOf(childNodeObjectType + '.' + nodeRecordType) !== -1)) {
            component.set("v.nodeCheckable", true);
        } else {
            component.set("v.nodeCheckable", false);
        }

        if (component.get("v.selectMode") == 3) {
            // If select mode is 3 and parent node is checked, we need to check current node
            if (component.get("v.parentChecked")) {
                component.set("v.checked", true);
            }

            // If select mode is 3 and parent node is selected, we need to select current node
            if (component.get("v.parentSelected")) {
                component.set("v.selected", true);
            }
        }
    },

    expandedChange: function (component, event, helper) {
        // Check if the children are already loaded or not.
        // If not, get child nodes and render them as tree node
        if (component.get("v.expanded") && component.get("v.lazy") == true) {
            //component.get('v.expanded')?component.set('v.iconName','dash'):component.set('v.iconName','new');
            helper.getChildNodes(component, event, helper);
        }
    },

    expandClick: function (component, event, helper) {
        debugger;
        // Toggle expanded flag
        var expanded = component.get("v.expanded");
        //alert(!expanded);
        component.set("v.expanded", !expanded);
        component.get('v.expanded') ? component.set('v.iconName', 'dash') : component.set('v.iconName', 'new');
        console.log('Expanded::', component.get('v.iconName'));
        var node = component.get("v.userData");
        console.log('Expanded:Node::', node);

        // Fire the event for tree node expand  
        var treeNodeClickEvent = $A.get("e.c:BT_TreeNodeClickEvent");
        if (treeNodeClickEvent) {
            console.log('--treeNodeClickEvent--', !expanded);
            treeNodeClickEvent.setParams({
                "nodeData": node,
                "actionType": !expanded == true ? "nodeexpand" : "nodecollapse"
            });
            treeNodeClickEvent.fire();
        }
        //component.get('v.expanded')?component.set('v.iconName','dash'):component.set('v.iconName','new');

    },

    nodeClick: function (component, event, helper) {
        debugger;
        console.log('On node Click..');
        // Get current node 
        var currentNode = component.get("v.userData");
        // Set current node as active
        component.set("v.activeNode", currentNode);

        // Fire the event for tree node click
        var treeNodeClickEvent = $A.get("e.c:BT_TreeNodeClickEvent");
        if (treeNodeClickEvent) {
            treeNodeClickEvent.setParams({
                "nodeData": component.get("v.userData"),
                "actionType": "nodeclick"
            });
            treeNodeClickEvent.fire();
        }
    },

    getChildNodes: function (component, event, helper) {
        // Get information of node whose child needs to be displayed
        var node = component.get("v.userData");
        var sObject = node.objSelectedRecord;
        if (node.objSelectedRecord != null) {
            node.objSelectedRecord = null;
        }
        // Get child nodes
        var getChildNodesAction = component.get("c.getChildNodes");
        getChildNodesAction.setParams({
            "treeType": component.get("v.treeType"),
            "sobjectFields": component.get("v.sobjectFields"),
            "nodeData": JSON.stringify(node)
        });

        getChildNodesAction.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.children", response.getReturnValue());
                if (component.get("v.selectMode") == 3) {
                    if (component.get("v.checked")) {
                        component.set("v.checkedChildrenCount", component.get("v.children").length);
                    }
                }
                component.set("v.lazy", false);
                console.log('getChildNodes :: ' + JSON.stringify(response.getReturnValue()));
                var c = response.getReturnValue();
                console.log({c});
            }
        });
        $A.enqueueAction(getChildNodesAction);

        // Set object back
        node.objSelectedRecord = sObject;
    }
})