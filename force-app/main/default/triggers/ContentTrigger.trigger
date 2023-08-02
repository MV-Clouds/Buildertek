trigger ContentTrigger on buildertek__Content__c (after insert, after update) {
    SET<Id> nodeIdSet = new SET<Id>();
    List<buildertek__Admin_Interface_Node_Configuration__c> nodeList = new List<buildertek__Admin_Interface_Node_Configuration__c>();
    if(Trigger.isInsert || Trigger.isUpdate && Trigger.isAfter){
        for(buildertek__Content__c content : Trigger.New){
            nodeIdSet.add(content.buildertek__Admin_Interface_Node_Configuration__c);       
        }
         List<buildertek__Admin_Interface_Node_Configuration__c> nodeConfig;
        if(Schema.sObjectType.buildertek__Admin_Interface_Node_Configuration__c.fields.Id.isAccessible()&&
            Schema.sObjectType.buildertek__Admin_Interface_Node_Configuration__c.fields.Name.isAccessible()&&
            Schema.sObjectType.buildertek__Admin_Interface_Node_Configuration__c.fields.buildertek__Page_URL__c.isAccessible() &&
			Schema.sObjectType.buildertek__Admin_Interface_Node_Configuration__c.fields.buildertek__Parent_Node__c.isAccessible() ){
                                    nodeConfig = [SELECT Id,
                                                 Name,
                                                 buildertek__Page_URL__c,
                                                 buildertek__Parent_Node__c,
                                                 buildertek__Parent_Node__r.Name
                                                 FROM buildertek__Admin_Interface_Node_Configuration__c
                                                 WHERE Id IN: nodeIdSet];
			}
                                                                                     
        for(buildertek__Admin_Interface_Node_Configuration__c node : nodeConfig){
            buildertek__Admin_Interface_Node_Configuration__c newNode = new buildertek__Admin_Interface_Node_Configuration__c();
            //if(node.buildertek__Parent_Node__r.Name == 'BT Training'){
                newNode.Id = node.Id;
                newNode.buildertek__Page_URL__c = '/apex/DisplayContents?id='+node.Id;
                nodeList.add(newNode);
            //}
        } 
        if(nodeList.size() > 0){
            if(Schema.sObjectType.buildertek__Admin_Interface_Node_Configuration__c.isUpdateable()&&
            Schema.sObjectType.buildertek__Admin_Interface_Node_Configuration__c.fields.Id.isUpdateable() &&
			Schema.sObjectType.buildertek__Admin_Interface_Node_Configuration__c.fields.buildertek__Page_URL__c.isUpdateable()){
            update nodeList;   
			}
        }
    }
}