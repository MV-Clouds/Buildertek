/*
 JS utility methods
 */

var Appurin = {}; // Appurin global namespace

Appurin.Debug = true;

Appurin.setDebug = function(dbg) {
	Appurin.Debug = dbg;
};

Appurin.alert = function(msg) {
	if (Appurin.Debug) {
		alert(msg);
	}
};

Appurin.isDefined = function(v) {
	return (v != undefined);
}

// define namespace
Appurin.namespace = function() {
	var a=arguments, o=null, i, j, d;
	for (i=0; i<a.length; i=i+1) {
		d=a[i].split(".");
		o=window;
		for (j=0; j<d.length; j=j+1) {
			o[d[j]]=o[d[j]] || {};
			o=o[d[j]];
		}
	}
	return o;
};

/*
Used to prepare the dynamic string using list of arguments. 
*/
 String.prototype.format = function() {
	var s = this;
	arguments = String(arguments[0]).split(',');       
	var i = arguments.length; 
	while (i>=0) {  
		s = s.replace(new RegExp('\\{' + i + '\\}', 'gm'), arguments[i]);i--;
	}
	return s;
};

function htmlEncode(value){
	if (value) {
		return jQuery('<div />').text(value).html();
	} else {
		return '';
	}
}
function htmlDecode(value) {
	if (value) {
		return jQuery('<div />').html(value).text();
	} else {
		return '';
	}
}

// Show Wait Cursor
function startSplash() {                        
	var divObj = document.getElementById('splashDiv');            
	divObj.style.display='block';                                                   
}
function updateSplash() {   
	var divObj = document.getElementById('updateSplashDiv');            
	divObj.style.display='block';                                                   
}
// Hide Wait Cursor		
function endSplash() {              
	document.getElementById('splashDiv').style.display='none';                      
}

Appurin.showLoadingImage = function(parentDivId) {
	var loaderId = parentDivId + 'P' + 'apLoaderImageDivId';
	var selector = '[id$=' + parentDivId + ']';
	j$(selector).append('<div id=' + loaderId + ' class="apLoaderImageDiv"></div>');
}

Appurin.hideLoadingImage = function(parentDivId) {
	var loaderId = parentDivId + 'P' + 'apLoaderImageDivId';
	j$('#' + loaderId).remove();
}

/** render easytooltip for all anchors with class **/
Appurin.easyTooltipWithClass = function (className) {
	var selector = '.' + className;
	j$(selector).easyTooltip();
}

/* will show the hiding div while clicking item in tree*/
Appurin.showLoadingDivInPickerWithDetail = function() {
        var newHeight = j$("#layoutContainer").css("height");
        var newW = j$("#layoutContainer").css("width");
        j$("[id$=curtain]").css("background-color", "white").css("opacity", 0.35).css("height", newHeight).css("width", newW).html("<Div id=\"spinningSign\" class=\"apLoaderImageDivfortree\" ><div>");
   
}

/* will hiding the hiding div while clicking item in tree*/
Appurin.hideLoadingDivInPickerWithDetail = function() {
        j$("[id$=curtain]").css("background-color", "white").css("opacity", "1").css("height", "0px").css("width", "0px");
        j$("#spinningSign").remove();
        if( j$("[id$=detailObj]").attr("id")+''!='undefined'){
        Appurin.showLoadingDivInPickerWithDetailPane();
        }
}

Appurin.showLoadingDivInPickerWithDetailPane = function() {
        var newHeight = j$("#layoutContainer").css("height");
        var newW = j$("#layoutContainer").css("width");
        j$("[id$=curtain]").css("background-color", "white").css("opacity", 0.35).css("height", newHeight).css("width", newW).html("<Div id=\"spinningSign1\" class=\"apLoaderImageDivfortree\" ><div>");
        
}

Appurin.showLoadingDivInUserPickerSearch = function(parentDivId) {
	var idOfCheckBox=j$("[id$=showOnlyPortalForSearch]").attr("id")+'';
	if(idOfCheckBox!='undefined'){
		var showOnlyPortalId=j$("[id$=showOnlyPortalForSearch]").attr("id");
		document.getElementById(showOnlyPortalId).disabled=true;
	}
	var isDefined=j$("[id$=searchSelect]").attr("id")+'';
	if(isDefined!='undefined'){
		j$("[id$=searchSelect]").addClass("disabled");
		j$("[id$=searchCancel]").addClass("disabled");
		j$("[id$=searchButton]").addClass("disabled");
		var selectId=j$("[id$=searchSelect]").attr("id");
		var cancelId=j$("[id$=searchCancel]").attr("id");
		var searchId=j$("[id$=searchButton]").attr("id");
		var searchTextId=j$("[id$=searchText1]").attr("id");
		document.getElementById(selectId).disabled=true;
		document.getElementById(cancelId).disabled=true;
		document.getElementById(searchId).disabled=true;
		document.getElementById(searchTextId).disabled=true;
	}
	var loaderId = parentDivId + 'P' + 'apLoaderImageDivId';
	var selector = '[id$=' + parentDivId + ']';
	j$(selector).append('<div id=' + loaderId + ' class="apLoaderImageDiv"></div>');
}

Appurin.hideLoadingDivInUserPickerSearch = function(parentDivId) {
	var idOfCheckBox=j$("[id$=showOnlyPortalForSearch]").attr("id")+'';
	if(idOfCheckBox!='undefined'){
		var showOnlyPortalId=j$("[id$=showOnlyPortalForSearch]").attr("id");
		document.getElementById(showOnlyPortalId).disabled=false;
	}
	var isDefined=j$("[id$=searchSelect]").attr("id")+'';
	if(isDefined!='undefined'){
		j$("[id$=searchSelect]").removeClass("disabled");
		j$("[id$=searchCancel]").removeClass("disabled");
		j$("[id$=searchButton]").removeClass("disabled");
		var selectId=j$("[id$=searchSelect]").attr("id");
		var cancelId=j$("[id$=searchCancel]").attr("id");
		var searchId=j$("[id$=searchButton]").attr("id");
		var searchTextId=j$("[id$=searchText1]").attr("id");
		document.getElementById(selectId).disabled=false;
		document.getElementById(cancelId).disabled=false;
		document.getElementById(searchId).disabled=false;
		document.getElementById(searchTextId).disabled=false;
	}
	var loaderId = parentDivId + 'P' + 'apLoaderImageDivId';
	j$('#' + loaderId).remove(); 
}
    	
Appurin.initializeRefreshForTree = function(){
	 var currentName=j$('.header').html();
	j$('.header').html('<span>'+currentName+'</span><div class="apRefreshDivfortree">&nbsp;<div>');
	j$('.apRefreshDivfortree').click(function(){refreshNode();});     
}

function refreshNode(){
	var tree = j$('#tree-div').dynatree('getTree');
	var node =  tree.getActiveNode();
	if(node!=null){
		if(!node.data.isLazy){
			node.data.isLazy=true;
			node.render();
			node.resetLazy(); 
			node.expand();
			console.log("inside");
			return;
		}
		node.resetLazy(); 
		node.expand();
		console.log("outside");
	}else{
		tree.reload();
	}
}