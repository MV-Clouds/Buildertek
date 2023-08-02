({

	loadpdfData:function(component,event){
		var pdfData = component.get('v.pdfData');
        var pdfjsframe = component.find('pdfFrame')
        if(pdfData != 'undefined'){
            pdfjsframe.getElement().contentWindow.postMessage(pdfData,'*');	
        }
	}
})