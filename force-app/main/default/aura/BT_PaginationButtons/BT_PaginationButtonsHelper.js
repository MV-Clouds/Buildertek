({
	updateDisplayButtons : function(component) {
		var paginationInfo = component.get("v._pagination_info");
        var maxItems = component.get("v._max_items");
        var displayButtons = [];
       
        if(!paginationInfo){
            return;
        }
       
        var totalPages = paginationInfo.totalPages;
        var pageNumber = paginationInfo.pageNumber;
        var halfNumber = Math.floor(maxItems/2);
        
        
        var startNumber = 1;
      /*  if(pageNumber > halfNumber){
            startNumber = pageNumber;
        } */
       /*  alert('startnumber-----'+startNumber);
         alert('endnumber-----'+endNumber);
        alert('maxItems-----'+maxItems);
         alert('totalPages-----'+totalPages);*/
        var endNumber = totalPages;
       /* if(endNumber > totalPages){
            startNumber = endNumber - maxItems + 1;
            endNumber = totalPages;
            alert('end----->'+endNumber);
        }*/
       // alert('endnumbeeeer-----'+endNumber); 
        if(startNumber < 1){
            startNumber = 1;
        }
        
        for(var index = startNumber; index <= endNumber;index ++){
            var paginatorObj = {"num":index,"className":"page-item"};

            if(index === Number.parseInt(pageNumber)){
              paginatorObj.className = 'page-item active';
                
            }
            displayButtons.push(paginatorObj);
            
        }
        var previousClass = "page-item";
        var nextClass = "page-item";
        
        if(startNumber === Number.parseInt(pageNumber)){
            previousClass = "page-item disabled";
            
        }
       // alert('pagenumber--------------->'+Number.parseInt(pageNumber) +'-----endNumber-----'+endNumber);
        if(endNumber === Number.parseInt(pageNumber)){
            nextClass = "page-item disabled";
        }
        
        component.set("v._previous_class",previousClass);  
        
        // alert('previousClassgett-----'+component.get("v._previous_class"));
        component.set("v._next_class",nextClass);
        component.set("v._display_buttons",displayButtons);
	},
    goToPage : function(component, pageNumber){
        var paginationInfo = component.get("v._pagination_info");
        paginationInfo.pageNumber = pageNumber;
        component.set("v._pagination_info", paginationInfo);
    },
})