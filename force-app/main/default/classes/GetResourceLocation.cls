/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Laxman
Date: 27/08/2020
Description : To get the current user Geo Location.
*/
public class GetResourceLocation {
    @AuraEnabled
    public static string updatelocation(String recId, Decimal lat, Decimal lng/*, Datetime userDatatime*/, string status){
        string msg = ''; 
        buildertek__Resource_Log__c resourcerecord = [Select id,
                                                      buildertek__Start_Time__c,
                                                      buildertek__End_Time__c,
                                                      buildertek__Start_Location__latitude__s,
                                                      buildertek__Start_Location__longitude__s,
                                                      buildertek__End_Location__latitude__s,
                                                      buildertek__End_Location__longitude__s
                                                      from buildertek__Resource_Log__c where id =:recId limit 1];
        if(status == 'Startime' && (System.now() < resourcerecord.buildertek__End_Time__c || resourcerecord.buildertek__End_Time__c == null)){
      //  resourcerecord.buildertek__Start_Time__c = userDatatime;
        resourcerecord.buildertek__Start_Time__c = System.now();   
        resourcerecord.buildertek__Start_Location__latitude__s = lat;
        resourcerecord.buildertek__Start_Location__longitude__s = lng;
        }else{
            msg =  'Startime';
        }
        if(status == 'Endtime'){
           // resourcerecord.buildertek__End_Time__c = userDatatime;
            resourcerecord.buildertek__End_Time__c = System.now();
            resourcerecord.buildertek__End_Location__latitude__s = lat;
            resourcerecord.buildertek__End_Location__longitude__s = lng;
        }
        update resourcerecord;
        return msg;
        
    }
}