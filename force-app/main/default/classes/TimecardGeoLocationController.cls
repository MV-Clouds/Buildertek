/*
 Copyright (c) 2017-2018, BuilderTek.
 All rights reserved.

 Developed By: Laxman
 Date: 28/08/2020
 Description : To get the current user Geo Location.
 */
public class TimecardGeoLocationController{
	@AuraEnabled
	//public static buildertek__Time_Cards__c updatelocation(String recId, Decimal lat, Decimal lng, string status){
	  public static string updatelocation(String recId, Decimal lat, Decimal lng, string status){
         string msg = '';
		buildertek__Time_Cards__c timecardrecord = [Select id, buildertek__Start_Time__c, buildertek__End_Time__c, buildertek__Start_Location__latitude__s, buildertek__Start_Location__longitude__s, buildertek__End_Location__latitude__s, buildertek__End_Location__longitude__s
		                                            from buildertek__Time_Cards__c
		                                            where id = :recId
		                                            limit 1];
		if (status == 'Startime' && (System.now() < timecardrecord.buildertek__End_Time__c || timecardrecord.buildertek__End_Time__c == null)){
			timecardrecord.buildertek__Start_Time__c = System.now();
			timecardrecord.buildertek__Start_Location__latitude__s = lat;
			timecardrecord.buildertek__Start_Location__longitude__s = lng;
        }else{
            msg =  'Startime';
        }
		if (status == 'Endtime'){
			timecardrecord.buildertek__End_Time__c = System.now();
			timecardrecord.buildertek__End_Location__latitude__s = lat;
			timecardrecord.buildertek__End_Location__longitude__s = lng;
            system.debug(lat+'--->lat'+lng+'---->'+status);
		}
		update timecardrecord; 
		return msg; 
	}
    @AuraEnabled
    public static string updatestartlocation(String recId, Decimal lat, Decimal lng, string status){
         string msg = '';
		buildertek__Time_Cards__c timecardrecord = [Select id, buildertek__Start_Time__c, buildertek__End_Time__c, buildertek__Start_Location__latitude__s, buildertek__Start_Location__longitude__s, buildertek__End_Location__latitude__s, buildertek__End_Location__longitude__s
		                                            from buildertek__Time_Cards__c
		                                            where id = :recId
		                                            limit 1];
		if (status == 'Startime' &&  timecardrecord.buildertek__Start_Location__latitude__s != null
            						&& timecardrecord.buildertek__Start_Location__longitude__s != null
                                  && (System.now() < timecardrecord.buildertek__End_Time__c || timecardrecord.buildertek__End_Time__c == null)){
			timecardrecord.buildertek__Start_Time__c = System.now();
			timecardrecord.buildertek__Start_Location__latitude__s = lat;
			timecardrecord.buildertek__Start_Location__longitude__s = lng;
        }else{
            msg =  'Startime';
        }
		/*if (status == 'Endtime'){
			timecardrecord.buildertek__End_Time__c = System.now();
			timecardrecord.buildertek__End_Location__latitude__s = lat;
			timecardrecord.buildertek__End_Location__longitude__s = lng;
            system.debug(lat+'--->lat'+lng+'---->'+status);
		}*/
		update timecardrecord; 
		return msg; 
        
    }
}