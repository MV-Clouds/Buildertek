({

    
    
    readFiles2 : function(component, event, helper, file,poId){
        debugger;
        var filesList = component.get("v.fileData2");
        var reader = new FileReader(); 
        reader.onload = () => {
            var base64 = reader.result.split(',')[1]; 
            var fileData2 = {
            'fileName': file.name,
            'fileContent': base64,
            'POId': poId
        }
        console.log(JSON.stringify(fileData2));
        component.get("v.fileData2").push(fileData2);
        component.set("v.fileData2",component.get("v.fileData2"))
        
        var names = []
        
        for (var i = 0; i < component.get("v.fileData2").length; i++) {
            var name = {};
            name['FileName'] = [];
            name['poId'] = JSON.parse(JSON.stringify(component.get("v.fileData2")[i])).POId
            name['FileName'] = JSON.parse(JSON.stringify(component.get("v.fileData2")[i]))["fileName"];
            names.push(name);
        }
        component.set("v.FileNameList",names);
        component.set("v.fileBody", filesList.fileName);
    }
    reader.readAsDataURL(file);
}
 

})