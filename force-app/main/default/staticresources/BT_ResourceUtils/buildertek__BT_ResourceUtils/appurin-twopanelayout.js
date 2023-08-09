Appurin.namespace('Appurin.layout');
/* 
*/
Appurin.layout.createJq2PaneLayout = function (config) {
	var containerId = config.containerId;
	var westId = config.westId;
	var contentId = config.contentId;
	var layoutSettings = {
		name: "outerLayout",
		// options.defaults apply to ALL PANES - but overridden by pane-specific settings
		defaults: {
			size:					"auto",
			minSize:				50,
			paneClass:				"pane" ,				// default = 'ui-layout-pane'
			resizerClass:			config.resizerClass,	// default = 'ui-layout-resizer'
			togglerClass:			"toggler",				// default = 'ui-layout-toggler'
			buttonClass:			"button",				// default = 'ui-layout-button'
			contentSelector:		".content",				// inner div to auto-size so only it scrolls, not the entire pane!
			contentIgnoreSelector:	"span",					// 'paneSelector' for content to 'ignore' when measuring room for content
			togglerLength_open:		35,						// WIDTH of toggler on north/south edges - HEIGHT on east/west edges
			togglerLength_closed:	35,						// "100%" OR -1 = full height
			hideTogglerOnSlide:		true,					// hide the toggler when pane is 'slid open'
			togglerTip_open:		"Close This Pane",
			togglerTip_closed:		"Open This Pane",
			resizerTip:				"Resize This Pane",
			fxName:					"slide",				// none, slide, drop, scale
			fxSpeed_open:			750,
			fxSpeed_close:			1500,
			fxSettings_open:		{ easing: "easeInQuint" },
			fxSettings_close:		{ easing: "easeOutQuint" }
		},
		west: {
			paneSelector:			"#" + westId, 			// sample: use an ID to select pane instead of a class
			size:					config.westWidth,
			spacing_closed:			21,						// wider space when closed
			togglerLength_closed:	21,						// make toggler 'square' - 21x21
			togglerAlign_closed:	"top",					// align to top of resizer
			togglerLength_open:		0,						// NONE - using custom togglers INSIDE west-pane
			togglerTip_open:		"Close West Pane",
			togglerTip_closed:		"Open West Pane",
			resizerTip_open:		"Resize West Pane",
			slideTrigger_open:		"click", 	
			initClosed:				false,
			fxSettings_open:		{ easing: "easeOutBounce" }
		},
		center: {
			paneSelector:			"#" + contentId ,				// sample: use an ID to select pane instead of a class
			onresize:				"innerLayout.resizeAll",		// resize INNER LAYOUT when center pane resizes
			minWidth:				200,
			minHeight:				200
		}
	};
	
	outerLayout = j$("#" + containerId).layout( layoutSettings );
	
	var westSelector = "#" + westId; 
	// Create div for refresh button indised the tree header
	j$("#" + containerId).find('.content').prepend(j$("#" + containerId).find('.header').css('display', 'block'));
	// Binding the on click event for refresh button to make them functional
	j$("#" + containerId).find("button[id$='layoutRefreshButton']").click(function(){ Appurin.layout.refreshActiveNode(config.treeId); return false;});   
	return outerLayout;
};

/*
Purpose: 	This method will be invloked when refresh button will be clicked.
Parameters: treeId: Id of tree, which we need to refresh.
Returns:	 
Throws [Exceptions]:
*/				
Appurin.layout.refreshActiveNode = function(treeId){
	var tree = j$('#'+treeId).fancytree('getTree');
	var node =  tree.getActiveNode();
	if(node!=null){
		if(!node.data.lazy){
			node.data.lazy=true;
			node.render();
			node.resetLazy(); 
			node.setExpanded(true);
			return;
		}
		node.resetLazy(); 
		node.setExpanded(true);
	}else{
		tree.reload();
	}
};
		