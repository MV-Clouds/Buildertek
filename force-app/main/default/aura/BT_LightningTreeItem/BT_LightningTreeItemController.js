/*
 * Copyright 2011-2018, @ thoriyas
 * All rights reserved
 */

/* Lightning CLI rule */
({
	doInit: function (component, event, helper) {
		component.get('v.expanded') ? component.set('v.iconName', 'dash') : component.set('v.iconName', 'new');
		helper.doInit(component, event, helper);
	},

	expandClick: function (component, event, helper) {
		helper.expandClick(component, event, helper);
	},

	nodeClick: function (component, event, helper) {
		helper.nodeClick(component, event, helper);
	},

	checkBoxFocus: function (component, event, helper) {
		// This method will be used only for select mode = 3.
		// It will set the level of current node as last effective node level
		// Later that level will be used to set checked flag of parent and grand parent nodes.

		if (component.get("v.selectMode") == 3) {
			component.set("v.lastEffectiveNodeLevel", component.get("v.level"));
		}
	},

	checkBoxChange: function (component, event, helper) {
		// This method will be used only for select mode = 3.
		// It will start setting checked flag for all parent and grand parent nodes

		if (component.get("v.selectMode") == 3) {
			var updateParentNodeStatusEvent = component.getEvent("updateParentNodeStatus");
			if (updateParentNodeStatusEvent) {
				updateParentNodeStatusEvent.setParams({
					"callerLevel": component.get("v.level"),
					"checked": component.get("v.checked")
				});
				updateParentNodeStatusEvent.fire();
			}
		}
	},

	parentCheckedChange: function (component, event, helper) {
		// This method will be used only for select mode = 3.
		// It will be listen by all child nodes of node whose checked flag is updated

		if (component.get("v.selectMode") == 3) {
			if (component.get("v.level") > component.get("v.lastEffectiveNodeLevel")) {

				// Set the checked flag as per parent's checked flag
				component.set("v.checked", component.get("v.parentChecked"));

				// Also update the counts for checked nodes
				if (component.get("v.checked")) {
					component.set("v.checkedChildrenCount", component.get("v.children") != null ? component.get("v.children").length : 0);
				} else {
					component.set("v.checkedChildrenCount", 0);
				}
			}
		}
	},

	expandedChange: function (component, event, helper) {
		helper.expandedChange(component, event, helper);
	},

	checkedChange: function (component, event, helper) {
		// This method will be used only for select mode = 1.
		// It will add current node into checked nodes list and that will automatically set checked = false for previously selected nodes

		if (component.get("v.selectMode") == 1) {
			// Get current node
			var currentNode = component.get("v.userData");

			// Get checked nodes
			var checkedNodes = component.get("v.checkedNodes");
			if (checkedNodes == undefined) {
				checkedNodes = [];
			}

			if (component.get("v.checked")) {
				// Current node will be the only checked node. Clear all old checked nodes 
				checkedNodes = [];
				checkedNodes.push(currentNode);
			}
			component.set("v.checkedNodes", checkedNodes);
		}
	},

	activeNodeChange: function (component, event, helper) {
		// This method will be listen by every tree node item to set active = false for previously active node

		// Get current node
		var currentNode = component.get("v.userData");

		// Get active node
		var activeNode = component.get("v.activeNode");
		// console.log('activeNode', activeNode.id);
		// console.log('currentNode', currentNode.id);
		// Set active flag
		if (currentNode.id == activeNode.id) {
			component.set("v.active", true);
		} else {
			// console.log('else');
			component.set("v.active", false);
		}
	},

	selectedNodesChange: function (component, event, helper) {
		// This method will be listen by every tree node when any tree node is added or removed from selected items.

		// Get current node
		var currentNode = component.get("v.userData");

		// Get selected nodes
		var selectedNodes = component.get("v.selectedNodes");

		// Set default selected to false
		var selected = false;

		// Check if node is selected
		for (var i in selectedNodes) {
			var node = selectedNodes[i];
			if (node.id == currentNode.id) {
				selected = true;
				break;
			}
		}
		// Set selected flag
		component.set("v.selected", selected);

		// For select mode = 3, if parent is selected, mark child as selected
		if (!component.get("v.selected") && component.get("v.selectMode") == 3 && component.get("v.parentSelected")) {
			component.set("v.selected", true);
		}
	},

	checkedNodesChange: function (component, event, helper) {
		// This method will be used only for select mode = 1.
		// It will be listen by every tree node item to set checked = false for previously checked node

		if (component.get("v.selectMode") == 1) {
			// Get current node
			var currentNode = component.get("v.userData");

			// Get checked nodes
			var checkedNodes = component.get("v.checkedNodes");

			// Set default checked to false
			var checked = false;

			// Check if node is checked
			for (var i in checkedNodes) {
				var node = checkedNodes[i];
				if (node.id == currentNode.id) {
					checked = true;
					break;
				}
			}

			// Set checked flag
			component.set("v.checked", checked);
		}
	},

	updateParentNodeStatus: function (component, event, helper) {
		// Only parent should listen this event. Decide that using node level. 
		// For grand parent it will be called recursively.
		// Also node must be checkable 
		if (component.get("v.nodeCheckable") && component.get("v.level") == (event.getParam("callerLevel") - 1)) {
			// Get checked parameter
			var checked = event.getParam("checked");

			// Set the count of checked child nodes as per checked parameter   
			if (checked) {
				component.set("v.checkedChildrenCount", component.get("v.checkedChildrenCount") + 1);
			} else {
				component.set("v.checkedChildrenCount", component.get("v.checkedChildrenCount") - 1);
			}

			// Check if all child nodes are checked
			if (component.get("v.checkedChildrenCount") == component.get("v.children").length) {
				// If all child nodes are checked and current node is not checked, set checked = true for current node 
				// and start recursive call
				if (!component.get("v.checked")) {
					component.set("v.checked", true);
					var updateParentNodeStatusEvent = component.getEvent("updateParentNodeStatus");
					if (updateParentNodeStatusEvent) {
						updateParentNodeStatusEvent.setParams({
							"callerLevel": component.get("v.level"),
							"checked": component.get("v.checked")
						});
						updateParentNodeStatusEvent.fire();
					}
				}
			} else {
				// If current node is selected and one or more child nodes are not checked, set checked = false for current node 
				// and start recursive call
				if (component.get("v.checked")) {
					component.set("v.checked", false);
					var updateParentNodeStatusEvent = component.getEvent("updateParentNodeStatus");
					if (updateParentNodeStatusEvent) {
						updateParentNodeStatusEvent.setParams({
							"callerLevel": component.get("v.level"),
							"checked": component.get("v.checked")
						});
						updateParentNodeStatusEvent.fire();
					}
				}
			}
		}
	},

	addNodeIntoCheckedNodes: function (component, event, helper) {
		// This method will be listen by every tree node item when user want checked nodes from the tree

		// Check if node is checked and parent node is not checked
		if (component.get("v.startGetCheckedNodes") && component.get("v.checked")) {
			// If select mode  = 3 and parent node is checked, do not add current node
			if (component.get("v.selectMode") == 3 && component.get("v.parentChecked")) {
				return;
			}

			// Get current node
			var currentNode = component.get("v.userData");

			// Get checked nodes
			var checkedNodes = component.get("v.checkedNodes");
			if (checkedNodes == undefined) {
				checkedNodes = [];
			}

			// Add current node
			checkedNodes.push(currentNode);

			// Set checked nodes
			component.set("v.checkedNodes", checkedNodes);
		}
	},

	// This method will be listen by every tree node item when user want to refresh the tree node
	refreshTreeNode: function (component, event, helper) {
		var key = event.getParam("key"),
			node = component.get("v.userData");
		if (node && node.key === key) {
			helper.getChildNodes(component, event, helper);
		}
	},

	// redirectToOption: function (component, event, helper) {
	// 	var id = event.currentTarget.getAttribute("data-title-id");
	// 	if (id != undefined && id != null && id !='') {
	// 		var elem = document.getElementById(id);
	// 		elem.scrollIntoView(true);
	// 		window.scrollBy(0, -5000);
	// 	}
	// }
})