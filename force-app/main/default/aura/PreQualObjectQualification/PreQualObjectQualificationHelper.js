({
	
    /* File upload helper */
         readFiles2 : function(component, event, helper, file){
        var filesList = component.get("v.fileData2");
        var reader = new FileReader(); 
        reader.onload = () => {
            var base64 = reader.result.split(',')[1]; 
            var fileData2 = {
            'fileName': file.name,
            'fileContent': base64,
        }
        console.log(JSON.stringify(fileData2));
        
       
        //filesList.push(fileData2);
        //component.set("v.fileData2", filesList);
        component.get("v.fileData2").push(fileData2);
        component.set("v.fileBody", filesList.fileName);
        
       
        
    }
    //alert("eVENT"+JSON.stringify(component.get("v.fileData2")));
    reader.readAsDataURL(file);
},
    
    /* file upload helper*/
})