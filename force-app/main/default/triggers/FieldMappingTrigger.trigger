trigger FieldMappingTrigger on FieldMapping__c (before Update) {
    //List<FieldDef__c> fieldDefList = new List<FieldDef__c>([SELECT ID, Name, APIName__c, Object__c, SFFieldTypeID__c from FieldDef__c ]);
    
    Set<Id> fieldMappingRecIds = new Set<Id>();
    Set<Id> destObjIds = new Set<Id>();
    
    for(FieldMapping__c fieldMappingRec : Trigger.New){
        fieldMappingRecIds.add(fieldMappingRec.Id);
    }
	List<FieldMapping__c> fieldMappingRecList = [SELECT ObjectMapping__c, ObjectMapping__r.DestinationObject__c, DestinationFieldName__c, DestinationField__c from FieldMapping__c WHERE ID =: fieldMappingRecIds];
    system.debug('fieldMappingRecList : '+fieldMappingRecList);
    for(FieldMapping__c fieldMapRec :fieldMappingRecList ){
        destObjIds.add(fieldMapRec.ObjectMapping__r.DestinationObject__c);
    }
    List<FieldDef__c> fieldDefList = new List<FieldDef__c>([SELECT ID, Name, APIName__c, Object__c, SFFieldTypeID__c from FieldDef__c  where Object__c IN: destObjIds]);
    Map<String, Id> fieldApiNameToIdMap = new Map<String, Id>();
    for(FieldDef__c fieldRec : fieldDefList ){
        fieldApiNameToIdMap.put(fieldRec.APIName__c, fieldRec.Id);
    }
    system.debug('fieldApiNameToIdMap : '+fieldApiNameToIdMap);
    system.debug('fieldDefList :'+fieldDefList);
    for(FieldMapping__c fieldMappingRec : Trigger.New){
        if(fieldApiNameToIdMap.containsKey(fieldMappingRec.DestinationFieldName__c)){
            System.debug('Destination Field :'+fieldApiNameToIdMap.get(fieldMappingRec.DestinationFieldName__c));
            fieldMappingRec.DestinationField__c = fieldApiNameToIdMap.get(fieldMappingRec.DestinationFieldName__c);
            system.debug('fieldMappingRec:  '+fieldMappingRec.DestinationField__c);
        }
       
    /*for(FieldMapping__c fieldMappingRec : fieldMappingRecList){
        for(FieldDef__c fieldDefRec : fieldDefList){
            system.debug('fieldDefRec: '+fieldDefRec);
            if(fieldMappingRec.ObjectMapping__r.DestinationObject__c == fieldDefRec.Object__c && fieldMappingRec.DestinationFieldName__c == fieldDefRec.APIName__c){
                system.debug('fieldMappingRec@@: '+fieldMappingRec);
                system.debug('fieldDefRec@@:'+fieldDefRec);
                fieldMappingRec.DestinationField__c = fieldDefRec.Id;
    		}
            /*if(fieldMappingRec.ObjectMapping__r.SourceObject__c == fieldDefRec.Object__c && fieldMappingRec.SourceFieldName__c == fieldDefRec.APIName__c){
                fieldMappingRec.SourceField__c = fieldDefRec.Id;
    		}*/
        }
}