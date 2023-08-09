/* Appurin javascript library code to provide base Appurin tree that uses TreePickerNode
* Copyright � 2015-2016, dbixo Inc.
* All rights reserved
*
*
* - Rendering the tree as per the tree configuration. Using the jquery plugin called Fancytree to render the tree. Also added
*   few methods to display selected tree nodes on area for selected records, activate the last visited node once user came back to explorer page and propogating the checkbox status
*   of parent into children for selectMode = 3 after fethcing the children from server.
*
* - Modifications:
* -
*/

/*
Purpose: 	Creating the tree using jquery plugin called fancy tree. 
Parameters: 
			1)	config: All Fancy tree configurstion options like on which DOM element tree will be rendered, do we need checkbox for tree nodes. whats the selection mode. 
				We are preparing this fancy tree configuration in avJQLayoutComponent itself and passing it as perameter.
				If we have not provided any confgiration option in avJQLayoutComponent, it will be extended from "treeConfigOptions" or default tree options.
			    	
Returns:	Fancytree 
Throws [Exceptions]:
*/

// Define Appurin namespace to hold different tree implementation
Appurin.namespace('Appurin.tree');

Appurin.tree.createFancyTree = function (treeType, config) {
	// DOM element on which tree will be generated
	var treeDiv = '#' + config.renderTo; 
	// Define default tree config options
	var treeConfigOptions = {
		// This is the extension to persist the tree state. So on rereneder for tree, previsouly expanded and selected nodes will be come as they were.
		// To make it work we need to include the jquery.fancytree.persist.js file
		extensions: ["persist"],
		// Default title
		title : 'Appurin Tree',
		rootCollapsible: false,
		keyboard: true,
		// Store the tree state in cookie
		cookie: {
			expires: null
		},
		keyPathSeparator: "/",
		// Default icon path for all different types of nodes
		imagePath:'jquery/images/',
		// Default no need to display checkbox for nodes
		checkbox: false,
		// Selection mode
		selectMode : config.selectMode,
		// Default source/root nodes
		source: [
			{ title: 'Test Node 1', lazy: false },
			{ title: 'Test Node 2', select: true }
		],
		// Persist the tree state. Expanding the lazy nodes also and storing automatically
		persist: {
			expandLazy: true,
			store: "auto" 
		},
		activate: function(event, data) {
			// We need to render the detail of record on North pane of the two pane layout when node for record get activated from tree.
			// Previosuly we were doing it onClick so it was getting executing everytine node expanded or collapse. That was not correct behaviour.
			onClickTreeNode(data.node, event);
			// Once tree loaded completely, it will set the state of all nodes as per the coockie. So once its done, incase there are few node are already selected we need to display selected nodes on the area of selected recoeds. So setActivated() method will be fired for last selected node in the tree and automatically all selectedrecords will be added on RHS. 
			Appurin.tree.treeSelectionUpdate(data.node);
		},
		select: function(event, data) {
			// We are making selected record as activated. So once state of the tree get persisted. last setActivated() method can fire and nodes comes selected on RHS.
			data.node.setActive(true);
			Appurin.tree.treeSelectionUpdate(data.node);
		},
		expand: function(event, data) {
			j$(".fancytree-title").easyTooltip({width: '200px', isLightning : true});			
		},
		click: function(event, data) {
		},
		lazyLoad: function(event, data){
			// This method will be executed everytime any parent node will be expanded. It will fetch the children for parent node as per the query string of the parent node.
			// resutlDeffered will be used to store the result of callback for fetching children
			var resultDeferred = new j$.Deferred();
			// We need to set the Node[] as the result of lazy load function. Here Node[] is array of all children. Callback will return Node[] and we will set them as result of parent node.
			data.result = resultDeferred;
			// Get model and fields attached to this proxy to retrieve from server
			var node = data.node;
			// Need to prefix tree type
			var id = treeType + '/'+node.data.userData.key;
			var objectType = node.data.userData.objectType;
			var nodeType = node.data.userData.nodeType;
			var childObjectType = node.data.userData.childObjectType;
			var titleFieldName = node.data.userData.titleFieldName;
			var nodeQuery = node.data.userData.nodeQuery;
			var showGroupByCharts = node.data.userData.showGroupByCharts;
			var showResultObjectsInTree = node.data.userData.showResultObjectsInTree;
			var showNewButton = node.data.userData.showNewButton;
			// Salesforce record id
			var tncId = node.data.userData.tncId;
			// Order by field in the query for child records
			if(node.data.userData.orderChildrenBy+'' != 'undefined') {
				var orderChildrenBy = node.data.userData.orderChildrenBy;
			} else {
				var orderChildrenBy = '';
			}
			// Query parameters for child records
			if(node.data.userData.queryParameters+'' != 'undefined') {
				var queryParameters = node.data.userData.queryParameters;
			} else {
				var queryParameters = '{}';
			}
			
			// Fetching all childrens.
			buildertek.BT_TreeRemotingModel.getChildren(objectType, id, 'Id,Name', nodeType, 
											childObjectType, titleFieldName, nodeQuery,
											showGroupByCharts, showResultObjectsInTree, showNewButton, tncId, 
											orderChildrenBy, queryParameters, config.displayColumnNames,
											function(result, event) {
												// Adjust checkbox status for all child records based on configured options
												Appurin.tree.setCheckableForChildren(result, treeConfigOptions);
												// Set the callback result as the child nodes
												resultDeferred.resolve(result);
											});
											j$(".fancytree-title").easyTooltip({width: '200px', isLightning : true});	
		}
	};
	
	// Extending the above tree configuration in configuration passed as parameter.
	j$.extend(treeConfigOptions, config);
	
	// Set checkbox options for root nodes of the tree.This will be executed only at the time tree is going to generate first time.
	if (treeConfigOptions.checkbox) {
		Appurin.tree.setCheckableForChildren(treeConfigOptions.source, treeConfigOptions);
	}
	
	// Render tree using the jquery plugin called fancytree.
	var tree = j$(treeDiv).fancytree(treeConfigOptions);
	return tree;
};

/*
Purpose: 	This method will be invloked when any node inside the tree will be selected. All selected tree nodes will be displayed on the RHS section for selected records.
			For selectMode = 3, selected and checkable node at the most higher level will be considered as the selected node. 
Parameters: node: Selected tree node. This node will be used to get the tree for which we need to update selected nodes.
Returns:	 
Throws [Exceptions]:
*/		
Appurin.tree.treeSelectionUpdate = function(node){
	// Get all selected nodes of tree
	var selectedTreeNodes = node.tree.getSelectedNodes();
	// List of all seleted Node
	var selectedTreePickerNodes = []
	// Array of uniques ids for all selected records 
	var selectedNodeKeys = [];
	j$.each(selectedTreeNodes, function(i, item) {
		// Check if node with same id is not added in the list and node is chechable
		if(selectedNodeKeys.indexOf(item.data.userData.key) == -1 && !item.hideCheckbox){
			// Get the parent node to check if the parent is selected or not
			var parentNode = item.getParent();
			// If parent is not checkable and parent is selected, we will consider all children as selectedo
			// If parent is not selected then also we will consider all selected children as selected records
			if((item.data.userData.nodeType != 'NodeType_GroupBy' && item.data.userData.nodeType != 'NodeType_GroupByRoot' ) && 
			((parentNode.hideCheckbox && parentNode.selected) || (parentNode.data.userData.nodeType =='NodeType_GroupBy' && parentNode.selected) || (!parentNode.selected))){
				// We will prepare the TreePickerNode object from tree Node to pass it in the controller
				newNodeTodAdd = {};
				newNodeTodAdd.fullPath = item.getKeyPath(); // Full path of the selected node
				newNodeTodAdd.id = item.data.userData.key;  // Key of the node. Usually salesforce record ids. 
				newNodeTodAdd.objectType = item.data.userData.childObjectType; // Object type of child record
				// URL for selected record detail. For group we need to prepare special url. for other object we can directly use the id
				if(item.data.userData.objectType == 'AmazonFile' || item.data.userData.objectType == 'AmazonFolder'){
					if(item.data.userData.objectType == 'AmazonFile'){
						/*
						if(item.data.userData.downloadUrl != null && item.data.userData.downloadUrl != ''){
							newNodeTodAdd.detailUrl = '/'+item.data.userData.downloadUrl;
						} else{
							newNodeTodAdd.detailUrl = 'https://s3.amazonaws.com/'+item.data.userData.key;
						}
						*/
						newNodeTodAdd.detailUrl = '';
					} else if(item.data.userData.objectType == 'AmazonFolder'){
					    newNodeTodAdd.detailUrl = '';
					}
				} else{
					newNodeTodAdd.detailUrl = item.data.userData.childObjectType == 'Group' ? '/setup/own/groupdetail.jsp?id='+item.key : '/'+item.data.userData.key; 
				}
				// Icon path for selected node. For few tree picker we are displaying icon for all selected record. 
				newNodeTodAdd.icon = item.tree.options.imagePath + item.data.icon; 
				newNodeTodAdd.name =  Appurin.tree.getHierarchicalTreeNodePath(item, item.tree.data.NumberOfNodePathLevels); // Name of the selected record
				selectedTreePickerNodes.push(newNodeTodAdd);
				selectedNodeKeys.push(item.data.userData.key);
			}
		}
	});
	// Show selected records on RHS area for selected records list
	Appurin.tree.getSelectedNodesInformation(node.tree.options.renderTo, selectedTreePickerNodes);
}

/*
Purpose: 	This method will be invloked for every selected tree node to prepare the hirarchical node tital.
Parameters: 1) node: Selected tree node. 
			2) pathLevels: Upto what level path should be display. Will be used to fetch parent.
Returns:	Hierarchical node title 
Throws [Exceptions]:
*/
Appurin.tree.getHierarchicalTreeNodePath = function(node, pathLevels){
	// Selected node title
	var nodePath = node.title;
	// Level upto which we need to display hierarchical titel 
	var numberOfPathLevels = parseInt(pathLevels);
	// Find the parent node
	node = node.getParent();
	// If parent is not null or parent is not root node here root node means the default root node created by fancy tree or number of path level is > 0 
	while(node != null && !node.isRoot() && numberOfPathLevels > 0){
		var newNodePath =  node.title+'/'+nodePath;
		nodePath = newNodePath;
		node = node.getParent();
		numberOfPathLevels--;
	}
	return nodePath;
}

/*
Purpose: 	1) This method will be invloked from treeSelectionUpdate() when any node inside the tree will be selected to display all
			selected tree nodes on the RHS section for selected records. 
			2) Also the json string for selected nodes will be set inside the input hidden field so that value will be used inside the controller
Parameters: 1) treeId: Id of the tree for which we need to display selected nodes name on RHS. 
			2) selectedTreePickerNodes: List of all selected tree nodes.
Returns:	 
Throws [Exceptions]:
*/
Appurin.tree.getSelectedNodesInformation = function(treeId, selectedTreePickerNodes){
	// Get the table where list of selected records needs to be displayed 
	var tableForSelectedRecord = j$("div[id$='"+treeId+"']").parent().parent().find("tbody[id$='treeSelectedRecordsTableBody']");
	// If table for selected records is not available(for explorer pages), we don't need to do anything. 
	if(tableForSelectedRecord.html() == undefined){
		return false;
	}
	
	// Settign the JSON strong for all selected node into input hiddne field so it will be used inside the controller. We need to do it using the4 input hidded to overcome the limitation of multiple component on the same page
	j$("div[id$='"+treeId+"']").parent().parent().parent().find("input[id$='hiddenFieldForSelectedTreeNodesJsonString']").val(JSON.stringify(selectedTreePickerNodes));
	var trHtmlForNoRecordSelected = tableForSelectedRecord.find("#treeNoRecordSelectedRow").html();
	if(trHtmlForNoRecordSelected != undefined){
		treeNoRecordSelectedRow = tableForSelectedRecord.find("#treeNoRecordSelectedRow").css('display','table-row');
	}
	tableForSelectedRecord.html('');
	// If none of the tree node is selected message for no selection will be displayed.
	if(selectedTreePickerNodes.length == 0){
		tableForSelectedRecord.append(treeNoRecordSelectedRow);
	} else{
		// For each record new table row will be added with the record name.
		j$.each(selectedTreePickerNodes, function(i, item) {
			// Preparign the html for displaying detail link and icon for selected record
			var nameHTML = Appurin.tree.getNodeTitleHTML(item);
			tableForSelectedRecord.append("<tr><td class=''>"+nameHTML+"</td></tr>");
		});
	}
}

/*
Purpose: 	Preparign the html for displaying detail link and icon for selected record
Parameters: node: TreePickerNode for which detail link and icon needs to be prepared. 
Returns:	HTML with record detail url	and icon	 
Throws [Exceptions]:
*/
Appurin.tree.getNodeTitleHTML = function(node){
	var nameHTML = '';
	if(node.icon != '' && node.detailUrl != ''){
		// If Icon is available for node
		nameHTML = nameHTML + "<img src='"+node.icon+"' alt='' class='slds-icon slds-icon--x-small'/> <a href="+node.detailUrl+" class='slds-p-left--xx-small' target='_blank'>"+node.name+"</a>";
	} else if(node.icon == '' && node.detailUrl != ''){
		// If icon is not available for node then just name will be display
		nameHTML = nameHTML + "<a href="+node.detailUrl+" class='slds-p-left--xx-small' target='_blank'>"+node.name+"</a>";
	} else if(node.icon != '' && node.detailUrl == ''){
		// If no detail url then just display name
		nameHTML = nameHTML +"<img src='"+node.icon+"' alt='' class='slds-icon slds-icon--x-small' />"+node.name;
	}
	return nameHTML;
}

/*
Purpose: 	1) Checkbox will be display for node only if object type or record type of the node is available in checkableNodes
			2) Also the checkbox will be display for group node if its allowed to select group nodes 
			3) Populating the checkbox status of parent node into child nodes based on the configuration. If selelctMode is 3, we need to
			populate the checkbox startus of parent into all child nodes.
Parameters: 1) children: All children for which checkbix starus needs to setted.
			2) treeConfigOptions: Tree configuration option.
Returns:		 
Throws [Exceptions]:
*/
Appurin.tree.setCheckableForChildren = function(children, treeConfigOptions) {
	// Get list of all checkableNodes
	checkableNodes = treeConfigOptions.checkableNodes;
	j$.each(children, function(index, nodeData) { 
		var nodeObjType = nodeData.userData.objectType;
		var childNodeObjectType = nodeData.userData.childObjectType;
		var nodeRecType = nodeData.userData.recordType;
		var checkable = nodeData.userData.checkable;
		// If node is checkable and object type of node is available in checkable nodes
		// or if node is checkable and object type + record type of node is available in checkable nodes
		// or if node is checkable and child object type of node is available in checkable nodes
		// or if node is checkable and child object type + record type of node is available in checkable nodes, checkbox will be display.
		// Suppose for group node we have made node as chackable from configuration, but if child object type is not checkable then no need to display the checkbox for group node
		if (checkable && Appurin.isDefined(nodeObjType) && (j$.inArray(nodeObjType, checkableNodes) != -1 || j$.inArray(nodeObjType+'.'+nodeRecType, checkableNodes) != -1 || j$.inArray(childNodeObjectType, checkableNodes) != -1 || j$.inArray(childNodeObjectType+'.'+nodeRecType, checkableNodes) != -1)) {
			nodeData.hideCheckbox = false;
		} else if(nodeData.hideCheckbox != true){
			nodeData.hideCheckbox = true;
		}
		
		// We need to handle children recursively if already returned
		if (nodeData.children != null) {
			Appurin.tree.setCheckableForChildren(nodeData.children, treeConfigOptions);
		}
	});
}

/*
Purpose: 	Activate a node with specified path in the tree
Parameters: 1) treeId: tree id for which we need to activate the node
			2) keyPathForNode: Key path of the node which needs to be acitvated.
Returns:		 
Throws [Exceptions]:
*/
Appurin.tree.activateTreeNode = function(treeId, keyPathForNode) {
	var tree = j$("#"+treeId).fancytree("getTree");
	if (keyPathForNode == "") return;
	tree.loadKeyPath(keyPathForNode, function(node, status){
		if (status == "loaded") {
		} else if (status == "ok") {
			node.setExpanded(true);
			node.setActive(true);
			j$(node.span).click(); 
		}
	});
}

/*
Purpose: 	We need to set tooltip for child nodes when parent get expanded.
Parameters: 1) chilNodes: child nodes for which keys needs to be setted
			2) parentNode: parent node of childs
Returns:		 
Throws [Exceptions]:
*/
Appurin.tree.setEasyTooltipForChildren = function(chilNodes, parentNode){
	if(chilNodes == undefined) return;
	j$.each(chilNodes, function(i, childNode){
		childNode.tooltip = htmlDecode(childNode.tooltip);	
		// Recusrsiuvely setting title for children of children also
		Appurin.tree.setEasyTooltipForChildren(childNode.children, childNode);
	});
	return;
}