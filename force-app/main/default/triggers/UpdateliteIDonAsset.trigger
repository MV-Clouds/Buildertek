trigger UpdateliteIDonAsset on Asset (before insert,before update) {
    
    for(Asset ast:Trigger.New){
        if(ast.SerialNumber !=Null && ast.SerialNumber.contains('`')){
        
            ast.Lite_Id__c=Stringformatchanger.addformat(ast.SerialNumber);
        }
        
     if(ast.H1__c!=null)
            ast.H1_B1_in__c = String.valueOf(ast.H1__c);
        else if(ast.W1__c!=null)
            ast.H1_B1_in__c = String.valueOf(ast.W1__c);
        else if(ast.H1__c==null || ast.W1__c==null)
            ast.H1_B1_in__c = '';
    
    }

}